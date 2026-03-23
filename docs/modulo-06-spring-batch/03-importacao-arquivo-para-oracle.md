# 03 — Importação de Arquivo CSV para Oracle

## Revisão do Tópico Anterior
Chunk-oriented processing, ItemReader (FlatFile/Jdbc), ItemProcessor, ItemWriter, Tasklet, Listeners, configuração de Step e Job.

---

## Visão Geral do Projeto

Projeto completo: importar arquivo CSV de clientes para o banco Oracle.

```
clientes.csv
    ↓
FlatFileItemReader  →  ClienteProcessor  →  JdbcBatchItemWriter
    (lê CSV)              (valida/transforma)      (insere no Oracle)
```

---

## Estrutura do Projeto

```
importacao-clientes/
├── pom.xml
├── src/main/
│   ├── java/br/com/javazero/batch/
│   │   ├── ImportacaoApplication.java
│   │   ├── config/
│   │   │   └── ImportacaoJobConfig.java
│   │   ├── model/
│   │   │   ├── ClienteInput.java
│   │   │   └── Cliente.java
│   │   ├── processor/
│   │   │   └── ClienteImportProcessor.java
│   │   ├── tasklet/
│   │   │   └── ValidarArquivoTasklet.java
│   │   └── listener/
│   │       ├── JobImportacaoListener.java
│   │       └── StepImportacaoListener.java
│   └── resources/
│       └── application.yml
└── data/
    └── clientes-exemplo.csv
```

---

## pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>br.com.javazero</groupId>
    <artifactId>importacao-clientes</artifactId>
    <version>1.0.0</version>
    <name>importacao-clientes</name>

    <properties>
        <java.version>21</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-batch</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>com.oracle.database.jdbc</groupId>
            <artifactId>ojdbc11</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.batch</groupId>
            <artifactId>spring-batch-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## application.yml

```yaml
spring:
  datasource:
    url: jdbc:oracle:thin:@localhost:1521/XEPDB1
    username: javazero
    password: senha123
    driver-class-name: oracle.jdbc.OracleDriver
    hikari:
      maximum-pool-size: 5
      connection-timeout: 30000

  batch:
    jdbc:
      initialize-schema: always  # cria tabelas de metadados do Batch
    job:
      enabled: false  # não executa job automaticamente na inicialização

  jpa:
    show-sql: false
    hibernate:
      ddl-auto: none

batch:
  files:
    input-dir: /tmp/batch/input
    output-dir: /tmp/batch/output

logging:
  level:
    br.com.javazero: DEBUG
    org.springframework.batch: INFO
```

---

## Modelos

```java
// ClienteInput.java — representa uma linha do CSV
package br.com.javazero.batch.model;

public class ClienteInput {
    private String nome;
    private String email;
    private String cpf;
    private String telefone;
    private String cidade;
    private String estado;

    // Getters e Setters
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getCpf() { return cpf; }
    public void setCpf(String cpf) { this.cpf = cpf; }
    public String getTelefone() { return telefone; }
    public void setTelefone(String telefone) { this.telefone = telefone; }
    public String getCidade() { return cidade; }
    public void setCidade(String cidade) { this.cidade = cidade; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    @Override
    public String toString() {
        return "ClienteInput{nome='" + nome + "', email='" + email + "'}";
    }
}

// Cliente.java — entidade que vai para o banco
package br.com.javazero.batch.model;

public class Cliente {
    private String nome;
    private String email;
    private String cpf;
    private String telefone;
    private String cidade;
    private String estado;

    // Getters e Setters
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getCpf() { return cpf; }
    public void setCpf(String cpf) { this.cpf = cpf; }
    public String getTelefone() { return telefone; }
    public void setTelefone(String telefone) { this.telefone = telefone; }
    public String getCidade() { return cidade; }
    public void setCidade(String cidade) { this.cidade = cidade; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}
```

---

## Processor

```java
package br.com.javazero.batch.processor;

import br.com.javazero.batch.model.Cliente;
import br.com.javazero.batch.model.ClienteInput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.stereotype.Component;

@Component
public class ClienteImportProcessor implements ItemProcessor<ClienteInput, Cliente> {

    private static final Logger log = LoggerFactory.getLogger(ClienteImportProcessor.class);

    @Override
    public Cliente process(ClienteInput input) throws Exception {
        // retornar null = pular registro (será contado como filtered)
        if (input.getNome() == null || input.getNome().isBlank()) {
            log.warn("Registro ignorado — nome vazio: {}", input);
            return null;
        }
        if (input.getEmail() == null || !input.getEmail().contains("@")) {
            log.warn("Registro ignorado — email inválido: {}", input);
            return null;
        }
        if (input.getEstado() != null && input.getEstado().trim().length() != 2) {
            log.warn("Registro ignorado — estado inválido: {}", input.getEstado());
            return null;
        }

        Cliente cliente = new Cliente();
        cliente.setNome(input.getNome().trim());
        cliente.setEmail(input.getEmail().trim().toLowerCase());
        cliente.setCpf(input.getCpf() != null ? input.getCpf().trim() : null);
        cliente.setTelefone(input.getTelefone() != null ? input.getTelefone().trim() : null);
        cliente.setCidade(input.getCidade() != null ? input.getCidade().trim() : null);
        cliente.setEstado(input.getEstado() != null ? input.getEstado().trim().toUpperCase() : null);

        return cliente;
    }
}
```

