# 02 — Conceitos Fundamentais do Spring Batch

## Revisão do Tópico Anterior
Arquitetura Spring Batch: Job, Step, JobRepository, JobLauncher, dependências, `application.yml`.

---

## Chunk-Oriented Processing

O coração do Spring Batch é o processamento em chunks:

```
Para cada chunk de N registros:
  ┌───────────────────────────────────────┐
  │  Iniciar transação                     │
  │  Repeat N times:                       │
  │    ItemReader.read()  → 1 registro     │
  │    ItemProcessor.process() → transforma│
  │  ItemWriter.write(lista de N itens)    │
  │  Commit ou Rollback                    │
  └───────────────────────────────────────┘
```

Com chunk-size=3 e 10 registros:
```
Chunk 1: lê 1,2,3 → processa → escreve [1,2,3] → COMMIT
Chunk 2: lê 4,5,6 → processa → escreve [4,5,6] → COMMIT
Chunk 3: lê 7,8,9 → processa → escreve [7,8,9] → COMMIT
Chunk 4: lê 10    → processa → escreve [10]    → COMMIT
```

---

## ItemReader

```java
// FlatFileItemReader — lê CSV
@Bean
@StepScope
public FlatFileItemReader<ClienteInput> clienteReader(
        @Value("#{jobParameters['nomeArquivo']}") String nomeArquivo,
        @Value("${batch.files.input-dir}") String inputDir) {

    return new FlatFileItemReaderBuilder<ClienteInput>()
            .name("clienteReader")
            .resource(new FileSystemResource(inputDir + "/" + nomeArquivo))
            .delimited()
            .delimiter(",")
            .names("nome", "email", "cpf", "telefone")
            .targetType(ClienteInput.class)
            .linesToSkip(1)  // pular cabeçalho
            .build();
}

// JdbcCursorItemReader — lê banco
@Bean
public JdbcCursorItemReader<Cliente> clienteDbReader(DataSource dataSource) {
    return new JdbcCursorItemReaderBuilder<Cliente>()
            .name("clienteDbReader")
            .dataSource(dataSource)
            .sql("SELECT id, nome, email, cpf, telefone, ativo FROM clientes WHERE ativo = 1 ORDER BY id")
            .rowMapper(new BeanPropertyRowMapper<>(Cliente.class))
            .build();
}
```

## ItemProcessor

```java
@Component
public class ClienteImportProcessor implements ItemProcessor<ClienteInput, Cliente> {

    private static final Logger log = LoggerFactory.getLogger(ClienteImportProcessor.class);

    @Override
    public Cliente process(ClienteInput input) throws Exception {
        // null = pular este registro (não vai para o Writer)
        if (input.getNome() == null || input.getNome().isBlank()) {
            log.warn("Registro ignorado (nome vazio): {}", input);
            return null;
        }
        if (input.getEmail() == null || !input.getEmail().contains("@")) {
            log.warn("Registro ignorado (email inválido): {}", input);
            return null;
        }

        Cliente c = new Cliente();
        c.setNome(input.getNome().trim());
        c.setEmail(input.getEmail().trim().toLowerCase());
        c.setCpf(input.getCpf() != null ? input.getCpf().trim() : null);
        c.setTelefone(input.getTelefone() != null ? input.getTelefone().trim() : null);
        return c;
    }
}
```

## ItemWriter

```java
// Escrita no banco
@Bean
public JdbcBatchItemWriter<Cliente> clienteDbWriter(DataSource dataSource) {
    return new JdbcBatchItemWriterBuilder<Cliente>()
            .dataSource(dataSource)
            .sql("INSERT INTO clientes (nome, email, cpf, telefone) VALUES (:nome, :email, :cpf, :telefone)")
            .beanMapped()
            .build();
}

// Escrita em arquivo CSV
@Bean
@StepScope
public FlatFileItemWriter<Cliente> clienteFileWriter(
        @Value("#{jobParameters['nomeArquivoSaida']}") String nomeArquivo,
        @Value("${batch.files.output-dir}") String outputDir) {

    BeanWrapperFieldExtractor<Cliente> extractor = new BeanWrapperFieldExtractor<>();
    extractor.setNames(new String[]{"id", "nome", "email", "cpf", "telefone"});

    DelimitedLineAggregator<Cliente> aggregator = new DelimitedLineAggregator<>();
    aggregator.setDelimiter(",");
    aggregator.setFieldExtractor(extractor);

    return new FlatFileItemWriterBuilder<Cliente>()
            .name("clienteFileWriter")
            .resource(new FileSystemResource(outputDir + "/" + nomeArquivo))
            .headerCallback(w -> w.write("id,nome,email,cpf,telefone"))
            .lineAggregator(aggregator)
            .build();
}
```

