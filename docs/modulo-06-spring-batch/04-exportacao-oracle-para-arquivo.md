# 04 — Exportação do Oracle para Arquivo

## Revisão do Tópico Anterior
Job de importação completo: FlatFileItemReader → ClienteProcessor → JdbcBatchItemWriter, ValidarArquivoTasklet, Listeners, skip/retry para fault tolerance.

---

## Visão Geral

Agora o fluxo inverso: ler dados do Oracle e gerar arquivos de saída.

```
Oracle DB
    ↓
JdbcCursorItemReader  →  RelatorioProcessor  →  FlatFileItemWriter
    (lê clientes)           (transforma/calcula)    (gera CSV/TXT)
```

Casos de uso comuns:
- Relatórios diários exportados para CSV
- Arquivos de remessa para bancos/parceiros
- Backup de dados em formato texto
- Feeds para outros sistemas

---

## ItemReader — Lendo do Banco

### JdbcCursorItemReader (streaming)

```java
// Lê linha a linha com cursor SQL — ideal para grandes volumes
@Bean
public JdbcCursorItemReader<Cliente> clienteDbReader(DataSource dataSource) {
    return new JdbcCursorItemReaderBuilder<Cliente>()
            .name("clienteDbReader")
            .dataSource(dataSource)
            .sql("""
                SELECT cliente_id, nome, email, cpf, telefone, cidade, estado,
                       data_import
                FROM clientes
                WHERE ativo = 1
                ORDER BY estado, nome
                """)
            .rowMapper(new BeanPropertyRowMapper<>(Cliente.class))
            .build();
}
```

### JdbcPagingItemReader (paginação)

```java
// Lê em páginas — melhor quando o banco não suporta cursores eficientemente
@Bean
public JdbcPagingItemReader<Cliente> clientePagingReader(DataSource dataSource) {
    Map<String, Order> sortKeys = new LinkedHashMap<>();
    sortKeys.put("estado", Order.ASCENDING);
    sortKeys.put("nome", Order.ASCENDING);

    OraclePagingQueryProvider queryProvider = new OraclePagingQueryProvider();
    queryProvider.setSelectClause("SELECT cliente_id, nome, email, cpf, telefone, cidade, estado");
    queryProvider.setFromClause("FROM clientes");
    queryProvider.setWhereClause("WHERE ativo = 1");
    queryProvider.setSortKeys(sortKeys);

    return new JdbcPagingItemReaderBuilder<Cliente>()
            .name("clientePagingReader")
            .dataSource(dataSource)
            .queryProvider(queryProvider)
            .rowMapper(new BeanPropertyRowMapper<>(Cliente.class))
            .pageSize(500)
            .build();
}
```

### Comparação: Cursor vs Paging

| Critério | JdbcCursorItemReader | JdbcPagingItemReader |
|----------|---------------------|---------------------|
| Mecanismo | Cursor SQL mantido aberto | Queries paginadas (OFFSET/ROWNUM) |
| Thread safety | Não thread-safe | Thread-safe |
| Reiniciabilidade | Sim (com saveState) | Sim |
| Performance | Melhor para 1 thread | Melhor para multi-thread |
| Oracle | Requer conexão aberta | Fecha após cada página |

---

## Processor — Transformação para Relatório

```java
package br.com.javazero.batch.processor;

import br.com.javazero.batch.model.Cliente;
import br.com.javazero.batch.model.ClienteRelatorio;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.stereotype.Component;

@Component
public class RelatorioProcessor implements ItemProcessor<Cliente, ClienteRelatorio> {

    @Override
    public ClienteRelatorio process(Cliente cliente) {
        // Formatar CPF mascarado (privacidade)
        String cpfMascarado = mascarar(cliente.getCpf());

        // Normalizar estado
        String estado = cliente.getEstado() != null
                ? cliente.getEstado().toUpperCase()
                : "N/D";

        return new ClienteRelatorio(
            cliente.getId(),
            cliente.getNome(),
            cliente.getEmail(),
            cpfMascarado,
            cliente.getCidade() != null ? cliente.getCidade() : "",
            estado
        );
    }

    private String mascarar(String cpf) {
        if (cpf == null || cpf.length() < 11) return "***.***.***-**";
        // Mantém apenas primeiros 3 e últimos 2 dígitos visíveis
        String digitos = cpf.replaceAll("[^0-9]", "");
        return digitos.substring(0, 3) + ".***.***-" + digitos.substring(9);
    }
}
```

```java
// ClienteRelatorio.java
package br.com.javazero.batch.model;

public record ClienteRelatorio(
    Long id,
    String nome,
    String email,
    String cpfMascarado,
    String cidade,
    String estado
) {}
```

