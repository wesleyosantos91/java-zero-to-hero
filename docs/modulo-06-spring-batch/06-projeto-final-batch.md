# 06 — Projeto Final: Sistema de Processamento de Pedidos

## Visão Geral

Sistema completo de processamento batch que integra todos os conceitos do módulo:

1. **Importar** pedidos de um arquivo CSV para o Oracle
2. **Processar** calcular totais, validar estoque, classificar status
3. **Exportar** relatório de pedidos processados em CSV
4. **Notificar** log de pedidos com problema

```
pedidos.csv
    ↓
[Step 1] ValidarArquivoTasklet
    ↓
[Step 2] ImportarPedidosStep   (FlatFileItemReader → PedidoProcessor → JdbcBatchItemWriter)
    ↓
[Step 3] ProcessarPedidosStep  (JdbcCursorItemReader → StatusProcessor → JdbcBatchItemWriter)
    ↓
[Step 4] GerarRelatorioStep    (JdbcCursorItemReader → RelatorioProcessor → FlatFileItemWriter)
    ↓
relatorio-pedidos.csv
```

---

## Estrutura do Projeto

```
processamento-pedidos/
├── pom.xml
├── src/main/
│   ├── java/br/com/javazero/pedidos/
│   │   ├── ProcessamentoPedidosApplication.java
│   │   ├── config/
│   │   │   └── PedidoJobConfig.java
│   │   ├── model/
│   │   │   ├── PedidoInput.java
│   │   │   ├── Pedido.java
│   │   │   └── PedidoRelatorio.java
│   │   ├── processor/
│   │   │   ├── PedidoImportProcessor.java
│   │   │   └── PedidoStatusProcessor.java
│   │   ├── tasklet/
│   │   │   └── ValidarArquivoTasklet.java
│   │   └── listener/
│   │       └── PedidoJobListener.java
│   └── resources/
│       └── application.yml
└── data/
    └── pedidos-exemplo.csv
```

---

## Script SQL — Schema Oracle

```sql
-- Sequência e tabela de pedidos
CREATE SEQUENCE seq_pedidos START WITH 1 INCREMENT BY 1;

CREATE TABLE pedidos (
    pedido_id       NUMBER        DEFAULT seq_pedidos.NEXTVAL PRIMARY KEY,
    numero_pedido   VARCHAR2(20)  NOT NULL UNIQUE,
    cliente_email   VARCHAR2(200) NOT NULL,
    produto_codigo  VARCHAR2(50)  NOT NULL,
    quantidade      NUMBER        NOT NULL,
    preco_unitario  NUMBER(10,2)  NOT NULL,
    total           NUMBER(10,2),
    status          VARCHAR2(20)  DEFAULT 'PENDENTE',
    data_pedido     DATE,
    data_processo   TIMESTAMP,
    observacao      VARCHAR2(500)
);

-- Tabela de estoque para validação
CREATE TABLE estoque (
    produto_codigo  VARCHAR2(50)  PRIMARY KEY,
    quantidade      NUMBER        NOT NULL,
    preco_unitario  NUMBER(10,2)  NOT NULL
);

-- Dados de estoque para teste
INSERT INTO estoque VALUES ('PROD-001', 100, 29.90);
INSERT INTO estoque VALUES ('PROD-002', 50,  99.90);
INSERT INTO estoque VALUES ('PROD-003', 0,   149.90);  -- sem estoque
INSERT INTO estoque VALUES ('PROD-004', 200, 19.90);
COMMIT;
```

---

## Arquivo CSV de Pedidos

```
numero_pedido,cliente_email,produto_codigo,quantidade,data_pedido
PED-0001,ana@email.com,PROD-001,2,2026-03-20
PED-0002,bruno@email.com,PROD-002,1,2026-03-20
PED-0003,carla@email.com,PROD-003,5,2026-03-21
PED-0004,daniel@email.com,PROD-001,10,2026-03-21
PED-0005,,PROD-004,1,2026-03-22
PED-0006,eva@email.com,PROD-002,0,2026-03-22
PED-0007,fabio@email.com,PROD-004,3,2026-03-22
```

