# Módulo 6 — Spring Batch
# Tópico 1: Introdução ao Spring Batch

---

## Revisão dos Módulos Anteriores

Até aqui você aprendeu:

- **Módulo 1**: Java OO — classes, herança, interfaces, coleções, streams
- **Módulo 2**: Banco de dados — SQL DDL/DML, Oracle, modelagem relacional
- **Módulo 3**: JDBC — conectar Java ao Oracle, `Connection`, `PreparedStatement`, `ResultSet`
- **Módulo 4**: REST API — HTTP, JSON, controllers Spring MVC, status codes
- **Módulo 5**: Spring Boot — auto-configuração, Spring Data JPA, `application.yml`, testes

Agora vamos aprender **processamento em lote (batch)**, um dos pilares da computação empresarial.

---

## O que é Processamento em Lote (Batch)?

### Processamento Online vs. Batch

No dia a dia de uma aplicação existem dois modos fundamentais de processamento:

**Processamento Online (transacional)**:
- O usuário realiza uma ação e o sistema responde imediatamente
- Exemplos: salvar um cadastro, consultar saldo, fazer um pedido
- Característica: baixo volume, alta interatividade, tempo de resposta curto (milissegundos)

**Processamento Batch**:
- O sistema processa grandes volumes de dados de forma automática
- Sem interação humana durante a execução
- Geralmente executado fora do horário de pico (madrugada, fim de semana)
- Característica: alto volume, sem interatividade, tempo de execução pode ser longo (horas)

### Analogia do mundo real

Pense em um restaurante:
- **Online**: garçom anota o pedido e cozinheiro prepara imediatamente (1 prato por vez)
- **Batch**: padaria que prepara 500 pães de uma vez às 4h da manhã, prontos para venda às 7h

### Casos de Uso Reais no Mercado

| Setor | Processo Batch | Volume Típico |
|-------|---------------|---------------|
| Banco | Processar extratos de conta toda madrugada | 10 milhões de contas |
| E-commerce | Calcular comissões de vendedores no fim do mês | 500 mil pedidos |
| Governo | Processar declarações de Imposto de Renda | 30 milhões de declarações |
| Saúde | Gerar cobranças mensais para beneficiários | 500 mil contratos |
| RH | Processar folha de pagamento | 50 mil funcionários |
| Logística | Calcular rotas de entrega para o dia seguinte | 200 mil pacotes |
| Telecomunicações | Processar CDR (registros de chamadas) para faturamento | 100 milhões de registros/dia |
| Banco central | Liquidação de títulos do Tesouro | Trilhões de reais em operações |

**Nosso cenário neste módulo**:
1. **Job de Importação**: ler arquivo `clientes.csv` do filesystem local → gravar no Oracle
2. **Job de Exportação**: ler clientes do Oracle → gerar arquivo `clientes-exportados.csv`

---

### Características de um Processamento Batch de Qualidade

Para que um job batch seja confiável em produção, ele deve ter:

1. **Alto volume**: capaz de processar milhões de registros sem travar
2. **Sem interação**: executa sem nenhum humano presente
3. **Janela de tempo**: precisa terminar antes do horário de pico começar
4. **Resiliência**: se falhar no meio, pode ser reiniciado do ponto onde parou (não reprocessa o que já foi feito)
5. **Rastreabilidade**: registra quantos registros foram lidos, processados, com erro, ignorados
6. **Idempotência**: processar o mesmo arquivo duas vezes não deve causar dados duplicados

---

## O que é Spring Batch?

Spring Batch é o framework Java padrão para processamento em lote. Faz parte do ecossistema Spring e implementa as melhores práticas de batch definidas na especificação JSR-352.

**O que ele gerencia por você**:
- Execução de jobs com rastreamento completo
- Retomada após falha (restart do ponto onde parou)
- Retry automático em caso de erros transientes
- Skip de registros inválidos sem parar o job inteiro
- Paralelismo (múltiplos threads ou partições)
- Histórico de execuções persistido no banco

### Spring Batch vs. @Scheduled

