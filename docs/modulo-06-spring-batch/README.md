# Módulo 6 - Spring Batch: Processamento em Lote com Arquivos e Oracle

## Visão Geral

Este módulo ensina como construir pipelines de processamento em lote (batch processing) robustos usando **Spring Batch 5.x** integrado ao banco de dados **Oracle**. Você aprenderá a importar dados de arquivos CSV para o banco e a exportar dados do banco para arquivos locais, com tratamento de erros, controle transacional e monitoramento completo.

O módulo é totalmente prático: cada conceito é imediatamente acompanhado de código funcional, explicações linha a linha e exercícios que consolidam o aprendizado.

Processamento em lote é uma habilidade essencial no mercado corporativo brasileiro. Bancos, seguradoras, operadoras de saúde e empresas de telecomunicações processam diariamente milhões de registros usando exatamente os padrões que você aprenderá aqui.

---

## Ementa

| Aula | Título | Carga Horária Estimada |
|------|--------|----------------------|
| 01 | Introdução ao Spring Batch | 3h |
| 02 | Conceitos Fundamentais | 4h |
| 03 | Importação: Arquivo CSV para Oracle | 5h |
| 04 | Exportação: Oracle para Arquivo CSV | 4h |
| 05 | Controle de Transação e Erros | 4h |
| 06 | Projeto Completo Integrado | 6h |

**Carga Horária Total Estimada:** aproximadamente 26 horas

---

## Objetivos de Aprendizagem

Ao concluir este módulo, você será capaz de:

1. **Explicar** o que é processamento em lote e quando utilizá-lo em vez de processamento online
2. **Descrever** a arquitetura do Spring Batch: Job, Step, JobRepository, JobLauncher
3. **Implementar** leitores de arquivo (FlatFileItemReader) para processar arquivos CSV e TXT do disco local
4. **Implementar** escritores para banco Oracle (JdbcBatchItemWriter)
5. **Implementar** leitores de banco Oracle (JdbcCursorItemReader, JdbcPagingItemReader)
6. **Implementar** escritores para arquivo local (FlatFileItemWriter) com cabeçalho e formatação
7. **Configurar** tratamento de erros com skip e retry policies
8. **Gerenciar** transações em nível de chunk
9. **Monitorar** execuções de jobs via tabelas de metadados do Spring Batch no Oracle
10. **Disparar** jobs via endpoint REST usando o BatchController
11. **Construir** um projeto integrado completo com ambos os fluxos de dados

---

## Pré-Requisitos

Este módulo requer conhecimento sólido dos módulos anteriores. Se você pulou algum módulo, volte e complete-o antes de prosseguir.

### Módulo 1 - Java e Orientação a Objetos (obrigatório)
- Classes, interfaces, herança e polimorfismo
- Generics: você usará `ItemReader<T>`, `ItemWriter<T>`, `ItemProcessor<I,O>` constantemente
- Tratamento de exceções (try/catch/throws): essencial para configurar skip e retry
- Anotações Java: `@Override`, anotações customizadas

### Módulo 2 - Banco de Dados e SQL (obrigatório)
- DDL: CREATE TABLE, ALTER TABLE (para criar as tabelas de metadados do batch)
- DML: INSERT, UPDATE, SELECT, DELETE
- Conceito de transação (COMMIT, ROLLBACK): fundamental para entender chunk processing
- Chaves primárias, sequences do Oracle

### Módulo 3 - JDBC (obrigatório)
- Como Java se conecta ao banco de dados via DataSource
- PreparedStatement e parametrização de queries
- ResultSet e mapeamento para objetos Java (usado no JdbcCursorItemReader)
- Connection Pool com HikariCP

### Módulo 4 - API REST (obrigatório)
- Spring MVC: @RestController, @GetMapping, @PostMapping
- Injeção de dependências: @Autowired, @Component, @Service
- ResponseEntity e códigos HTTP

### Módulo 5 - Spring Boot (obrigatório)
- Criação de projetos Spring Boot com Maven
- application.yml com múltiplas seções de configuração
- JPA/Hibernate: @Entity, @Table, @Column
- Spring Data JPA com JpaRepository
- @Configuration e @Bean para configurar componentes manualmente

### Conhecimentos Técnicos Adicionais
- Docker básico: saber subir um container Oracle
- Maven: adicionar dependências no pom.xml
- Familiaridade com linha de comando Linux/macOS

---

## Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|------------|--------|-----------|
| Java | 17+ | Linguagem principal |
| Spring Boot | 3.2.x | Framework de aplicação |
| Spring Batch | 5.1.x | Framework de batch processing |
| Spring Data JPA | 3.2.x | Persistência de entidades |
| Oracle Database | 21c XE | Banco de dados principal |
| ojdbc11 | 23.x | Driver JDBC do Oracle |
| HikariCP | 5.x | Pool de conexões |
| Lombok | 1.18.x | Redução de boilerplate |
| Maven | 3.9.x | Gerenciamento de dependências |

---

## Estrutura do Módulo

```
modulo-06-spring-batch/
├── README.md                              (este arquivo - visão geral e checklist)
├── 01-introducao-spring-batch.md          (teoria: o que é batch, arquitetura)
├── 02-conceitos-fundamentais.md           (Job, Step, Reader, Processor, Writer)
├── 03-importacao-arquivo-para-oracle.md   (Fluxo 1: CSV local -> Oracle)
├── 04-exportacao-oracle-para-arquivo.md   (Fluxo 2: Oracle -> CSV local)
├── 05-controle-transacao-e-erros.md       (Skip, Retry, Fault Tolerance, metadados)
└── 06-projeto-completo.md                 (Projeto integrado final com ambos os fluxos)
```

---

## Diagrama do Módulo

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MÓDULO 6 - SPRING BATCH                          │
│                                                                     │
│  FLUXO 1: IMPORTAÇÃO (Aula 03)                                      │
│                                                                     │
│  /tmp/batch/input/        Spring Batch          Oracle Database     │
│  clientes.csv      ──►   ItemReader        ──►  TB_CLIENTE          │
│  (disco local)           ItemProcessor         (tabela Oracle)      │
│                          ItemWriter                                  │
│                                                                     │
│  FLUXO 2: EXPORTAÇÃO (Aula 04)                                      │
│                                                                     │
│  Oracle Database         Spring Batch      /tmp/batch/output/       │
│  TB_CLIENTE        ──►   ItemReader   ──►  clientes_export.csv      │
│  (tabela Oracle)         ItemProcessor     (disco local)            │
│                          ItemWriter                                  │
│                                                                     │
│  CONTROLE E MONITORAMENTO                                           │
│                                                                     │
│  REST API         JobLauncher        JobRepository                  │
│  POST /importar ──► executa Job ──► grava metadados em:             │
│  POST /exportar      (Job/Step)      BATCH_JOB_INSTANCE             │
│                                      BATCH_JOB_EXECUTION            │
│                                      BATCH_STEP_EXECUTION            │
│                                                                     │
│  TOLERÂNCIA A FALHAS (Aula 05)                                      │
│                                                                     │
│  Skip: ignora registros inválidos ──► log no /tmp/batch/error/      │
│  Retry: tenta novamente em erros transitórios (timeout, deadlock)   │
│  Restart: retoma job falho do ponto de parada                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Projeto do Módulo

Ao longo do módulo, construímos um **Sistema de Integração de Dados de Clientes** que simula um cenário real corporativo:

### Cenário de Negócio
Uma empresa recebe diariamente um arquivo CSV com dados de novos clientes de um sistema legado. Esses dados precisam ser importados para o Oracle, validados e transformados. Além disso, a empresa precisa gerar relatórios exportando clientes ativos para um arquivo CSV enviado a parceiros.

### O Que o Sistema Faz
1. **Importa** clientes de um arquivo CSV local (`/tmp/batch/input/clientes.csv`) para a tabela `TB_CLIENTE` no Oracle
2. **Valida** CPF, e-mail e campos obrigatórios durante a importação
3. **Transforma** dados: padroniza nomes em maiúsculas, formata CPF, etc.
4. **Ignora** registros inválidos e registra-os em arquivo de erro
5. **Exporta** clientes ativos do Oracle para `/tmp/batch/output/clientes_export.csv`
6. **Registra** todas as execuções nas tabelas de metadados do Spring Batch
7. **Expõe** endpoints REST para disparar importação e exportação

---

## Ambiente de Desenvolvimento

### Requisitos de Software

```bash
# Verificar Java 17 ou superior
java -version
# Saída esperada: java version "17.x.x" ou superior

# Verificar Maven
mvn -version
# Saída esperada: Apache Maven 3.8.x ou superior

# Verificar Docker
docker --version
# Saída esperada: Docker version 24.x.x ou superior
```

### Subindo Oracle no Docker

```bash
# Baixar e iniciar Oracle 21c Express Edition
# ATENÇÃO: A imagem tem cerca de 3GB, a primeira execução pode demorar
docker run -d \
  --name oracle-xe \
  -p 1521:1521 \
  -e ORACLE_PASSWORD=senha123 \
  container-registry.oracle.com/database/express:21.3.0-xe

# Acompanhar os logs de inicialização (aguardar "DATABASE IS READY TO USE!")
docker logs -f oracle-xe

# Dados de conexão:
# Host:     localhost
# Porta:    1521
# Service:  XEPDB1
# Usuário:  system
# Senha:    senha123
```