---

## Tasklet — Validar Arquivo

```java
package br.com.javazero.batch.tasklet;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.File;

@Component
public class ValidarArquivoTasklet implements Tasklet {

    private static final Logger log = LoggerFactory.getLogger(ValidarArquivoTasklet.class);

    @Value("${batch.files.input-dir}")
    private String inputDir;

    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) {
        // Recuperar nome do arquivo dos jobParameters
        String nomeArquivo = (String) chunkContext
                .getStepContext()
                .getJobParameters()
                .get("nomeArquivo");

        File arquivo = new File(inputDir + "/" + nomeArquivo);

        if (!arquivo.exists()) {
            throw new IllegalStateException(
                "Arquivo de entrada não encontrado: " + arquivo.getAbsolutePath());
        }
        if (!arquivo.canRead()) {
            throw new IllegalStateException(
                "Arquivo sem permissão de leitura: " + arquivo.getAbsolutePath());
        }
        if (arquivo.length() == 0) {
            throw new IllegalStateException(
                "Arquivo vazio: " + arquivo.getAbsolutePath());
        }

        log.info("Arquivo validado: {} ({} bytes)", arquivo.getName(), arquivo.length());

        // Criar diretório de saída se não existir
        new File(inputDir.replace("input", "output")).mkdirs();

        return RepeatStatus.FINISHED;
    }
}
```

---

## Listeners

```java
// JobImportacaoListener.java
package br.com.javazero.batch.listener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobExecutionListener;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
public class JobImportacaoListener implements JobExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(JobImportacaoListener.class);

    @Override
    public void beforeJob(JobExecution jobExecution) {
        log.info("=== INICIANDO JOB: {} ===", jobExecution.getJobInstance().getJobName());
        log.info("Parâmetros: {}", jobExecution.getJobParameters());
    }

    @Override
    public void afterJob(JobExecution jobExecution) {
        Duration duracao = Duration.between(
            jobExecution.getStartTime(),
            jobExecution.getEndTime()
        );
        log.info("=== JOB FINALIZADO: {} ===", jobExecution.getJobInstance().getJobName());
        log.info("Status: {}", jobExecution.getStatus());
        log.info("Duração: {} segundos", duracao.getSeconds());

        if (jobExecution.getAllFailureExceptions().size() > 0) {
            log.error("Exceções ocorridas:");
            jobExecution.getAllFailureExceptions()
                .forEach(e -> log.error("  - {}", e.getMessage()));
        }
    }
}

// StepImportacaoListener.java
package br.com.javazero.batch.listener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.ExitStatus;
import org.springframework.batch.core.StepExecution;
import org.springframework.batch.core.StepExecutionListener;
import org.springframework.stereotype.Component;

@Component
public class StepImportacaoListener implements StepExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(StepImportacaoListener.class);

    @Override
    public void beforeStep(StepExecution stepExecution) {
        log.info("--- Iniciando step: {} ---", stepExecution.getStepName());
    }

    @Override
    public ExitStatus afterStep(StepExecution stepExecution) {
        log.info("--- Step finalizado: {} ---", stepExecution.getStepName());
        log.info("  Lidos    : {}", stepExecution.getReadCount());
        log.info("  Escritos : {}", stepExecution.getWriteCount());
        log.info("  Ignorados: {}", stepExecution.getFilterCount());
        log.info("  Pulados  : {}", stepExecution.getSkipCount());
        log.info("  Erros    : {}", stepExecution.getReadSkipCount() + stepExecution.getWriteSkipCount());
        return stepExecution.getExitStatus();
    }
}
```

---

## Configuração do Job