Uma pergunta comum: "por que não usar apenas `@Scheduled` com um loop?"

```java
// Abordagem INGÊNUA com @Scheduled — NÃO faça isso para alto volume:
@Scheduled(cron = "0 0 2 * * *")  // todo dia às 2h
public void processarClientes() {
    List<Cliente> clientes = repository.findAll();  // PROBLEMA: carrega TUDO na memória!
    for (Cliente c : clientes) {
        processar(c);  // sem retry, sem rastreamento, sem restart
    }
}
```

**Problemas do @Scheduled simples**:
- Carrega todos os registros na memória de uma vez (OutOfMemoryError com milhões)
- Se falhar na metade, começa do zero na próxima vez (reprocessa tudo)
- Sem histórico: não sabe se terminou com sucesso
- Sem retry: um erro transiente cancela tudo
- Sem paralelismo

**Spring Batch resolve todos esses problemas** com uma arquitetura testada em produção por grandes empresas.

---

## Arquitetura do Spring Batch

```
┌─────────────────────────────────────────────────────────────┐
│                       JOB LAUNCHER                          │
│    (ponto de entrada — dispara a execução do job)           │
│    Pode ser: HTTP endpoint, linha de comando, @Scheduled    │
└──────────────────────────┬──────────────────────────────────┘
                           │  run(job, params)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                          JOB                                │
│      (unidade de trabalho completa — ex: ImportacaoJob)     │
│                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│   │   Step 1    │───▶│   Step 2    │───▶│   Step 3    │    │
│   │ (Tasklet)   │    │  (Chunk)    │    │  (Tasklet)  │    │
│   │Cria direts. │    │Importa CSV  │    │ Move arquivo│    │
│   └─────────────┘    └─────────────┘    └─────────────┘    │
└──────────────────────────┬──────────────────────────────────┘
                           │  persiste metadados
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      JOB REPOSITORY                         │
│    (persiste o estado de execução no banco de dados)        │
│    Tabelas: BATCH_JOB_INSTANCE, BATCH_JOB_EXECUTION,        │
│             BATCH_STEP_EXECUTION, ...                       │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo dentro de um Step Chunk-Oriented

```
┌──────────────────────────────────────────────────────────────┐
│  STEP (Chunk-Oriented)                                       │
│                                                              │
│  Abre transação                                              │
│  ┌──────────┐      ┌───────────────┐      ┌──────────────┐  │
│  │  READER  │─────▶│  PROCESSOR    │─────▶│   WRITER     │  │
│  │          │      │               │      │              │  │
│  │ Lê 1     │      │ Valida/trans- │      │ Escreve N    │  │
│  │ registro │      │ forma 1 item  │      │ itens de vez │  │
│  │ por vez  │      │ (pode descar- │      │ (batch SQL)  │  │
│  │          │      │  tar com null)│      │              │  │
│  └──────────┘      └───────────────┘      └──────────────┘  │
│  Repete N vezes (chunk-size)                                 │
│  Faz COMMIT                                                  │
│  Repete até Reader retornar null                             │
└──────────────────────────────────────────────────────────────┘
```

---

## Componentes Principais em Detalhe

### Job

- Representa um processo batch completo
- É composto por um ou mais **Steps** executados em sequência (ou condicionalmente)
- Identificado por um nome único (String)
- **JobParameters**: parâmetros que identificam uma execução específica

```java
// Exemplo de Job com dois Steps:
Job importacaoJob = jobBuilder
    .start(criarDiretoriosStep)   // Step 1: preparação
    .next(importarClientesStep)   // Step 2: processamento
    .build();
```

### JobInstance

- Representa uma execução **lógica** de um Job com parâmetros específicos
- `ImportacaoJob + data=2026-03-22` = uma JobInstance
- `ImportacaoJob + data=2026-03-23` = outra JobInstance (diferente!)
- Uma JobInstance **não pode ser executada novamente** se já completou com sucesso

### JobExecution

- Representa uma **tentativa real** de executar uma JobInstance
- Se o job falhar e você reiniciar: nova **JobExecution**, mesma **JobInstance**
- Contém: status (STARTED, COMPLETED, FAILED), início, fim, erros

```
JobInstance: ImportacaoJob + data=2026-03-22
  └── JobExecution #1: FAILED  (às 02:01 — arquivo corrompido)
  └── JobExecution #2: COMPLETED (às 02:15 — arquivo corrigido e reprocessado)
