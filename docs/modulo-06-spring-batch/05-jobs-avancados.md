# 05 — Jobs Avançados: Particionamento, Fluxos e Monitoramento

## Revisão do Tópico Anterior
Exportação Oracle → CSV com JdbcCursorItemReader, JdbcPagingItemReader, FlatFileItemWriter, ClassifierCompositeItemWriter, agendamento com @Scheduled.

---

## Particionamento — Processamento Paralelo

O particionamento divide o trabalho em fatias (partições) e as processa em paralelo:

```
MasterStep
    ├── Partição SP → Worker Thread 1 → processa clientes de SP
    ├── Partição RJ → Worker Thread 2 → processa clientes de RJ
    ├── Partição MG → Worker Thread 3 → processa clientes de MG
    └── Partição outros → Worker Thread 4 → demais estados
```

### Partitioner — Define as Partições

```java
package br.com.javazero.batch.partition;

import org.springframework.batch.core.partition.support.Partitioner;
import org.springframework.batch.item.ExecutionContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class EstadoPartitioner implements Partitioner {

    private final JdbcTemplate jdbcTemplate;

    public EstadoPartitioner(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public Map<String, ExecutionContext> partition(int gridSize) {
        // Busca estados distintos que têm clientes
        List<String> estados = jdbcTemplate.queryForList(
            "SELECT DISTINCT estado FROM clientes WHERE estado IS NOT NULL ORDER BY estado",
            String.class
        );

        Map<String, ExecutionContext> partitions = new HashMap<>();

        for (String estado : estados) {
            ExecutionContext ctx = new ExecutionContext();
            ctx.putString("estado", estado);        // cada partição recebe seu estado
            partitions.put("particao-" + estado, ctx);
        }

        return partitions;
    }
}
```

### Worker Step — Processa Uma Partição

```java
@Bean
@StepScope
public JdbcCursorItemReader<Cliente> clienteParticionadoReader(
        DataSource dataSource,
        @Value("#{stepExecutionContext['estado']}") String estado) {

    return new JdbcCursorItemReaderBuilder<Cliente>()
            .name("clienteParticionadoReader")
            .dataSource(dataSource)
            .sql("SELECT * FROM clientes WHERE estado = ? AND ativo = 1 ORDER BY nome")
            .preparedStatementSetter(ps -> ps.setString(1, estado))
            .rowMapper(new BeanPropertyRowMapper<>(Cliente.class))
            .build();
}

@Bean
@StepScope
public FlatFileItemWriter<ClienteRelatorio> writerParticionado(
        @Value("#{stepExecutionContext['estado']}") String estado,
        @Value("${batch.files.output-dir}") String outputDir) {

    // Cada partição gera seu próprio arquivo
    BeanWrapperFieldExtractor<ClienteRelatorio> extractor = new BeanWrapperFieldExtractor<>();
    extractor.setNames(new String[]{"id", "nome", "email", "estado"});

    DelimitedLineAggregator<ClienteRelatorio> aggregator = new DelimitedLineAggregator<>();
    aggregator.setDelimiter(",");
    aggregator.setFieldExtractor(extractor);

    return new FlatFileItemWriterBuilder<ClienteRelatorio>()
            .name("writerParticionado-" + estado)
            .resource(new FileSystemResource(outputDir + "/clientes-" + estado + ".csv"))
            .headerCallback(w -> w.write("id,nome,email,estado"))
            .lineAggregator(aggregator)
            .build();
}
```

### Master Step — Coordena as Partições

```java
@Bean
public Step workerStep(
        JobRepository jobRepository,
        PlatformTransactionManager txManager,
        JdbcCursorItemReader<Cliente> clienteParticionadoReader,
        RelatorioProcessor processor,
        FlatFileItemWriter<ClienteRelatorio> writerParticionado) {

    return new StepBuilder("workerStep", jobRepository)
            .<Cliente, ClienteRelatorio>chunk(200, txManager)
            .reader(clienteParticionadoReader)
            .processor(processor)
            .writer(writerParticionado)
            .build();
}

@Bean
public Step masterStep(
        JobRepository jobRepository,
        EstadoPartitioner partitioner,
        Step workerStep) {

    // TaskExecutorPartitionHandler processa partições em threads paralelas
    TaskExecutorPartitionHandler handler = new TaskExecutorPartitionHandler();
    handler.setTaskExecutor(new SimpleAsyncTaskExecutor());
    handler.setStep(workerStep);
    handler.setGridSize(4);  // até 4 partições simultâneas

    return new StepBuilder("masterStep", jobRepository)
            .partitioner("workerStep", partitioner)
            .partitionHandler(handler)
            .build();
}
```

---

## Fluxos Condicionais — Decisões no Job