Linha 5 (sem email) e linha 6 (quantidade zero) serão rejeitadas.
Linha 3 (PROD-003 sem estoque) será importada mas marcada como `SEM_ESTOQUE`.

---

## Modelos

```java
// PedidoInput.java — linha do CSV
package br.com.javazero.pedidos.model;

import java.time.LocalDate;

public class PedidoInput {
    private String numeroPedido;
    private String clienteEmail;
    private String produtoCodigo;
    private Integer quantidade;
    private LocalDate dataPedido;

    // Getters e Setters
    public String getNumeroPedido() { return numeroPedido; }
    public void setNumeroPedido(String numeroPedido) { this.numeroPedido = numeroPedido; }
    public String getClienteEmail() { return clienteEmail; }
    public void setClienteEmail(String clienteEmail) { this.clienteEmail = clienteEmail; }
    public String getProdutoCodigo() { return produtoCodigo; }
    public void setProdutoCodigo(String produtoCodigo) { this.produtoCodigo = produtoCodigo; }
    public Integer getQuantidade() { return quantidade; }
    public void setQuantidade(Integer quantidade) { this.quantidade = quantidade; }
    public LocalDate getDataPedido() { return dataPedido; }
    public void setDataPedido(LocalDate dataPedido) { this.dataPedido = dataPedido; }

    @Override
    public String toString() {
        return "PedidoInput{numero='" + numeroPedido + "', produto='" + produtoCodigo + "'}";
    }
}

// Pedido.java — entidade
package br.com.javazero.pedidos.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Pedido {
    private Long pedidoId;
    private String numeroPedido;
    private String clienteEmail;
    private String produtoCodigo;
    private Integer quantidade;
    private BigDecimal precoUnitario;
    private BigDecimal total;
    private String status;
    private LocalDate dataPedido;
    private String observacao;

    // Getters e Setters
    public Long getPedidoId() { return pedidoId; }
    public void setPedidoId(Long pedidoId) { this.pedidoId = pedidoId; }
    public String getNumeroPedido() { return numeroPedido; }
    public void setNumeroPedido(String numeroPedido) { this.numeroPedido = numeroPedido; }
    public String getClienteEmail() { return clienteEmail; }
    public void setClienteEmail(String clienteEmail) { this.clienteEmail = clienteEmail; }
    public String getProdutoCodigo() { return produtoCodigo; }
    public void setProdutoCodigo(String produtoCodigo) { this.produtoCodigo = produtoCodigo; }
    public Integer getQuantidade() { return quantidade; }
    public void setQuantidade(Integer quantidade) { this.quantidade = quantidade; }
    public BigDecimal getPrecoUnitario() { return precoUnitario; }
    public void setPrecoUnitario(BigDecimal precoUnitario) { this.precoUnitario = precoUnitario; }
    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDate getDataPedido() { return dataPedido; }
    public void setDataPedido(LocalDate dataPedido) { this.dataPedido = dataPedido; }
    public String getObservacao() { return observacao; }
    public void setObservacao(String observacao) { this.observacao = observacao; }
}

// PedidoRelatorio.java — linha do CSV de saída
package br.com.javazero.pedidos.model;

import java.math.BigDecimal;

public record PedidoRelatorio(
    String numeroPedido,
    String clienteEmail,
    String produtoCodigo,
    Integer quantidade,
    BigDecimal total,
    String status,
    String observacao
) {}
```

---

## Processors