```

### Step

- Uma fase de processamento dentro de um Job
- Dois tipos:
  - **Tasklet**: executa uma tarefa simples (criar diretório, limpar tabela, mover arquivo)
  - **Chunk-oriented**: lê/processa/escreve dados em lotes (o tipo mais usado)

### StepExecution

- Análogo ao JobExecution mas para Steps
- Contém contadores: `readCount`, `writeCount`, `filterCount`, `skipCount`, `commitCount`
- Esses dados ficam salvos na tabela `BATCH_STEP_EXECUTION`

### JobRepository

- O "banco de dados" do Spring Batch
- Persiste todos os metadados: jobs, execuções, steps, parâmetros
- Permite: restart (saber onde parou), rastreamento, auditoria
- Usa tabelas no banco relacional (Oracle, no nosso caso)

### JobLauncher

- Responsável por iniciar um Job com seus parâmetros
- Retorna um `JobExecution` com o resultado

```java
// Exemplo de uso do JobLauncher:
JobParameters params = new JobParametersBuilder()
    .addLocalDate("data", LocalDate.now())
    .toJobParameters();

JobExecution execution = jobLauncher.run(importacaoJob, params);
System.out.println("Status: " + execution.getStatus());
```

---

## Dependências Maven

Adicione ao seu `pom.xml`:

```xml
<dependencies>
    <!-- Spring Batch — framework principal -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-batch</artifactId>
    </dependency>

    <!-- Spring Data JPA — para entidades e repositórios -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <!-- Oracle JDBC driver -->
    <dependency>
        <groupId>com.oracle.database.jdbc</groupId>
        <artifactId>ojdbc11</artifactId>
        <version>23.3.0.23.09</version>
    </dependency>

    <!-- Spring Web — para expor endpoints REST de disparo de jobs -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- Lombok — para reduzir código boilerplate -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

    <!-- Testes -->
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
```

---

## Configuração do Banco de Metadados

O Spring Batch precisa de tabelas próprias no banco para registrar execuções. Com Oracle, configure assim:

```yaml
# src/main/resources/application.yml
spring:
  datasource:
    url: jdbc:oracle:thin:@localhost:1521/FREEPDB1
    username: system
    password: oracle
    driver-class-name: oracle.jdbc.OracleDriver
    hikari:
      maximum-pool-size: 10
      minimum-idle: 2

  batch:
    jdbc:
      initialize-schema: always   # cria as tabelas de metadados automaticamente
                                  # use 'never' em produção se as tabelas já existem
    job:
      enabled: false              # NÃO executar jobs automaticamente ao subir a aplicação

  jpa:
    hibernate:
      ddl-auto: validate          # valida entidades, não recria tabelas
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.OracleDialect
        format_sql: true

# Configuração customizada dos diretórios de arquivo
batch:
  files:
    input-dir: /tmp/batch/input    # onde ficam os arquivos de entrada (CSV)
    output-dir: /tmp/batch/output  # onde ficam os arquivos de saída (CSV gerado)

logging:
  level:
    org.springframework.batch: INFO
    com.exemplo.batch: DEBUG
```

### Tabelas Criadas pelo Spring Batch

Quando `initialize-schema: always`, o Spring Batch cria automaticamente:

```sql
-- Cada execução lógica de um job (job + params únicos)
BATCH_JOB_INSTANCE (
    JOB_INSTANCE_ID  NUMBER PRIMARY KEY,
    VERSION          NUMBER,
    JOB_NAME         VARCHAR2(100),
    JOB_KEY          VARCHAR2(32)  -- hash dos parâmetros
)