```java
package br.com.javazero.batch.config;

import br.com.javazero.batch.listener.JobImportacaoListener;
import br.com.javazero.batch.listener.StepImportacaoListener;
import br.com.javazero.batch.model.Cliente;
import br.com.javazero.batch.model.ClienteInput;
import br.com.javazero.batch.processor.ClienteImportProcessor;
import br.com.javazero.batch.tasklet.ValidarArquivoTasklet;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.database.JdbcBatchItemWriter;
import org.springframework.batch.item.database.builder.JdbcBatchItemWriterBuilder;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.FlatFileParseException;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;
import org.springframework.transaction.PlatformTransactionManager;

import javax.sql.DataSource;

@Configuration
public class ImportacaoJobConfig {

    // =========================================================
    // READER
    // =========================================================
    @Bean
    @org.springframework.batch.core.configuration.annotation.StepScope
    public FlatFileItemReader<ClienteInput> clienteReader(
            @Value("#{jobParameters['nomeArquivo']}") String nomeArquivo,
            @Value("${batch.files.input-dir}") String inputDir) {

        return new FlatFileItemReaderBuilder<ClienteInput>()
                .name("clienteReader")
                .resource(new FileSystemResource(inputDir + "/" + nomeArquivo))
                .delimited()
                .delimiter(",")
                .names("nome", "email", "cpf", "telefone", "cidade", "estado")
                .targetType(ClienteInput.class)
                .linesToSkip(1)          // pular linha de cabeçalho
                .strict(true)            // lança exceção se arquivo não encontrado
                .build();
    }

    // =========================================================
    // WRITER
    // =========================================================
    @Bean
    public JdbcBatchItemWriter<Cliente> clienteWriter(DataSource dataSource) {
        return new JdbcBatchItemWriterBuilder<Cliente>()
                .dataSource(dataSource)
                .sql("""
                    INSERT INTO clientes (nome, email, cpf, telefone, cidade, estado)
                    VALUES (:nome, :email, :cpf, :telefone, :cidade, :estado)
                    """)
                .beanMapped()  // usa getters do objeto para os named parameters
                .build();
    }

    // =========================================================
    // STEPS
    // =========================================================
    @Bean
    public Step validarArquivoStep(
            JobRepository jobRepository,
            PlatformTransactionManager txManager,
            ValidarArquivoTasklet tasklet,
            StepImportacaoListener listener) {

        return new StepBuilder("validarArquivoStep", jobRepository)
                .tasklet(tasklet, txManager)
                .listener(listener)
                .build();
    }

    @Bean
    public Step importarClientesStep(
            JobRepository jobRepository,
            PlatformTransactionManager txManager,
            FlatFileItemReader<ClienteInput> reader,
            ClienteImportProcessor processor,
            JdbcBatchItemWriter<Cliente> writer,
            StepImportacaoListener listener) {

        return new StepBuilder("importarClientesStep", jobRepository)
                .<ClienteInput, Cliente>chunk(100, txManager)   // processa 100 por vez
                .reader(reader)
                .processor(processor)
                .writer(writer)
                .listener(listener)
                .faultTolerant()
                    .skip(FlatFileParseException.class)          // pula linha malformada
                    .skipLimit(50)                               // máximo 50 linhas puladas
                    .retryLimit(3)                               // 3 tentativas em erros transitórios
                    .retry(org.springframework.dao.DeadlockLoserDataAccessException.class)
                .build();
    }

    // =========================================================
    // JOB
    // =========================================================
    @Bean
    public Job importacaoClientesJob(
            JobRepository jobRepository,
            Step validarArquivoStep,
            Step importarClientesStep,
            JobImportacaoListener listener) {

        return new JobBuilder("importacaoClientesJob", jobRepository)
                .listener(listener)
                .start(validarArquivoStep)       // 1. valida o arquivo
                .next(importarClientesStep)      // 2. importa os dados
                .build();
    }
}
```

---

## Application

```java
package br.com.javazero.batch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class ImportacaoApplication {

    public static void main(String[] args) {
        SpringApplication.run(ImportacaoApplication.class, args);
    }

    @Bean
    public CommandLineRunner executarJob(JobLauncher jobLauncher, Job importacaoClientesJob) {
        return args -> {
            // Parâmetro obrigatório: nome do arquivo CSV
            String nomeArquivo = args.length > 0 ? args[0] : "clientes.csv";

            JobParameters params = new JobParametersBuilder()
                    .addString("nomeArquivo", nomeArquivo)
                    .addLong("timestamp", System.currentTimeMillis())  // garante unicidade
                    .toJobParameters();

            var resultado = jobLauncher.run(importacaoClientesJob, params);
            System.out.println("Job finalizado com status: " + resultado.getStatus());
        };
    }
}
```

---

## Script SQL — Tabela no Oracle