```java
// JobExecutionDecider — toma decisão baseada em resultado do step anterior
@Component
public class ArquivoValidoDecider implements JobExecutionDecider {

    @Override
    public FlowExecutionStatus decide(JobExecution jobExecution, StepExecution stepExecution) {
        // Verifica se step anterior teve erros
        if (stepExecution.getSkipCount() > 0) {
            return new FlowExecutionStatus("COM_ERROS");
        }
        return new FlowExecutionStatus("SEM_ERROS");
    }
}

// Configurar fluxo condicional no Job
@Bean
public Job jobComDecisao(
        JobRepository jobRepository,
        Step validarStep,
        Step importarStep,
        Step notificarErrosStep,
        Step notificarSucessoStep,
        ArquivoValidoDecider decider) {

    return new JobBuilder("jobComDecisao", jobRepository)
            .start(validarStep)
            .next(importarStep)
            .next(decider)                              // ponto de decisão
                .on("COM_ERROS").to(notificarErrosStep)     // se houver erros
                .on("SEM_ERROS").to(notificarSucessoStep)   // se tudo OK
            .end()
            .build();
}
```

---

## Múltiplos Steps em Paralelo — Split Flow

```java
@Bean
public Job jobParalelo(JobRepository jobRepository,
                        Flow flowImportacao,
                        Flow flowExportacao,
                        Step consolidarStep) {

    // flowImportacao e flowExportacao rodam ao mesmo tempo
    return new JobBuilder("jobParalelo", jobRepository)
            .start(flowImportacao)
            .split(new SimpleAsyncTaskExecutor())
                .add(flowExportacao)
            .end()
            .next(consolidarStep)    // aguarda ambos terminarem, depois consolida
            .build();
}

@Bean
public Flow flowImportacao(Step importarClientesStep) {
    return new FlowBuilder<SimpleFlow>("flowImportacao")
            .start(importarClientesStep)
            .build();
}

@Bean
public Flow flowExportacao(Step exportarRelatorioStep) {
    return new FlowBuilder<SimpleFlow>("flowExportacao")
            .start(exportarRelatorioStep)
            .build();
}
```

---

## Reinicialização de Jobs — Restart

O Spring Batch salva o estado no `JobRepository`. Se um job falhar, pode ser reiniciado do ponto de parada:

```java
// Habilitar reinicialização (padrão: true)
@Bean
public Step stepReiniciavel(JobRepository jobRepository, ...) {
    return new StepBuilder("stepReiniciavel", jobRepository)
            .<ClienteInput, Cliente>chunk(100, txManager)
            .reader(reader)          // FlatFileItemReader salva posição automaticamente
            .processor(processor)
            .writer(writer)
            .allowStartIfComplete(false)  // não reinicia se completou com sucesso
            .startLimit(3)               // máximo 3 tentativas de iniciar este step
            .build();
}

// Forçar reinício de job que já completou (útil em desenvolvimento)
JobParameters params = new JobParametersBuilder()
        .addString("nomeArquivo", "clientes.csv")
        .addLong("timestamp", System.currentTimeMillis())  // timestamp diferente = novo job
        .toJobParameters();
```

### Consultar status para reinício

```sql
-- Jobs que falharam (candidatos a reinício)
SELECT ji.job_name,
       je.job_execution_id,
       je.status,
       je.exit_message
FROM batch_job_execution je
JOIN batch_job_instance ji ON je.job_instance_id = ji.job_instance_id
WHERE je.status IN ('FAILED', 'STOPPED')
ORDER BY je.create_time DESC;

-- Reiniciar job via JobOperator (API programática)
```

```java
// JobOperator para operações administrativas
@Autowired
private JobOperator jobOperator;

public void reiniciarJob(Long executionId) throws Exception {
    Long novaExecucaoId = jobOperator.restart(executionId);
    System.out.println("Job reiniciado. Nova execução: " + novaExecucaoId);
}

public void pararJob(Long executionId) throws Exception {
    jobOperator.stop(executionId);
}
```

---

## Monitoramento — Spring Batch Admin / Actuator

### Expor métricas via Actuator

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health, info, metrics, batch
  endpoint:
    health:
      show-details: always
```

```bash
# Endpoints disponíveis
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/metrics
curl http://localhost:8080/actuator/metrics/spring.batch.job
```

### Métricas do Spring Batch no Actuator

```bash
# Número de execuções de jobs
GET /actuator/metrics/spring.batch.job.count

# Tempo médio de execução por job
GET /actuator/metrics/spring.batch.job?tag=name:importacaoClientesJob