-- Cada tentativa de executar uma JobInstance
BATCH_JOB_EXECUTION (
    JOB_EXECUTION_ID  NUMBER PRIMARY KEY,
    JOB_INSTANCE_ID   NUMBER REFERENCES BATCH_JOB_INSTANCE,
    CREATE_TIME       TIMESTAMP,
    START_TIME        TIMESTAMP,
    END_TIME          TIMESTAMP,
    STATUS            VARCHAR2(10),  -- STARTED, COMPLETED, FAILED, STOPPED
    EXIT_CODE         VARCHAR2(2500),
    EXIT_MESSAGE      VARCHAR2(2500)
)

-- Parâmetros de cada execução
BATCH_JOB_EXECUTION_PARAMS (
    JOB_EXECUTION_ID  NUMBER,
    PARAMETER_NAME    VARCHAR2(100),
    PARAMETER_TYPE    VARCHAR2(100),
    PARAMETER_VALUE   VARCHAR2(2500)
)

-- Execução de cada Step dentro do Job
BATCH_STEP_EXECUTION (
    STEP_EXECUTION_ID  NUMBER PRIMARY KEY,
    JOB_EXECUTION_ID   NUMBER,
    STEP_NAME          VARCHAR2(100),
    START_TIME         TIMESTAMP,
    END_TIME           TIMESTAMP,
    STATUS             VARCHAR2(10),
    READ_COUNT         NUMBER,       -- quantos registros foram lidos
    WRITE_COUNT        NUMBER,       -- quantos foram escritos
    FILTER_COUNT       NUMBER,       -- quantos foram ignorados pelo processor
    SKIP_COUNT         NUMBER,       -- quantos foram pulados por erro
    COMMIT_COUNT       NUMBER,       -- quantos commits foram feitos
    ROLLBACK_COUNT     NUMBER        -- quantos rollbacks
)

-- Sequences Oracle para gerar IDs
BATCH_JOB_SEQ
BATCH_STEP_EXECUTION_SEQ
BATCH_JOB_EXECUTION_SEQ
```

---

## Configuração da Classe Main

```java
package com.exemplo.batch;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

// Spring Batch 5 (Spring Boot 3.x):
// NÃO precisa mais de @EnableBatchProcessing — é auto-configurado!
// Se você adicionar @EnableBatchProcessing no Boot 3, pode causar conflitos.

// Spring Batch 4 (Spring Boot 2.x):
// Precisava de @EnableBatchProcessing na classe main ou em uma @Configuration

@SpringBootApplication
public class BatchApplication {

    public static void main(String[] args) {
        SpringApplication.run(BatchApplication.class, args);
    }
}
```

---

## Estrutura de Pacotes do Projeto

```
src/main/java/com/exemplo/batch/
├── BatchApplication.java              ← classe main
│
├── config/
│   └── BatchConfig.java               ← configuração dos Jobs e Steps
│
├── domain/
│   ├── Cliente.java                   ← entidade JPA (tabela Oracle)
│   └── ClienteInput.java              ← DTO de entrada do CSV (record)
│
├── processor/
│   └── ClienteProcessor.java          ← ItemProcessor de validação/transformação
│
├── listener/
│   ├── JobResultListener.java         ← log de início/fim do job
│   └── StepResultListener.java        ← log de métricas do step
│
├── tasklet/
│   └── CriarDiretoriosTasklet.java    ← cria diretórios antes de processar
│
└── controller/
    └── BatchController.java           ← endpoints REST para disparar jobs
```

```
src/main/resources/
├── application.yml                    ← configuração geral
└── schema-oracle.sql                  ← DDL da tabela de clientes (opcional)
```

---

## Entidade e DTO

### Cliente.java — Entidade JPA

```java
package com.exemplo.batch.domain;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "clientes")
@Data
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "clientes_seq")
    @SequenceGenerator(name = "clientes_seq", sequenceName = "clientes_seq", allocationSize = 50)
    private Long id;

    @Column(nullable = false, length = 200)
    private String nome;

    @Column(nullable = false, length = 200, unique = true)
    private String email;

    @Column(length = 14)
    private String cpf;

    @Column(length = 20)
    private String telefone;

    @Column(nullable = false)
    private Boolean ativo = true;

    @Column(name = "criado_em")
    private LocalDateTime criadoEm = LocalDateTime.now();
}
```

### ClienteInput.java — DTO para Leitura do CSV

```java
package com.exemplo.batch.domain;