```java
// PedidoImportProcessor.java — Step 2: valida e enriquece dados do CSV
package br.com.javazero.pedidos.processor;

import br.com.javazero.pedidos.model.Pedido;
import br.com.javazero.pedidos.model.PedidoInput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
public class PedidoImportProcessor implements ItemProcessor<PedidoInput, Pedido> {

    private static final Logger log = LoggerFactory.getLogger(PedidoImportProcessor.class);
    private final JdbcTemplate jdbc;

    public PedidoImportProcessor(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Override
    public Pedido process(PedidoInput input) {
        // Validações básicas — retornar null = ignorar registro
        if (input.getClienteEmail() == null || input.getClienteEmail().isBlank()) {
            log.warn("Pedido {} ignorado — email do cliente ausente", input.getNumeroPedido());
            return null;
        }
        if (input.getQuantidade() == null || input.getQuantidade() <= 0) {
            log.warn("Pedido {} ignorado — quantidade inválida: {}", input.getNumeroPedido(), input.getQuantidade());
            return null;
        }

        // Buscar preço do produto no banco
        BigDecimal preco;
        try {
            preco = jdbc.queryForObject(
                "SELECT preco_unitario FROM estoque WHERE produto_codigo = ?",
                BigDecimal.class,
                input.getProdutoCodigo()
            );
        } catch (Exception e) {
            log.warn("Pedido {} ignorado — produto não encontrado: {}", input.getNumeroPedido(), input.getProdutoCodigo());
            return null;
        }

        Pedido pedido = new Pedido();
        pedido.setNumeroPedido(input.getNumeroPedido().trim().toUpperCase());
        pedido.setClienteEmail(input.getClienteEmail().trim().toLowerCase());
        pedido.setProdutoCodigo(input.getProdutoCodigo().trim().toUpperCase());
        pedido.setQuantidade(input.getQuantidade());
        pedido.setPrecoUnitario(preco);
        pedido.setTotal(preco.multiply(BigDecimal.valueOf(input.getQuantidade())));
        pedido.setDataPedido(input.getDataPedido());
        pedido.setStatus("PENDENTE");

        return pedido;
    }
}

// PedidoStatusProcessor.java — Step 3: verifica estoque e define status final
package br.com.javazero.pedidos.processor;

import br.com.javazero.pedidos.model.Pedido;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class PedidoStatusProcessor implements ItemProcessor<Pedido, Pedido> {

    private static final Logger log = LoggerFactory.getLogger(PedidoStatusProcessor.class);
    private final JdbcTemplate jdbc;

    public PedidoStatusProcessor(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Override
    public Pedido process(Pedido pedido) {
        // Verificar estoque disponível
        Integer estoqueDisponivel = jdbc.queryForObject(
            "SELECT quantidade FROM estoque WHERE produto_codigo = ?",
            Integer.class,
            pedido.getProdutoCodigo()
        );

        if (estoqueDisponivel == null || estoqueDisponivel < pedido.getQuantidade()) {
            pedido.setStatus("SEM_ESTOQUE");
            pedido.setObservacao(
                "Estoque insuficiente: disponível=" + estoqueDisponivel +
                ", solicitado=" + pedido.getQuantidade()
            );
            log.warn("Pedido {} — sem estoque para {}", pedido.getNumeroPedido(), pedido.getProdutoCodigo());
        } else {
            pedido.setStatus("APROVADO");
            pedido.setObservacao("Pedido aprovado e reservado");
            log.debug("Pedido {} — aprovado", pedido.getNumeroPedido());
        }

        return pedido;
    }
}
```

---

## Configuração Completa do Job

