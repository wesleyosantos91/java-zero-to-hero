# Módulo 6 — Spring Batch: Processamento em Lote com Arquivos e Oracle

## Visão Geral

Este módulo ensina como construir sistemas de processamento em lote (batch processing) profissionais usando **Spring Batch 5.x** com **Spring Boot 3.x**. O foco é a integração entre **arquivos locais (CSV/TXT)** e o **banco de dados Oracle**, dois cenários amplamente utilizados em ambientes corporativos e financeiros.

Ao final deste módulo, você será capaz de criar pipelines robustos de dados que importam e exportam milhões de registros com controle de erros, retentativas, transações e rastreabilidade completa.

---

## Ementa

| # | Tópico | Descrição |
|---|--------|-----------|
| 1 | Introdução ao Spring Batch | Conceitos, arquitetura, quando usar batch |
| 2 | Conceitos Fundamentais | Job, Step, Chunk, ItemReader, ItemProcessor, ItemWriter |
| 3 | Importação: Arquivo → Oracle | Ler CSV do disco e gravar no banco Oracle |
| 4 | Exportação: Oracle → Arquivo | Ler do Oracle e gerar CSV no disco |
| 5 | Controle de Transação e Erros | Skip, Retry, Fault Tolerance, Restart |
| 6 | Projeto Completo | Sistema integrado com ambos os fluxos |

---

## Objetivos de Aprendizagem

Ao concluir este módulo, o aluno será capaz de:

1. **Explicar** o que é processamento batch e em quais situações ele é preferível ao processamento online
2. **Identificar** os componentes da arquitetura Spring Batch: Job, Step, JobRepository, JobLauncher
3. **Implementar** leitura de arquivos CSV com `FlatFileItemReader` usando `DefaultLineMapper`, `DelimitedLineTokenizer` e `BeanWrapperFieldSetMapper`
4. **Implementar** escrita no Oracle com `JdbcBatchItemWriter`
5. **Implementar** leitura do Oracle com `JdbcCursorItemReader` e `JdbcPagingItemReader`
6. **Implementar** geração de arquivos CSV com `FlatFileItemWriter`, incluindo cabeçalho e formatação
7. **Configurar** políticas de skip e retry para tolerância a falhas
8. **Depurar** problemas usando as tabelas de metadados do Spring Batch
9. **Expor** endpoints REST para disparar jobs de importação e exportação
10. **Construir** um projeto completo integrado com dois fluxos de dados

---

## Pré-requisitos

Este módulo requer conhecimento sólido dos módulos anteriores:

### Módulo 1 — Java e Orientação a Objetos
- Classes, interfaces, herança
- Generics (`List<T>`, `Optional<T>`)
- Tratamento de exceções (`try/catch/throw`)
- Annotations (`@Override`, `@FunctionalInterface`)

### Módulo 2 — Banco de Dados
- SQL: `SELECT`, `INSERT`, `UPDATE`, `DELETE`
- Conceito de transações (`COMMIT`, `ROLLBACK`)
- Oracle: tipos de dados, constraints, sequências

### Módulo 3 — JDBC
- `DataSource`, `Connection`, `PreparedStatement`
- `ResultSet` e mapeamento para objetos Java
- Pool de conexões

### Módulo 4 — REST API
- Spring MVC: `@RestController`, `@GetMapping`, `@PostMapping`
- `ResponseEntity`, códigos HTTP
- `@RequestBody`, `@RequestParam`

### Módulo 5 — Spring Boot
- Auto-configuração do Spring Boot
- `application.yml` / `application.properties`
- Spring Data JPA: `@Entity`, `@Repository`, `JpaRepository`
- Injeção de dependências: `@Autowired`, `@Bean`, `@Configuration`
- Spring Boot 3.x com Java 17+

---

## Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|------------|--------|-----------|
| Java | 17+ | Linguagem de programação |
| Spring Boot | 3.2.x | Framework principal |
| Spring Batch | 5.1.x | Processamento em lote |
| Spring Data JPA | 3.2.x | Persistência ORM |
| Oracle Database | 21c (Docker) | Banco de dados |
| ojdbc11 | 21.x | Driver JDBC Oracle |
| Lombok | 1.18.x | Redução de boilerplate |
| Maven | 3.8+ | Gerenciamento de dependências |

---

## Estrutura dos Arquivos do Módulo