// Record Java: imutável, sem boilerplate, perfeito para DTOs de entrada
public record ClienteInput(
    String nome,
    String email,
    String cpf,
    String telefone
) {}
```

### DDL no Oracle

```sql
-- Execute no Oracle antes de subir a aplicação:
CREATE SEQUENCE clientes_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE clientes (
    id         NUMBER         PRIMARY KEY,
    nome       VARCHAR2(200)  NOT NULL,
    email      VARCHAR2(200)  NOT NULL UNIQUE,
    cpf        VARCHAR2(14),
    telefone   VARCHAR2(20),
    ativo      NUMBER(1)      DEFAULT 1 NOT NULL,
    criado_em  TIMESTAMP      DEFAULT SYSTIMESTAMP
);
```

---

## Nosso Arquivo de Entrada

Crie o arquivo `/tmp/batch/input/clientes.csv`:

```csv
nome,email,cpf,telefone
João Silva,joao.silva@email.com,111.111.111-11,(11) 99999-1111
Maria Santos,maria.santos@email.com,222.222.222-22,(21) 98888-2222
Carlos Oliveira,carlos.oliveira@email.com,333.333.333-33,(31) 97777-3333
Ana Lima,ana.lima@email.com,444.444.444-44,(41) 96666-4444
Pedro Costa,pedro.costa@email.com,555.555.555-55,(51) 95555-5555
Fernanda Rocha,fernanda.rocha@email.com,666.666.666-66,
Roberto Alves,,777.777.777-77,(71) 93333-7777
Camila Souza,camila.souza@email.com,888.888.888-88,(81) 92222-8888
Lucas Martins,lucas.martins@email.com,999.999.999-99,(91) 91111-9999
Beatriz Ferreira,beatriz.ferreira@email.com,000.000.000-00,(11) 90000-0000
```

Observações sobre o arquivo:
- Linha 1: cabeçalho (será ignorado pelo reader com `linesToSkip(1)`)
- Linha 7 (Roberto Alves): email vazio → será ignorado pelo processor (retorna null)
- Linha 7 (Fernanda Rocha): telefone vazio → válido, telefone é opcional

---

## Como Verificar as Execuções no Banco

Após executar um job, você pode consultar diretamente no Oracle:

```sql
-- Ver todos os jobs executados:
SELECT ji.job_name,
       je.job_execution_id,
       je.status,
       je.start_time,
       je.end_time,
       ROUND((je.end_time - je.start_time) * 86400, 2) AS duracao_segundos
FROM batch_job_instance ji
JOIN batch_job_execution je ON ji.job_instance_id = je.job_instance_id
ORDER BY je.start_time DESC;

-- Ver detalhes dos steps:
SELECT se.step_name,
       se.status,
       se.read_count,
       se.write_count,
       se.filter_count,
       se.skip_count,
       se.commit_count
FROM batch_step_execution se
WHERE se.job_execution_id = :jobExecutionId
ORDER BY se.start_time;

-- Ver parâmetros de uma execução:
SELECT parameter_name, parameter_type, parameter_value
FROM batch_job_execution_params
WHERE job_execution_id = :jobExecutionId;
```

---

## Controller REST para Disparar Jobs

```java
package com.exemplo.batch.controller;

import org.springframework.batch.core.*;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/batch")
public class BatchController {

    private final JobLauncher jobLauncher;
    private final Job importacaoJob;
    private final Job exportacaoJob;

    public BatchController(JobLauncher jobLauncher, Job importacaoJob, Job exportacaoJob) {
        this.jobLauncher = jobLauncher;
        this.importacaoJob = importacaoJob;
        this.exportacaoJob = exportacaoJob;
    }