```java
package br.com.javazero.pedidos.config;

import br.com.javazero.pedidos.listener.PedidoJobListener;
import br.com.javazero.pedidos.model.Pedido;
import br.com.javazero.pedidos.model.PedidoInput;
import br.com.javazero.pedidos.model.PedidoRelatorio;
import br.com.javazero.pedidos.processor.PedidoImportProcessor;
import br.com.javazero.pedidos.processor.PedidoStatusProcessor;
import br.com.javazero.pedidos.tasklet.ValidarArquivoTasklet;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.StepScope;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.database.JdbcBatchItemWriter;
import org.springframework.batch.item.database.JdbcCursorItemReader;
import org.springframework.batch.item.database.builder.JdbcBatchItemWriterBuilder;
import org.springframework.batch.item.database.builder.JdbcCursorItemReaderBuilder;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.FlatFileItemWriter;
import org.springframework.batch.item.file.FlatFileParseException;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.batch.item.file.builder.FlatFileItemWriterBuilder;
import org.springframework.batch.item.file.mapping.BeanWrapperFieldSetMapper;
import org.springframework.batch.item.file.transform.BeanWrapperFieldExtractor;
import org.springframework.batch.item.file.transform.DelimitedLineAggregator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.transaction.PlatformTransactionManager;

import javax.sql.DataSource;
import java.time.format.DateTimeFormatter;

@Configuration
public class PedidoJobConfig {

    // === STEP 1: VALIDAR ARQUIVO ===

    @Bean
    public Step validarArquivoStep(JobRepository jobRepository,
                                    PlatformTransactionManager txManager,
                                    ValidarArquivoTasklet tasklet) {
        return new StepBuilder("validarArquivoStep", jobRepository)
                .tasklet(tasklet, txManager)
                .build();
    }

    // === STEP 2: IMPORTAR PEDIDOS ===

    @Bean
    @StepScope
    public FlatFileItemReader<PedidoInput> pedidoReader(
            @Value("#{jobParameters['nomeArquivo']}") String nomeArquivo,
            @Value("${batch.files.input-dir}") String inputDir) {

        BeanWrapperFieldSetMapper<PedidoInput> mapper = new BeanWrapperFieldSetMapper<>();
        mapper.setTargetType(PedidoInput.class);
        mapper.setConversionService(createConversionService());

        return new FlatFileItemReaderBuilder<PedidoInput>()
                .name("pedidoReader")
                .resource(new FileSystemResource(inputDir + "/" + nomeArquivo))
                .delimited().delimiter(",")
                .names("numeroPedido", "clienteEmail", "produtoCodigo", "quantidade", "dataPedido")
                .fieldSetMapper(mapper)
                .linesToSkip(1)
                .build();
    }

    @Bean
    public JdbcBatchItemWriter<Pedido> pedidoWriter(DataSource dataSource) {
        return new JdbcBatchItemWriterBuilder<Pedido>()
                .dataSource(dataSource)
                .sql("""
                    INSERT INTO pedidos
                        (numero_pedido, cliente_email, produto_codigo, quantidade,
                         preco_unitario, total, status, data_pedido)
                    VALUES
                        (:numeroPedido, :clienteEmail, :produtoCodigo, :quantidade,
                         :precoUnitario, :total, :status, :dataPedido)
                    """)
                .beanMapped()
                .build();
    }

    @Bean
    public Step importarPedidosStep(JobRepository jobRepository,
                                     PlatformTransactionManager txManager,
                                     FlatFileItemReader<PedidoInput> pedidoReader,
                                     PedidoImportProcessor processor,
                                     JdbcBatchItemWriter<Pedido> pedidoWriter) {
        return new StepBuilder("importarPedidosStep", jobRepository)
                .<PedidoInput, Pedido>chunk(50, txManager)
                .reader(pedidoReader)
                .processor(processor)
                .writer(pedidoWriter)
                .faultTolerant()
                    .skip(FlatFileParseException.class)
                    .skipLimit(20)
                .build();
    }

    // === STEP 3: PROCESSAR STATUS ===

    @Bean
    public JdbcCursorItemReader<Pedido> pedidoPendenteReader(DataSource dataSource) {
        return new JdbcCursorItemReaderBuilder<Pedido>()
                .name("pedidoPendenteReader")
                .dataSource(dataSource)
                .sql("""
                    SELECT pedido_id, numero_pedido, cliente_email, produto_codigo,
                           quantidade, preco_unitario, total, status
                    FROM pedidos
                    WHERE status = 'PENDENTE'
                    ORDER BY pedido_id
                    """)
                .rowMapper(new BeanPropertyRowMapper<>(Pedido.class))
                .build();
    }

    @Bean
    public JdbcBatchItemWriter<Pedido> pedidoStatusWriter(DataSource dataSource) {
        return new JdbcBatchItemWriterBuilder<Pedido>()
                .dataSource(dataSource)
                .sql("""
                    UPDATE pedidos
                    SET status = :status,
                        observacao = :observacao,
                        data_processo = SYSTIMESTAMP
                    WHERE pedido_id = :pedidoId
                    """)
                .beanMapped()
                .build();
    }

    @Bean
    public Step processarStatusStep(JobRepository jobRepository,
                                     PlatformTransactionManager txManager,
                                     JdbcCursorItemReader<Pedido> pedidoPendenteReader,
                                     PedidoStatusProcessor processor,
                                     JdbcBatchItemWriter<Pedido> pedidoStatusWriter) {
        return new StepBuilder("processarStatusStep", jobRepository)
                .<Pedido, Pedido>chunk(50, txManager)
                .reader(pedidoPendenteReader)
                .processor(processor)
                .writer(pedidoStatusWriter)
                .build();
    }

    // === STEP 4: GERAR RELATÓRIO ===

    @Bean
    public JdbcCursorItemReader<Pedido> pedidoRelatorioReader(DataSource dataSource) {
        return new JdbcCursorItemReaderBuilder<Pedido>()
                .name("pedidoRelatorioReader")
                .dataSource(dataSource)
                .sql("""
                    SELECT numero_pedido, cliente_email, produto_codigo,
                           quantidade, total, status, observacao
                    FROM pedidos
                    ORDER BY status, numero_pedido
                    """)
                .rowMapper(new BeanPropertyRowMapper<>(Pedido.class))
                .build();
    }

    @Bean
    @StepScope
    public FlatFileItemWriter<PedidoRelatorio> relatorioWriter(
            @Value("#{jobParameters['nomeArquivoSaida']}") String nomeArquivo,
            @Value("${batch.files.output-dir}") String outputDir) {

        BeanWrapperFieldExtractor<PedidoRelatorio> extractor = new BeanWrapperFieldExtractor<>();
        extractor.setNames(new String[]{
            "numeroPedido", "clienteEmail", "produtoCodigo", "quantidade", "total", "status", "observacao"
        });

        DelimitedLineAggregator<PedidoRelatorio> aggregator = new DelimitedLineAggregator<>();
        aggregator.setDelimiter(",");
        aggregator.setFieldExtractor(extractor);

        return new FlatFileItemWriterBuilder<PedidoRelatorio>()
                .name("relatorioWriter")
                .resource(new FileSystemResource(outputDir + "/" + nomeArquivo))
                .headerCallback(w -> w.write("numero_pedido,email,produto,quantidade,total,status,observacao"))
                .lineAggregator(aggregator)
                .build();
    }

    @Bean
    public Step gerarRelatorioStep(JobRepository jobRepository,
                                    PlatformTransactionManager txManager,
                                    JdbcCursorItemReader<Pedido> pedidoRelatorioReader,
                                    FlatFileItemWriter<PedidoRelatorio> relatorioWriter) {
        // Processor inline: converte Pedido → PedidoRelatorio
        return new StepBuilder("gerarRelatorioStep", jobRepository)
                .<Pedido, PedidoRelatorio>chunk(100, txManager)
                .reader(pedidoRelatorioReader)
                .processor(pedido -> new PedidoRelatorio(
                    pedido.getNumeroPedido(),
                    pedido.getClienteEmail(),
                    pedido.getProdutoCodigo(),
                    pedido.getQuantidade(),
                    pedido.getTotal(),
                    pedido.getStatus(),
                    pedido.getObservacao() != null ? pedido.getObservacao() : ""
                ))
                .writer(relatorioWriter)
                .build();
    }

    // === JOB PRINCIPAL ===

    @Bean
    public Job processamentoPedidosJob(JobRepository jobRepository,
                                        Step validarArquivoStep,
                                        Step importarPedidosStep,
                                        Step processarStatusStep,
                                        Step gerarRelatorioStep,
                                        PedidoJobListener listener) {
        return new JobBuilder("processamentoPedidosJob", jobRepository)
                .listener(listener)
                .start(validarArquivoStep)
                .next(importarPedidosStep)
                .next(processarStatusStep)
                .next(gerarRelatorioStep)
                .build();
    }

    // Conversion service para LocalDate no CSV
    private org.springframework.core.convert.support.DefaultConversionService createConversionService() {
        var cs = new org.springframework.core.convert.support.DefaultConversionService();
        cs.addConverter(String.class, java.time.LocalDate.class,
            s -> java.time.LocalDate.parse(s.trim(), DateTimeFormatter.ISO_LOCAL_DATE));
        return cs;
    }
}
```