## Tasklet — Tarefas Simples

```java
@Component
public class CriarDiretoriosTasklet implements Tasklet {

    @Value("${batch.files.input-dir}")
    private String inputDir;

    @Value("${batch.files.output-dir}")
    private String outputDir;

    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) {
        new java.io.File(inputDir).mkdirs();
        new java.io.File(outputDir).mkdirs();
        return RepeatStatus.FINISHED;
    }
}
```

## Listeners

```java
@Component
public class JobResultListener implements JobExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(JobResultListener.class);

    @Override
    public void beforeJob(JobExecution jobExecution) {
        log.info("Iniciando job: {}", jobExecution.getJobInstance().getJobName());
    }

    @Override
    public void afterJob(JobExecution jobExecution) {
        log.info("Job finalizado: {} — status: {}",
                jobExecution.getJobInstance().getJobName(),
                jobExecution.getStatus());
    }
}

@Component
public class StepResultListener implements StepExecutionListener {

    private static final Logger log = LoggerFactory.getLogger(StepResultListener.class);

    @Override
    public ExitStatus afterStep(StepExecution stepExecution) {
        log.info("Step: {} | Lidos: {} | Escritos: {} | Ignorados: {} | Erros: {}",
                stepExecution.getStepName(),
                stepExecution.getReadCount(),
                stepExecution.getWriteCount(),
                stepExecution.getFilterCount(),
                stepExecution.getSkipCount());
        return stepExecution.getExitStatus();
    }
}
```

---

## Configurando Step e Job

```java
// Step com chunk processing
@Bean
public Step importarClientesStep(
        JobRepository jobRepository,
        PlatformTransactionManager txManager,
        FlatFileItemReader<ClienteInput> reader,
        ClienteImportProcessor processor,
        JdbcBatchItemWriter<Cliente> writer,
        StepResultListener listener) {

    return new StepBuilder("importarClientesStep", jobRepository)
            .<ClienteInput, Cliente>chunk(100, txManager)
            .reader(reader)
            .processor(processor)
            .writer(writer)
            .listener(listener)
            .faultTolerant()
                .skip(Exception.class)
                .skipLimit(10)
            .build();
}

// Job com múltiplos steps
@Bean
public Job importacaoJob(
        JobRepository jobRepository,
        Step prepararAmbienteStep,
        Step importarClientesStep,
        JobResultListener listener) {

    return new JobBuilder("importacaoJob", jobRepository)
            .listener(listener)
            .start(prepararAmbienteStep)
            .next(importarClientesStep)
            .build();
}
```

---

## Exercícios

### Básico
1. Configure um `FlatFileItemReader` para um arquivo com separador `;` e campos `codigo`, `nome`, `valor`
2. Escreva um `ItemProcessor` que rejeita (retorna null) registros com valor negativo
3. Configure um `JdbcBatchItemWriter` para inserir produtos na tabela `produtos`

### Intermediário
4. Adicione um `JobExecutionListener` que registra o tempo total de execução
5. Configure `faultTolerant()` com skip de `FlatFileParseException` e `skipLimit(50)`
6. Implemente um `Tasklet` que verifica se o arquivo de entrada existe e lança exceção se não

### Avançado
7. Configure `CompositeItemProcessor` encadeando dois processors: validação e transformação
8. Implemente `ItemWriteListener` que registra em log todos os itens escritos com sucesso
9. Configure retry: 3 tentativas em caso de `DeadlockLoserDataAccessException`