### Criando os Diretórios de Arquivos

```bash
# Criar estrutura de diretórios para o batch
mkdir -p /tmp/batch/input
mkdir -p /tmp/batch/output
mkdir -p /tmp/batch/error

# Verificar
ls -la /tmp/batch/
# drwxr-xr-x  error
# drwxr-xr-x  input
# drwxr-xr-x  output
```

### Estrutura do Projeto Maven

A estrutura de pacotes que usaremos ao longo do módulo:

```
batch-clientes/
├── pom.xml
└── src/
    └── main/
        ├── java/
        │   └── com/empresa/batch/
        │       ├── BatchClientesApplication.java        (classe principal)
        │       ├── config/
        │       │   ├── ImportacaoJobConfig.java          (Job de importação)
        │       │   └── ExportacaoJobConfig.java          (Job de exportação)
        │       ├── entity/
        │       │   └── ClienteEntity.java                (entidade JPA)
        │       ├── model/
        │       │   └── ClienteDTO.java                   (DTO para exportação)
        │       ├── reader/
        │       │   ├── ClienteItemReader.java            (lê CSV do disco)
        │       │   └── ClienteExportItemReader.java      (lê do Oracle)
        │       ├── processor/
        │       │   ├── ClienteItemProcessor.java         (valida e transforma)
        │       │   └── ClienteExportItemProcessor.java   (formata para saída)
        │       ├── writer/
        │       │   ├── ClienteItemWriter.java            (grava no Oracle)
        │       │   └── ClienteExportItemWriter.java      (grava CSV no disco)
        │       ├── listener/
        │       │   ├── JobNotificationListener.java      (log início/fim do job)
        │       │   └── SkipRegistroListener.java         (registra erros ignorados)
        │       └── controller/
        │           └── BatchController.java              (endpoints REST)
        └── resources/
            ├── application.yml                           (configuração geral)
            └── schema.sql                               (DDL das tabelas de negócio)
```

---

## Checklist de Conclusão do Módulo

Use este checklist para acompanhar seu progresso. Marque cada item somente quando você conseguir reproduzir o comportamento sem consultar o material.

### Aula 01 - Introdução ao Spring Batch
- [ ] Consigo explicar o que é processamento em lote com minhas próprias palavras
- [ ] Sei citar pelo menos 3 casos de uso reais de batch processing no mercado brasileiro
- [ ] Entendo a diferença entre batch e processamento online (REST API)
- [ ] Sei explicar a arquitetura geral: Job -> Step -> ItemReader/ItemProcessor/ItemWriter
- [ ] Entendo o papel do JobRepository e para que serve cada tabela BATCH_*
- [ ] Sei adicionar as dependências do Spring Batch no pom.xml
- [ ] Configurei as tabelas de metadados do Spring Batch no Oracle

### Aula 02 - Conceitos Fundamentais
- [ ] Sei o que é um Job e como identificar uma instância de execução
- [ ] Entendo a diferença entre Tasklet e Chunk-oriented processing
- [ ] Consigo explicar o ciclo: read -> process -> write -> commit (chunk por chunk)
- [ ] Sei escolher um chunk size adequado para diferentes cenários
- [ ] Conheço FlatFileItemReader, JdbcCursorItemReader e JdbcPagingItemReader
- [ ] Entendo o papel do ItemProcessor (transformação e filtragem)
- [ ] Conheço FlatFileItemWriter e JdbcBatchItemWriter
- [ ] Sei para que servem os Listeners (JobExecutionListener, StepExecutionListener)
- [ ] Entendo o papel dos JobParameters e por que são importantes para re-execução
- [ ] Fiz todos os exercícios de fixação da aula

### Aula 03 - Importação CSV para Oracle
- [ ] Implementei o FlatFileItemReader com DefaultLineMapper, DelimitedLineTokenizer e BeanWrapperFieldSetMapper
- [ ] Implementei um ItemProcessor que valida CPF e e-mail
- [ ] Implementei o JdbcBatchItemWriter para inserção em lote no Oracle
- [ ] Configurei o Job e o Step com chunk size de 100
- [ ] O endpoint POST /api/batch/importar funciona e dispara o job
- [ ] Verifiquei os dados na tabela TB_CLIENTE após a importação
- [ ] Configurei skip para linhas inválidas (FlatFileParseException, ValidationException)
- [ ] O arquivo de erro é gerado em /tmp/batch/error/ com os registros ignorados
- [ ] Fiz todos os exercícios práticos da aula