---

## ItemWriter — Escrevendo Arquivo CSV

```java
@Bean
@StepScope
public FlatFileItemWriter<ClienteRelatorio> relatorioWriter(
        @Value("#{jobParameters['nomeArquivoSaida']}") String nomeArquivo,
        @Value("${batch.files.output-dir}") String outputDir) {

    // Extrai campos do record na ordem desejada
    BeanWrapperFieldExtractor<ClienteRelatorio> extractor =
        new BeanWrapperFieldExtractor<>();
    extractor.setNames(new String[]{"id", "nome", "email", "cpfMascarado", "cidade", "estado"});

    // Junta com vírgula
    DelimitedLineAggregator<ClienteRelatorio> aggregator =
        new DelimitedLineAggregator<>();
    aggregator.setDelimiter(",");
    aggregator.setFieldExtractor(extractor);

    return new FlatFileItemWriterBuilder<ClienteRelatorio>()
            .name("relatorioWriter")
            .resource(new FileSystemResource(outputDir + "/" + nomeArquivo))
            .headerCallback(w -> w.write("id,nome,email,cpf,cidade,estado"))
            .lineAggregator(aggregator)
            .append(false)     // sobrescrever arquivo existente
            .build();
}
```

---

## ItemWriter — Escrevendo Arquivo com Formatação Fixa

```java
// Formato posicional (largura fixa) — comum em integrações bancárias
@Bean
@StepScope
public FlatFileItemWriter<ClienteRelatorio> relatorioFixoWriter(
        @Value("#{jobParameters['nomeArquivoSaida']}") String nomeArquivo,
        @Value("${batch.files.output-dir}") String outputDir) {

    FormatterLineAggregator<ClienteRelatorio> aggregator =
        new FormatterLineAggregator<>();
    // %-10d = inteiro, largura 10, alinhado à esquerda
    // %-50s = string, largura 50, alinhado à esquerda
    aggregator.setFormat("%-10d%-50s%-100s%-2s");
    BeanWrapperFieldExtractor<ClienteRelatorio> extractor =
        new BeanWrapperFieldExtractor<>();
    extractor.setNames(new String[]{"id", "nome", "email", "estado"});
    aggregator.setFieldExtractor(extractor);

    return new FlatFileItemWriterBuilder<ClienteRelatorio>()
            .name("relatorioFixoWriter")
            .resource(new FileSystemResource(outputDir + "/" + nomeArquivo))
            .lineAggregator(aggregator)
            .build();
}
```

---

## Job Completo de Exportação

```java
package br.com.javazero.batch.config;

import br.com.javazero.batch.listener.JobExportacaoListener;
import br.com.javazero.batch.listener.StepImportacaoListener;
import br.com.javazero.batch.model.Cliente;
import br.com.javazero.batch.model.ClienteRelatorio;
import br.com.javazero.batch.processor.RelatorioProcessor;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.database.JdbcCursorItemReader;
import org.springframework.batch.item.file.FlatFileItemWriter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

@Configuration
public class ExportacaoJobConfig {

    @Bean
    public Step exportarClientesStep(
            JobRepository jobRepository,
            PlatformTransactionManager txManager,
            JdbcCursorItemReader<Cliente> clienteDbReader,
            RelatorioProcessor processor,
            FlatFileItemWriter<ClienteRelatorio> relatorioWriter,
            StepImportacaoListener listener) {

        return new StepBuilder("exportarClientesStep", jobRepository)
                .<Cliente, ClienteRelatorio>chunk(500, txManager)
                .reader(clienteDbReader)
                .processor(processor)
                .writer(relatorioWriter)
                .listener(listener)
                .build();
    }

    @Bean
    public Job exportacaoRelatorioJob(
            JobRepository jobRepository,
            Step exportarClientesStep,
            JobExportacaoListener listener) {

        return new JobBuilder("exportacaoRelatorioJob", jobRepository)
                .listener(listener)
                .start(exportarClientesStep)
                .build();
    }
}
```

---

## Listener de Exportação com Métricas

```java
package br.com.javazero.batch.listener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobExecutionListener;
import org.springframework.batch.core.StepExecution;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
public class JobExportacaoListener implements JobExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(JobExportacaoListener.class);

    @Override
    public void beforeJob(JobExecution jobExecution) {
        log.info("Iniciando exportação...");
        log.info("Arquivo de saída: {}",
            jobExecution.getJobParameters().getString("nomeArquivoSaida"));
    }

    @Override
    public void afterJob(JobExecution jobExecution) {
        Duration duracao = Duration.between(
            jobExecution.getStartTime(),
            jobExecution.getEndTime()
        );

        long totalExportados = jobExecution.getStepExecutions().stream()
            .mapToLong(StepExecution::getWriteCount)
            .sum();

        log.info("Exportação concluída!");
        log.info("  Total exportado : {} registros", totalExportados);
        log.info("  Duração         : {} segundos", duracao.getSeconds());
        log.info("  Status          : {}", jobExecution.getStatus());
    }
}
```