```sql
-- Criar tabela de destino
CREATE SEQUENCE seq_clientes START WITH 1 INCREMENT BY 1;

CREATE TABLE clientes (
    cliente_id  NUMBER        DEFAULT seq_clientes.NEXTVAL PRIMARY KEY,
    nome        VARCHAR2(150) NOT NULL,
    email       VARCHAR2(200) NOT NULL UNIQUE,
    cpf         VARCHAR2(14)  UNIQUE,
    telefone    VARCHAR2(20),
    cidade      VARCHAR2(100),
    estado      CHAR(2),
    ativo       NUMBER(1)     DEFAULT 1 NOT NULL,
    data_import TIMESTAMP     DEFAULT SYSTIMESTAMP
);

-- Verificar importação
SELECT COUNT(*) total, estado
FROM clientes
GROUP BY estado
ORDER BY total DESC;
```

---

## Arquivo CSV de Exemplo

```
nome,email,cpf,telefone,cidade,estado
Ana Lima,ana.lima@email.com,111.111.111-11,(11) 99999-1111,São Paulo,SP
Bruno Costa,bruno.costa@email.com,222.222.222-22,(21) 99999-2222,Rio de Janeiro,RJ
Carla Dias,carla.dias@email.com,333.333.333-33,(31) 99999-3333,Belo Horizonte,MG
,email.sem.nome@test.com,,,,
nome.sem.email,,,,Curitiba,PR
Daniel Souza,daniel@email.com,444.444.444-44,(41) 99999-4444,Curitiba,PR
```

A linha 4 (sem nome) e linha 5 (sem email) serão ignoradas pelo processor.

---

## Como Executar

```bash
# 1. Criar diretório de entrada
mkdir -p /tmp/batch/input

# 2. Copiar o CSV
cp clientes-exemplo.csv /tmp/batch/input/clientes.csv

# 3. Compilar e executar passando o nome do arquivo
mvn clean package -DskipTests

java -jar target/importacao-clientes-1.0.0.jar clientes.csv

# 4. Verificar no Oracle
sqlplus javazero/senha123@localhost:1521/XEPDB1
SQL> SELECT * FROM clientes;
SQL> SELECT COUNT(*) FROM clientes;
```

---

## Executar via API REST (JobLauncher via REST)

Alternativa: expor endpoint HTTP para disparar o job:

```java
@RestController
@RequestMapping("/batch")
public class BatchController {

    private final JobLauncher jobLauncher;
    private final Job importacaoClientesJob;

    public BatchController(JobLauncher jobLauncher, Job importacaoClientesJob) {
        this.jobLauncher = jobLauncher;
        this.importacaoClientesJob = importacaoClientesJob;
    }

    @PostMapping("/importar")
    public ResponseEntity<String> importar(@RequestParam String nomeArquivo) throws Exception {
        JobParameters params = new JobParametersBuilder()
                .addString("nomeArquivo", nomeArquivo)
                .addLong("timestamp", System.currentTimeMillis())
                .toJobParameters();

        var exec = jobLauncher.run(importacaoClientesJob, params);
        return ResponseEntity.ok("Job executado. Status: " + exec.getStatus());
    }
}
```

```bash
# Disparar o job via curl
curl -X POST "http://localhost:8080/batch/importar?nomeArquivo=clientes.csv"
```

---

## Consultar Execuções no Banco

```sql
-- Histórico de execuções do job
SELECT ji.job_name,
       je.status,
       je.start_time,
       je.end_time,
       ROUND((CAST(je.end_time AS DATE) - CAST(je.start_time AS DATE)) * 86400) AS duracao_seg
FROM batch_job_execution je
JOIN batch_job_instance ji ON je.job_instance_id = ji.job_instance_id
ORDER BY je.start_time DESC;

-- Contadores por step
SELECT step_name,
       read_count,
       write_count,
       filter_count,
       skip_count,
       status
FROM batch_step_execution
WHERE job_execution_id = :executionId;
```

---

## Exercícios

### Básico
1. Altere o separador do CSV de `,` para `;` e atualize o `FlatFileItemReader`
2. Adicione validação no processor: rejeitar clientes com `estado` diferente de SP, RJ, MG
3. Execute o job duas vezes com o mesmo arquivo — observe o erro de "job already completed"

### Intermediário
4. Adicione um `ItemReadListener` que registra em log cada linha lida com sucesso
5. Configure o `skipLimit` para 0 (zero tolerância a erros) e teste com CSV malformado
6. Implemente um terceiro step após a importação que conta os registros inseridos e registra no log

### Avançado
7. Use `JobParametersIncrementer` para permitir reexecutar o job com mesmo arquivo
8. Implemente `ItemWriteListener` que salva em tabela de log cada cliente inserido
9. Configure `MultiResourceItemReader` para processar múltiplos arquivos CSV de uma vez