```
modulo-06-spring-batch/
├── README.md                              ← Este arquivo (visão geral)
├── 01-introducao-spring-batch.md          ← O que é Spring Batch, arquitetura
├── 02-conceitos-fundamentais.md           ← Job, Step, Chunk, Reader, Processor, Writer
├── 03-importacao-arquivo-para-oracle.md   ← Fluxo 1: CSV → Oracle (implementação completa)
├── 04-exportacao-oracle-para-arquivo.md   ← Fluxo 2: Oracle → CSV (implementação completa)
├── 05-controle-transacao-e-erros.md       ← Skip, Retry, Fault Tolerance, Restart
└── 06-projeto-completo.md                 ← Projeto integrado final
```

---

## Diagrama do Módulo

```
┌─────────────────────────────────────────────────────────────────┐
│                     MÓDULO 6 — SPRING BATCH                      │
│                                                                   │
│   FLUXO 1: IMPORTAÇÃO                                            │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐  │
│   │  clientes.csv│───▶│ Spring Batch │───▶│ Oracle Database  │  │
│   │ (disco local)│    │  (Job/Step)  │    │ (tabela cliente) │  │
│   └──────────────┘    └──────────────┘    └──────────────────┘  │
│                                                                   │
│   FLUXO 2: EXPORTAÇÃO                                            │
│   ┌──────────────────┐    ┌──────────────┐    ┌─────────────┐   │
│   │  Oracle Database │───▶│ Spring Batch │───▶│ export.csv  │   │
│   │ (tabela cliente) │    │  (Job/Step)  │    │(disco local)│   │
│   └──────────────────┘    └──────────────┘    └─────────────┘   │
│                                                                   │
│   CONTROLE:                                                       │
│   ┌────────────────────────────────────────────────────────┐    │
│   │ REST API → JobLauncher → Job → Step → Chunk Processing │    │
│   │ Skip/Retry → JobRepository (tabelas BATCH_*)           │    │
│   └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Ambiente de Desenvolvimento

### Oracle com Docker

```bash
# Iniciar Oracle 21c Express Edition
docker run -d \
  --name oracle-xe \
  -p 1521:1521 \
  -e ORACLE_PASSWORD=senha123 \
  container-registry.oracle.com/database/express:21.3.0-xe

# Aguardar inicialização (pode levar 2-3 minutos)
docker logs -f oracle-xe

# Conexão:
# Host: localhost
# Porta: 1521
# Service: XEPDB1
# Usuário: system (admin) ou criar usuário próprio
# Senha: senha123
```

### Diretórios de Arquivos Batch

```bash
# Criar diretórios para arquivos de entrada e saída
mkdir -p /tmp/batch/input
mkdir -p /tmp/batch/output
mkdir -p /tmp/batch/error

# Verificar
ls -la /tmp/batch/
```

### Estrutura do Projeto Maven

```
batch-clientes/
├── pom.xml
└── src/
    └── main/
        ├── java/
        │   └── com/empresa/batch/
        │       ├── BatchClientesApplication.java
        │       ├── config/
        │       │   ├── ImportacaoJobConfig.java
        │       │   └── ExportacaoJobConfig.java
        │       ├── entity/
        │       │   └── ClienteEntity.java
        │       ├── reader/
        │       │   ├── ClienteItemReader.java
        │       │   └── ClienteExportItemReader.java
        │       ├── processor/
        │       │   ├── ClienteItemProcessor.java
        │       │   └── ClienteExportItemProcessor.java
        │       ├── writer/
        │       │   ├── ClienteItemWriter.java
        │       │   └── ClienteExportItemWriter.java
        │       ├── listener/
        │       │   ├── JobNotificationListener.java
        │       │   └── SkipRegistroListener.java
        │       ├── model/
        │       │   └── ClienteDTO.java
        │       └── controller/
        │           └── BatchController.java
        └── resources/
            ├── application.yml
            └── schema.sql