---

## Múltiplos Writers — ClassifierCompositeItemWriter

Quando precisar escrever em destinos diferentes baseado em uma condição:

```java
@Bean
public ClassifierCompositeItemWriter<ClienteRelatorio> compositeWriter(
        FlatFileItemWriter<ClienteRelatorio> writerSP,
        FlatFileItemWriter<ClienteRelatorio> writerOutros) {

    // Escreve em arquivo diferente dependendo do estado
    Classifier<ClienteRelatorio, ItemWriter<? super ClienteRelatorio>> classifier =
        cliente -> cliente.estado().equals("SP") ? writerSP : writerOutros;

    ClassifierCompositeItemWriter<ClienteRelatorio> writer =
        new ClassifierCompositeItemWriter<>();
    writer.setClassifier(classifier);
    return writer;
}
```

---

## Executar a Exportação

```bash
# Via linha de comando
java -jar target/exportacao-clientes-1.0.0.jar \
  --spring.batch.job.name=exportacaoRelatorioJob \
  nomeArquivoSaida=relatorio-clientes-$(date +%Y%m%d).csv

# Via curl (se expor endpoint)
curl -X POST "http://localhost:8080/batch/exportar?nomeArquivoSaida=relatorio.csv"

# Verificar arquivo gerado
cat /tmp/batch/output/relatorio-clientes-20260323.csv
wc -l /tmp/batch/output/relatorio-clientes-20260323.csv
```

---

## Saída Esperada no Log

```
INFO  JobExportacaoListener - Iniciando exportação...
INFO  JobExportacaoListener - Arquivo de saída: relatorio-clientes-20260323.csv
INFO  StepImportacaoListener - --- Iniciando step: exportarClientesStep ---
INFO  StepImportacaoListener - --- Step finalizado: exportarClientesStep ---
INFO  StepImportacaoListener -   Lidos    : 1000
INFO  StepImportacaoListener -   Escritos : 1000
INFO  StepImportacaoListener -   Ignorados: 0
INFO  JobExportacaoListener - Exportação concluída!
INFO  JobExportacaoListener -   Total exportado : 1000 registros
INFO  JobExportacaoListener -   Duração         : 3 segundos
```

---

## Agendamento com @Scheduled

```java
@Component
public class BatchScheduler {

    private final JobLauncher jobLauncher;
    private final Job exportacaoRelatorioJob;

    public BatchScheduler(JobLauncher jobLauncher, Job exportacaoRelatorioJob) {
        this.jobLauncher = jobLauncher;
        this.exportacaoRelatorioJob = exportacaoRelatorioJob;
    }

    // Executa todos os dias às 02:00
    @Scheduled(cron = "0 0 2 * * *")
    public void executarExportacaoDiaria() throws Exception {
        String dataHoje = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);

        JobParameters params = new JobParametersBuilder()
                .addString("nomeArquivoSaida", "relatorio-" + dataHoje + ".csv")
                .addLong("timestamp", System.currentTimeMillis())
                .toJobParameters();

        jobLauncher.run(exportacaoRelatorioJob, params);
    }
}
```

Adicionar no `application.yml`:
```yaml
spring:
  task:
    scheduling:
      enabled: true
```

E na Application class:
```java
@SpringBootApplication
@EnableScheduling
public class ExportacaoApplication { ... }
```

---

## Exercícios

### Básico
1. Configure um `JdbcCursorItemReader` que lê apenas clientes do estado `MG`
2. Altere o `RelatorioProcessor` para converter o email para maiúsculas
3. Gere um arquivo com separador `;` em vez de `,`

### Intermediário
4. Use `JdbcPagingItemReader` com `pageSize=200` e compare o desempenho com o Cursor
5. Adicione um campo `dataExportacao` no CSV com a data atual formatada como `dd/MM/yyyy`
6. Implemente `ClassifierCompositeItemWriter` separando clientes ativos dos inativos em arquivos diferentes

### Avançado
7. Configure o `@Scheduled` para exportar automaticamente às 23h de segunda a sexta
8. Implemente um writer customizado que envia o arquivo gerado via SFTP (use JSch ou Apache Commons VFS)
9. Use `MultiResourceItemWriter` para criar um novo arquivo a cada 10.000 registros exportados