### Aula 04 - Exportação Oracle para Arquivo CSV
- [ ] Implementei o JdbcCursorItemReader com RowMapper
- [ ] Implementei o FlatFileItemWriter com FlatFileHeaderCallback e DelimitedLineAggregator
- [ ] O arquivo CSV é gerado corretamente em /tmp/batch/output/
- [ ] O arquivo tem cabeçalho na primeira linha
- [ ] O endpoint POST /api/batch/exportar funciona
- [ ] Testei exportação com filtro (WHERE status = 'ATIVO')
- [ ] Experimentei o JdbcPagingItemReader como alternativa
- [ ] Fiz todos os exercícios práticos da aula

### Aula 05 - Controle de Transação e Erros
- [ ] Entendo como Spring Batch abre e fecha transações por chunk
- [ ] Sei o que acontece quando um item dentro de um chunk lança exceção
- [ ] Configurei .faultTolerant().skipLimit(10).skip(MinhaException.class)
- [ ] Configurei .faultTolerant().retryLimit(3).retry(TransientException.class)
- [ ] Implementei SkipListener que escreve registros ignorados em arquivo
- [ ] Sei usar JobParameters com timestamp para garantir re-execução
- [ ] Consultei BATCH_JOB_INSTANCE, BATCH_JOB_EXECUTION e BATCH_STEP_EXECUTION no SQL
- [ ] Simulei uma falha e reiniciei o job com sucesso
- [ ] Fiz todos os exercícios da aula

### Aula 06 - Projeto Completo
- [ ] O projeto Maven compila sem erros com `mvn clean package`
- [ ] Oracle está rodando no Docker com o schema criado
- [ ] As tabelas de metadados do Spring Batch foram criadas no Oracle
- [ ] O job de importação funciona end-to-end (CSV -> Oracle)
- [ ] O job de exportação funciona end-to-end (Oracle -> CSV)
- [ ] Os endpoints REST de importação e exportação funcionam
- [ ] Skip de registros inválidos está configurado em ambos os jobs
- [ ] Os metadados de execução são salvos no Oracle
- [ ] Consegui monitorar execuções consultando as tabelas BATCH_*
- [ ] Completei pelo menos 2 dos desafios de extensão do projeto

---

## Relação com os Módulos Anteriores

```
Módulo 1 (Java OO)
    Classes e Interfaces ──► ItemReader<T>, ItemWriter<T>, ItemProcessor<I,O>
    Generics            ──► Tipagem dos componentes batch
    Exceções            ──► Skip e Retry de exceções específicas

Módulo 2 (Banco de Dados)
    SQL SELECT          ──► Queries do JdbcCursorItemReader
    SQL INSERT          ──► SQL do JdbcBatchItemWriter
    Transações          ──► Gerenciamento por chunk no Step

Módulo 3 (JDBC)
    DataSource          ──► Conexão do Spring Batch com o Oracle
    ResultSet           ──► RowMapper no JdbcCursorItemReader
    PreparedStatement   ──► Parâmetros no JdbcBatchItemWriter

Módulo 4 (REST API)
    @RestController     ──► BatchController para disparar jobs
    ResponseEntity      ──► Retorno dos endpoints de batch

Módulo 5 (Spring Boot)
    @Configuration      ──► ImportacaoJobConfig, ExportacaoJobConfig
    @Bean               ──► Definição de Job, Step, Reader, Writer
    application.yml     ──► Configuração de datasource e propriedades batch

                    ↓
          MÓDULO 6 (Spring Batch)
    Integra TODO o conhecimento anterior em pipelines robustos de dados
    prontos para ambientes corporativos de alto volume
```

---

## Estimativa de Tempo por Atividade

| Atividade | Tempo Estimado |
|-----------|---------------|
| Leitura e estudo do capítulo 01 | 2-3 horas |
| Leitura e estudo do capítulo 02 | 3-4 horas |
| Implementação do capítulo 03 (importação) | 4-5 horas |
| Implementação do capítulo 04 (exportação) | 3-4 horas |
| Estudo e prática do capítulo 05 (erros) | 3-4 horas |
| Projeto completo do capítulo 06 | 5-7 horas |
| **Total estimado** | **20-27 horas** |

Os tempos variam conforme o ritmo individual. Não se preocupe se levar mais tempo - o importante é entender profundamente cada conceito.

---

*Módulo 6 de 6 da Formação Java Zero to Hero*
*Spring Batch 5.x + Spring Boot 3.x + Oracle 21c*