---

## Listener com Resumo Completo

```java
package br.com.javazero.pedidos.listener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobExecutionListener;
import org.springframework.batch.core.StepExecution;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
public class PedidoJobListener implements JobExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(PedidoJobListener.class);

    @Override
    public void beforeJob(JobExecution je) {
        log.info("╔══════════════════════════════════════╗");
        log.info("║  PROCESSAMENTO DE PEDIDOS INICIADO   ║");
        log.info("╚══════════════════════════════════════╝");
        log.info("Arquivo: {}", je.getJobParameters().getString("nomeArquivo"));
        log.info("Saída  : {}", je.getJobParameters().getString("nomeArquivoSaida"));
    }

    @Override
    public void afterJob(JobExecution je) {
        Duration duracao = Duration.between(je.getStartTime(), je.getEndTime());

        log.info("╔══════════════════════════════════════╗");
        log.info("║  PROCESSAMENTO CONCLUÍDO             ║");
        log.info("╠══════════════════════════════════════╣");
        log.info("║  Status  : {}                        ", je.getStatus());
        log.info("║  Duração : {} segundos               ", duracao.getSeconds());
        log.info("╠══════════════════════════════════════╣");

        for (StepExecution se : je.getStepExecutions()) {
            log.info("║  Step: {}", se.getStepName());
            log.info("║    Lidos    : {}", se.getReadCount());
            log.info("║    Escritos : {}", se.getWriteCount());
            log.info("║    Ignorados: {}", se.getFilterCount());
            log.info("║    Pulados  : {}", se.getSkipCount());
        }

        log.info("╚══════════════════════════════════════╝");
    }
}
```