```

---

## Checklist de Aprendizagem

Use este checklist para acompanhar seu progresso no módulo.

### Conceitos Teóricos

- [ ] Sei explicar o que é processamento batch e quando usá-lo
- [ ] Sei explicar a diferença entre batch e processamento online
- [ ] Conheço os componentes da arquitetura Spring Batch
- [ ] Entendo o papel do `JobRepository` e das tabelas de metadados
- [ ] Sei a diferença entre `Tasklet` e `Chunk-oriented processing`
- [ ] Entendo o ciclo de leitura → processamento → escrita em chunks
- [ ] Sei o que é `commit interval` e como escolhê-lo
- [ ] Entendo `Skip` e `Retry` e quando usar cada um
- [ ] Sei o que são `JobParameters` e por que são importantes

### Habilidades Práticas — Importação (CSV → Oracle)

- [ ] Criei um `FlatFileItemReader` funcional para CSV
- [ ] Configurei `DefaultLineMapper`, `DelimitedLineTokenizer` e `BeanWrapperFieldSetMapper`
- [ ] Implementei um `ItemProcessor` com validação de negócio
- [ ] Configurei um `JdbcBatchItemWriter` para inserção em lote no Oracle
- [ ] Montei o `Step` com chunk size adequado
- [ ] Configurei o `Job` completo
- [ ] Testei a importação via endpoint REST
- [ ] Verifiquei os dados no Oracle após importação
- [ ] Implementei skip para linhas inválidas

### Habilidades Práticas — Exportação (Oracle → CSV)

- [ ] Configurei um `JdbcCursorItemReader` com query no Oracle
- [ ] Implementei `RowMapper` para mapear `ResultSet` para DTO
- [ ] Configurei um `FlatFileItemWriter` com cabeçalho e campos
- [ ] Usei `BeanWrapperFieldExtractor` e `DelimitedLineAggregator`
- [ ] Testei a exportação via endpoint REST
- [ ] Verifiquei o arquivo CSV gerado no disco

### Habilidades Práticas — Controle de Erros

- [ ] Configurei `skipLimit` e `skippable exceptions`
- [ ] Configurei `retryLimit` e `retryable exceptions`
- [ ] Implementei `SkipListener` para registrar erros
- [ ] Consultei as tabelas `BATCH_JOB_EXECUTION` e `BATCH_STEP_EXECUTION`
- [ ] Entendi como reiniciar um job falho

### Projeto Completo

- [ ] Projeto Maven compila sem erros (`mvn clean package`)
- [ ] Oracle rodando no Docker com schema criado
- [ ] Importação funcional: arquivo CSV → Oracle
- [ ] Exportação funcional: Oracle → arquivo CSV
- [ ] Endpoints REST documentados e testados
- [ ] Skip de registros inválidos funcionando
- [ ] Metadados do batch armazenados no Oracle

---

## Como Usar Este Módulo

### Sequência Recomendada

1. Leia os **Capítulos 1 e 2** completamente antes de escrever qualquer código
2. Execute os exemplos do **Capítulo 3** (importação) do início ao fim
3. Execute os exemplos do **Capítulo 4** (exportação)
4. Estude o **Capítulo 5** (erros e transações) com atenção especial
5. Construa o **Projeto Completo** do Capítulo 6 do zero

### Dicas para o Aprendizado

> **Dica 1:** Execute o projeto e consulte as tabelas `BATCH_*` no Oracle após cada job. Isso solidifica o entendimento dos metadados.

> **Dica 2:** Propositalmente insira registros inválidos no CSV para ver o skip em ação.

> **Dica 3:** Acompanhe os logs do Spring Batch — eles são extremamente informativos.

> **Dica 4:** Leia a documentação oficial do Spring Batch 5.x em https://docs.spring.io/spring-batch/docs/current/reference/html/

---

## Relação com Módulos Anteriores

```
Módulo 1 (Java OO)
    └── Classes, Interfaces, Generics → usados em Reader/Processor/Writer

Módulo 2 (Banco de Dados)
    └── SQL, Transações, Oracle → usados em JdbcBatchItemWriter e JdbcCursorItemReader

Módulo 3 (JDBC)
    └── DataSource, Connection, ResultSet → base do Spring Batch com JDBC

Módulo 4 (REST API)
    └── @RestController, ResponseEntity → BatchController para disparar jobs

Módulo 5 (Spring Boot)
    └── @Configuration, @Bean, application.yml → configuração do Job e Steps

                        ↓
              MÓDULO 6 (Spring Batch)
        Integra tudo em pipelines de dados robustos
```

---

## Estimativa de Tempo

| Atividade | Tempo Estimado |
|-----------|---------------|
| Leitura dos capítulos 1 e 2 | 3-4 horas |
| Implementação do Capítulo 3 (importação) | 4-5 horas |
| Implementação do Capítulo 4 (exportação) | 3-4 horas |
| Estudo do Capítulo 5 (erros) | 2-3 horas |
| Projeto Completo (Capítulo 6) | 4-6 horas |
| **Total** | **16-22 horas** |

---

*Módulo 6 de 6 da Trilha Java Zero to Hero — Spring Batch para Processamento de Dados*