    // POST /api/batch/importar
    // Dispara o job de importação CSV → Oracle
    @PostMapping("/importar")
    public ResponseEntity<Map<String, Object>> importar() {
        try {
            JobParameters params = new JobParametersBuilder()
                .addLocalDate("data", LocalDate.now())
                .addLong("timestamp", System.currentTimeMillis())  // garante unicidade
                .toJobParameters();

            JobExecution execution = jobLauncher.run(importacaoJob, params);

            return ResponseEntity.ok(Map.of(
                "jobExecutionId", execution.getId(),
                "status", execution.getStatus().toString(),
                "startTime", execution.getStartTime().toString()
            ));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of(
                "erro", e.getMessage()
            ));
        }
    }

    // POST /api/batch/exportar
    // Dispara o job de exportação Oracle → CSV
    @PostMapping("/exportar")
    public ResponseEntity<Map<String, Object>> exportar() {
        try {
            JobParameters params = new JobParametersBuilder()
                .addLocalDate("data", LocalDate.now())
                .addLong("timestamp", System.currentTimeMillis())
                .toJobParameters();

            JobExecution execution = jobLauncher.run(exportacaoJob, params);

            return ResponseEntity.ok(Map.of(
                "jobExecutionId", execution.getId(),
                "status", execution.getStatus().toString()
            ));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of(
                "erro", e.getMessage()
            ));
        }
    }
}
```

---

## Resumo do Tópico

| Conceito | O que é | Para que serve |
|---------|---------|----------------|
| Batch | Processamento em lote sem interação humana | Alto volume, fora do pico |
| Spring Batch | Framework Java para batch | Gerencia execução, restart, retry |
| Job | Processo batch completo | Unidade de trabalho |
| JobInstance | Job + parâmetros únicos | Identifica execução lógica |
| JobExecution | Tentativa real de executar | Controle de tentativas/falhas |
| Step | Fase dentro do Job | Tasklet ou Chunk |
| JobRepository | Persistência de metadados | Restart, rastreamento |
| JobLauncher | Inicia um Job | Ponto de entrada |
| JobParameters | Parâmetros da execução | Identificação e configuração |

---

## Exercícios Conceituais

### Básico

1. Qual a diferença entre processamento online e batch? Dê 3 exemplos de cada.

2. Explique a relação entre `Job`, `JobInstance` e `JobExecution`. Use uma analogia do mundo real.

3. O que é um `JobRepository` e para que serve? O que acontece se o banco de metadados ficar indisponível?

4. Liste as tabelas criadas pelo Spring Batch e explique o que cada uma armazena.

### Intermediário

5. Por que o parâmetro `timestamp` é frequentemente adicionado ao `JobParameters`? Quando isso é útil e quando não deve ser feito?

6. Qual a diferença entre `initialize-schema: always` e `initialize-schema: never`? Qual usar em cada ambiente (dev, homologação, produção)?

7. No Oracle, o que é uma `SEQUENCE` e por que a entidade `Cliente` usa `allocationSize = 50`?

8. Se um job de importação de 1 milhão de registros falhar no registro 750.000, o que acontece quando você reinicia? Explique usando os conceitos `JobInstance` e `JobExecution`.

### Avançado

9. Por que `job.enabled: false` é importante no `application.yml`? O que aconteceria se fosse `true` em um ambiente com banco compartilhado?

10. Explique por que o Spring Batch usa o hash dos `JobParameters` como `JOB_KEY` na tabela `BATCH_JOB_INSTANCE`. Qual problema isso resolve?

11. Pesquise sobre `JobOperator` no Spring Batch. Como ele difere do `JobLauncher`? Quando você usaria um em vez do outro?

12. Desenhe a arquitetura de um sistema batch para processar 50 milhões de registros em menos de 2 horas. Quais estratégias de paralelismo você usaria?

---

## Próximo Tópico

No **Tópico 2** você vai implementar os componentes fundamentais do Spring Batch:
- `ItemReader` com `FlatFileItemReader` e `JdbcCursorItemReader`
- `ItemProcessor` com validação e transformação
- `ItemWriter` com `JdbcBatchItemWriter` e `FlatFileItemWriter`
- Configuração completa de Steps e Jobs
- Listeners para observabilidade