# Contadores de itens por step
GET /actuator/metrics/spring.batch.step.item.count
```

---

## Skip e Retry Avançados

```java
@Bean
public Step stepRobusto(JobRepository jobRepository, PlatformTransactionManager txManager,
                         ItemReader<ClienteInput> reader,
                         ItemProcessor<ClienteInput, Cliente> processor,
                         ItemWriter<Cliente> writer,
                         SkipListener<ClienteInput, Cliente> skipListener) {

    return new StepBuilder("stepRobusto", jobRepository)
            .<ClienteInput, Cliente>chunk(100, txManager)
            .reader(reader)
            .processor(processor)
            .writer(writer)
            .faultTolerant()
                // Skip: ignora registros com estes erros
                .skip(FlatFileParseException.class)
                .skip(ValidationException.class)
                .skipLimit(100)
                // Não skippar erros críticos
                .noSkip(IllegalArgumentException.class)
                // Retry: tenta novamente em erros transitórios
                .retry(DeadlockLoserDataAccessException.class)
                .retry(CannotAcquireLockException.class)
                .retryLimit(3)
                // Back-off: espera entre tentativas
                .backOffPolicy(new ExponentialBackOffPolicy())
            .listener(skipListener)
            .build();
}
```

### SkipListener — Log de Registros Pulados

```java
@Component
public class ClienteSkipListener implements SkipListener<ClienteInput, Cliente> {

    private static final Logger log = LoggerFactory.getLogger(ClienteSkipListener.class);

    @Override
    public void onSkipInRead(Throwable t) {
        log.warn("Registro pulado na leitura: {}", t.getMessage());
    }

    @Override
    public void onSkipInProcess(ClienteInput item, Throwable t) {
        log.warn("Registro pulado no processamento — item: {}, erro: {}", item, t.getMessage());
    }

    @Override
    public void onSkipInWrite(Cliente item, Throwable t) {
        log.warn("Registro pulado na escrita — item: {}, erro: {}", item.getNome(), t.getMessage());
    }
}
```

---

## ItemStream — Estado Customizado

Para readers/writers que precisam salvar/restaurar estado:

```java
@Component
public class StatefulItemReader implements ItemReader<String>, ItemStream {

    private int posicaoAtual = 0;
    private static final String POSICAO_KEY = "posicao.atual";

    @Override
    public String read() {
        // lógica de leitura usando posicaoAtual
        return posicaoAtual < 100 ? "item-" + posicaoAtual++ : null;
    }

    @Override
    public void open(ExecutionContext executionContext) {
        // Restaurar posição salva anteriormente (em caso de restart)
        if (executionContext.containsKey(POSICAO_KEY)) {
            posicaoAtual = executionContext.getInt(POSICAO_KEY);
        }
    }

    @Override
    public void update(ExecutionContext executionContext) {
        // Salvar posição atual após cada chunk (para restart)
        executionContext.putInt(POSICAO_KEY, posicaoAtual);
    }

    @Override
    public void close() {
        // Liberar recursos
    }
}
```

---

## Tabelas de Metadados do Spring Batch

O Spring Batch usa 9 tabelas para rastrear execuções:

```
BATCH_JOB_INSTANCE        — cada instância única de um job (parâmetros distintos)
BATCH_JOB_EXECUTION       — cada execução (tentativa) de uma instância
BATCH_JOB_EXECUTION_PARAMS — parâmetros passados para cada execução
BATCH_JOB_EXECUTION_CONTEXT— estado salvo do job (para restart)
BATCH_STEP_EXECUTION      — execução de cada step
BATCH_STEP_EXECUTION_CONTEXT— estado salvo do step (posição para restart)
```

```sql
-- Monitoramento operacional

-- Jobs executando agora
SELECT ji.job_name, je.status, je.start_time
FROM batch_job_execution je
JOIN batch_job_instance ji ON je.job_instance_id = ji.job_instance_id
WHERE je.status = 'STARTED';

-- Histórico dos últimos 7 dias
SELECT ji.job_name,
       je.status,
       je.start_time,
       je.end_time,
       se.read_count,
       se.write_count,
       se.skip_count
FROM batch_job_execution je
JOIN batch_job_instance ji ON je.job_instance_id = ji.job_instance_id
JOIN batch_step_execution se ON je.job_execution_id = se.job_execution_id
WHERE je.start_time >= SYSDATE - 7
ORDER BY je.start_time DESC;
```

---

## Exercícios

### Básico
1. Configure `startLimit(2)` em um step e force-o a falhar — observe o comportamento no banco
2. Use `allowStartIfComplete(true)` e execute o mesmo job duas vezes com os mesmos parâmetros
3. Consulte as tabelas `BATCH_JOB_EXECUTION` e `BATCH_STEP_EXECUTION` após execuções com falha

### Intermediário
4. Implemente `EstadoPartitioner` que divide por range de ID (1-1000, 1001-2000, etc.) em vez de estado
5. Configure um job com dois steps em paralelo usando `split()` e verifique se ambos realmente rodam ao mesmo tempo
6. Implemente `SkipListener` que salva os registros pulados em uma tabela `erros_importacao`

### Avançado
7. Implemente um `JobExecutionDecider` que verifica se há um arquivo de lock e aguarda sua liberação
8. Configure particionamento remoto usando `MessageChannelPartitionHandler` com Spring Integration
9. Crie um endpoint REST que: lista jobs em execução, reinicia jobs falhados, e para jobs em andamento usando `JobOperator`