---

## Application + CommandLineRunner

```java
package br.com.javazero.pedidos;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@SpringBootApplication
public class ProcessamentoPedidosApplication {

    public static void main(String[] args) {
        SpringApplication.run(ProcessamentoPedidosApplication.class, args);
    }

    @Bean
    public CommandLineRunner run(JobLauncher jobLauncher, Job processamentoPedidosJob) {
        return args -> {
            String nomeEntrada = args.length > 0 ? args[0] : "pedidos.csv";
            String data = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
            String nomeSaida = "relatorio-pedidos-" + data + ".csv";

            JobParameters params = new JobParametersBuilder()
                    .addString("nomeArquivo", nomeEntrada)
                    .addString("nomeArquivoSaida", nomeSaida)
                    .addLong("timestamp", System.currentTimeMillis())
                    .toJobParameters();

            var resultado = jobLauncher.run(processamentoPedidosJob, params);
            System.exit(resultado.getStatus().isUnsuccessful() ? 1 : 0);
        };
    }
}
```

---

## Como Executar e Testar

```bash
# 1. Preparar ambiente
mkdir -p /tmp/batch/input /tmp/batch/output

# 2. Criar schema no Oracle
sqlplus javazero/senha123@localhost:1521/XEPDB1 @schema.sql

# 3. Copiar arquivo de entrada
cp data/pedidos-exemplo.csv /tmp/batch/input/pedidos.csv

# 4. Compilar
mvn clean package -DskipTests

# 5. Executar
java -jar target/processamento-pedidos-1.0.0.jar pedidos.csv

# 6. Verificar resultados
# Arquivo de saída
cat /tmp/batch/output/relatorio-pedidos-$(date +%Y%m%d).csv

# Banco de dados
sqlplus javazero/senha123@localhost:1521/XEPDB1 <<EOF
SELECT status, COUNT(*) qtd, SUM(total) valor_total
FROM pedidos
GROUP BY status;

SELECT * FROM pedidos ORDER BY numero_pedido;
EOF
```

---

## Saída Esperada

```
╔══════════════════════════════════════╗
║  PROCESSAMENTO DE PEDIDOS INICIADO   ║
╚══════════════════════════════════════╝
Arquivo: pedidos.csv
Saída  : relatorio-pedidos-20260323.csv

--- Iniciando step: validarArquivoStep ---
--- Step finalizado: validarArquivoStep ---

--- Iniciando step: importarPedidosStep ---
WARN  PedidoImportProcessor - Pedido PED-0005 ignorado — email do cliente ausente
WARN  PedidoImportProcessor - Pedido PED-0006 ignorado — quantidade inválida: 0
--- Step finalizado: importarPedidosStep ---
  Lidos    : 7
  Escritos : 5
  Ignorados: 2

--- Iniciando step: processarStatusStep ---
WARN  PedidoStatusProcessor - Pedido PED-0003 — sem estoque para PROD-003
--- Step finalizado: processarStatusStep ---
  Lidos    : 5
  Escritos : 5

--- Iniciando step: gerarRelatorioStep ---
--- Step finalizado: gerarRelatorioStep ---
  Lidos    : 5
  Escritos  : 5

╔══════════════════════════════════════╗
║  PROCESSAMENTO CONCLUÍDO             ║
╠══════════════════════════════════════╣
║  Status  : COMPLETED
║  Duração : 2 segundos
╚══════════════════════════════════════╝
```

---

## Relatório CSV Gerado

```
numero_pedido,email,produto,quantidade,total,status,observacao
PED-0001,ana@email.com,PROD-001,2,59.80,APROVADO,Pedido aprovado e reservado
PED-0002,bruno@email.com,PROD-002,1,99.90,APROVADO,Pedido aprovado e reservado
PED-0003,carla@email.com,PROD-003,5,749.50,SEM_ESTOQUE,Estoque insuficiente: disponível=0, solicitado=5
PED-0004,daniel@email.com,PROD-001,10,299.00,APROVADO,Pedido aprovado e reservado
PED-0007,fabio@email.com,PROD-004,3,59.70,APROVADO,Pedido aprovado e reservado
```

---

## Resumo do Módulo 6

| Conceito | Descrição |
|----------|-----------|
| `Job` | Unidade de processamento batch com Steps |
| `Step` | Unidade de trabalho (Chunk ou Tasklet) |
| `ItemReader` | Lê dados (FlatFile, JdbcCursor, JdbcPaging) |
| `ItemProcessor` | Transforma/valida — null = ignorar registro |
| `ItemWriter` | Persiste dados (JdbcBatch, FlatFile) |
| `Tasklet` | Tarefa simples sem chunk (verificar arquivo, criar diretório) |
| `Chunk` | Lote de N registros com transação própria |
| `faultTolerant()` | Ativa skip e retry |
| `@StepScope` | Bean criado por step — acessa `jobParameters` |
| `JobRepository` | Persiste metadados das execuções no banco |
| `Partitioner` | Divide trabalho para processamento paralelo |

---

## Próximos Passos

Com Spring Batch dominado, você está pronto para:

- **Módulo 7 — Testes**: JUnit 5, Mockito, Spring Boot Test, `@SpringBatchTest`
- **Módulo 8 — Segurança**: Spring Security, JWT, OAuth2
- **Módulo 9 — Mensageria**: RabbitMQ ou Kafka para processar mensagens em batch
- **Módulo 10 — Cloud**: Deploy no Kubernetes, Spring Cloud

## Exercícios Finais do Módulo

### Básico
1. Execute o projeto com o arquivo de exemplo e verifique o relatório gerado
2. Adicione mais 5 pedidos ao CSV (incluindo casos de erro) e reexecute
3. Consulte o histórico de execuções nas tabelas `BATCH_JOB_EXECUTION` e `BATCH_STEP_EXECUTION`

### Intermediário
4. Adicione um 5º step que envia um email (simulado com log) resumindo os resultados
5. Implemente um `SkipListener` que salva pedidos rejeitados em arquivo `pedidos-rejeitados.csv`
6. Configure `@Scheduled` para executar o job diariamente às 6h da manhã

### Avançado
7. Use `EstadoPartitioner` do módulo anterior para processar pedidos por região em paralelo
8. Adicione um endpoint REST `/batch/pedidos/executar` que recebe o nome do arquivo e dispara o job
9. Implemente monitoramento: salve métricas de cada execução em tabela `metricas_batch` e crie uma query de relatório mensal de performance
