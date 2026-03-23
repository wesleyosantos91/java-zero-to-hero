# Módulo 03 — Java + JDBC (Java Database Connectivity)

## Visão Geral

Bem-vindo ao Módulo 3 da trilha **Java Zero to Hero**! Chegamos a um dos pontos mais importantes da sua formação como desenvolvedor Java backend: a integração com banco de dados via **JDBC**.

Se nos módulos anteriores você aprendeu a pensar em orientação a objetos e a modelar dados com SQL, agora você vai conectar esses dois mundos. Neste módulo, você aprenderá a fazer seu programa Java conversar com um banco de dados Oracle de verdade — inserindo, consultando, atualizando e deletando registros de forma segura e profissional.

Este módulo é fundamentalmente prático. Ao final, você terá construído um sistema completo de cadastro de clientes com CRUD (Create, Read, Update, Delete) usando boas práticas de mercado.

---

## Pré-requisitos

Este módulo exige que você tenha concluído:

### Módulo 01 — Java e Orientação a Objetos
Você precisa saber:
- Criar classes, atributos e métodos em Java
- Trabalhar com herança, interfaces e encapsulamento
- Tratar exceções com try/catch/finally
- Usar coleções (List, ArrayList)
- Entender modificadores de acesso (public, private, protected)
- Conhecer o conceito de construtores e getters/setters

### Módulo 02 — Banco de Dados e SQL
Você precisa saber:
- O que é um banco de dados relacional
- Como escrever comandos DDL (CREATE TABLE, ALTER TABLE)
- Como escrever comandos DML (SELECT, INSERT, UPDATE, DELETE)
- O que são chaves primárias e estrangeiras
- O que é uma transação (COMMIT e ROLLBACK)
- Ter o Oracle Database rodando (via Docker ou instalação local)

> **Dica:** Se você pulou algum módulo, volte e revise os tópicos listados acima antes de continuar. JDBC sem base sólida em Java e SQL vai gerar muita frustração.

---

## Ementa Completa

### Aula 1 — Introdução ao JDBC
- O que é JDBC e por que ele existe
- Arquitetura do JDBC (Driver, DriverManager, Connection)
- Driver Oracle JDBC: o que é e como adicionar ao projeto Maven
- URL de conexão Oracle: formatos e componentes
- Estabelecendo sua primeira conexão com o banco
- Classes fundamentais: `Connection`, `Statement`, `PreparedStatement`, `ResultSet`
- Problemas comuns de conexão e como diagnosticá-los
- Exercícios práticos

### Aula 2 — Executando Queries SQL com JDBC
- `Statement` vs `PreparedStatement`: quando usar cada um
- SQL Injection: o que é, como funciona, como se proteger
- `ResultSet`: navegando pelos resultados de uma consulta
- Métodos de execução: `executeQuery()`, `executeUpdate()`, `execute()`
- Operações completas: SELECT, INSERT, UPDATE, DELETE
- Obtendo o ID gerado após uma inserção
- Batch updates: executando múltiplos comandos de forma eficiente
- Exercícios práticos

### Aula 3 — Boas Práticas com JDBC
- Fechamento correto de recursos (evitando memory leaks)
- `try-with-resources`: a forma moderna e segura
- Connection Pool: por que abrir uma nova conexão a cada operação é um problema
- HikariCP: o connection pool mais rápido para Java
- Padrão DAO (Data Access Object): separando responsabilidades
- Tratamento adequado de `SQLException`
- Configuração externalizada com arquivos `.properties`
- Transações manuais: `setAutoCommit()`, `commit()`, `rollback()`
- Exercícios práticos

### Aula 4 — Projeto Completo: CRUD de Clientes
- Planejamento e estrutura de pacotes
- Entidade `Cliente` com validações
- Interface `ClienteDAO` e implementação `ClienteDAOImpl`
- `ConnectionFactory` com HikariCP configurado
- Menu console interativo
- Todos os métodos CRUD implementados e explicados
- Tratamento de exceções personalizado
- Scripts SQL de setup
- Checklist de conclusão do módulo

---

## Estrutura de Arquivos

```
docs/modulo-03-jdbc/
├── README.md                        (este arquivo)
├── 01-introducao-jdbc.md            (Aula 1 — Conexão, DriverManager, DataSource)
├── 02-queries-sql-com-jdbc.md       (Aula 2 — PreparedStatement, ResultSet, batch)
├── 03-transacoes-e-gerenciamento-conexao.md (Aula 3 — HikariCP, transações, DAO)
├── 04-projeto-crud-clientes.md      (Aula 4 — Projeto final com menu console)
└── exercicios.md                    (16 exercícios + desafio integrador)
```

---

## Objetivos de Aprendizagem

Ao concluir este módulo, você será capaz de:

1. **Explicar** o que é JDBC e qual problema ele resolve
2. **Configurar** um projeto Maven com as dependências necessárias para JDBC com Oracle
3. **Estabelecer** uma conexão com o banco de dados Oracle de forma segura
4. **Executar** queries SQL (SELECT, INSERT, UPDATE, DELETE) a partir do Java
5. **Prevenir** SQL Injection usando `PreparedStatement`
6. **Navegar** por resultados de consultas usando `ResultSet`
7. **Aplicar** o padrão DAO para separar responsabilidades no código
8. **Configurar** um connection pool com HikariCP
9. **Gerenciar** transações manualmente com commit e rollback
10. **Fechar** recursos JDBC corretamente usando try-with-resources
11. **Construir** um CRUD completo e funcional com Java + JDBC + Oracle

---

## Tecnologias Utilizadas

| Tecnologia | Versão | Papel |
|---|---|---|
| Java | 17 LTS | Linguagem de programação |
| Maven | 3.8+ | Gerenciamento de dependências e build |
| Oracle Database | 21c XE | Banco de dados relacional |
| Oracle JDBC Driver | ojdbc11 | Driver de comunicação Java-Oracle |
| HikariCP | 5.1.0 | Connection pool de alta performance |
| SLF4J + Logback | 2.0.x | Logging |

---

## Configuração do Ambiente

### 1. Verificar se o Oracle está rodando

```bash
# Se estiver usando Docker:
docker ps | grep oracle

# Ou verificar o serviço:
docker start oracle-db
```

### 2. Estrutura do pom.xml do projeto

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <groupId>br.com.zerotohero</groupId>
    <artifactId>modulo03-jdbc</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>

        <!-- Oracle JDBC Driver -->
        <dependency>
            <groupId>com.oracle.database.jdbc</groupId>
            <artifactId>ojdbc11</artifactId>
            <version>23.3.0.23.09</version>
        </dependency>

        <!-- HikariCP - Connection Pool -->
        <dependency>
            <groupId>com.zaxxer</groupId>
            <artifactId>HikariCP</artifactId>
            <version>5.1.0</version>
        </dependency>

        <!-- SLF4J API - Interface de Logging -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>2.0.9</version>
        </dependency>

        <!-- Logback - Implementação de Logging -->
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>1.4.14</version>
        </dependency>

        <!-- JUnit 5 - Testes -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.1</version>
            <scope>test</scope>
        </dependency>

    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
            </plugin>
        </plugins>
    </build>

</project>
```

### 3. Testar a conexão

Após configurar o pom.xml, rode o exemplo básico da Aula 1 para garantir que a conexão está funcionando antes de avançar.

---

## Checklist de Conclusão do Módulo

Use este checklist para acompanhar seu progresso:

### Aula 1 — Introdução ao JDBC
- [ ] Entendo o que é JDBC e qual problema ele resolve
- [ ] Sei o que é um Driver JDBC e para que serve
- [ ] Configurei o pom.xml com o driver Oracle JDBC
- [ ] Consigo estabelecer uma conexão com o Oracle via Java
- [ ] Sei o que é uma URL de conexão JDBC e cada parte dela
- [ ] Completei os exercícios da Aula 1

### Aula 2 — Executando Queries
- [ ] Sei a diferença entre `Statement` e `PreparedStatement`
- [ ] Entendo o que é SQL Injection e como `PreparedStatement` previne
- [ ] Consigo fazer um SELECT e ler os resultados com `ResultSet`
- [ ] Sei usar `executeQuery()`, `executeUpdate()` e `execute()`
- [ ] Consigo executar INSERT, UPDATE e DELETE via Java
- [ ] Completei os exercícios da Aula 2

### Aula 3 — Boas Práticas
- [ ] Uso `try-with-resources` para fechar recursos JDBC
- [ ] Entendo o que é um Connection Pool e por que é necessário
- [ ] Configurei o HikariCP no meu projeto
- [ ] Implementei o padrão DAO em um exemplo
- [ ] Sei trabalhar com transações (commit/rollback)
- [ ] Sei ler configurações de um arquivo `.properties`
- [ ] Completei os exercícios da Aula 3

### Aula 4 — Projeto Final
- [ ] Criei a estrutura de pacotes do projeto
- [ ] Implementei a entidade `Cliente`
- [ ] Implementei a interface `ClienteDAO`
- [ ] Implementei `ClienteDAOImpl` com todos os métodos CRUD
- [ ] Criei o `ConnectionFactory` com HikariCP
- [ ] O menu console funciona corretamente
- [ ] Consigo inserir, listar, buscar, atualizar e deletar clientes
- [ ] Tratei as exceções de forma adequada

### Conclusão
- [ ] Revisei todo o conteúdo do módulo
- [ ] Sinto confiança para trabalhar com JDBC em projetos reais
- [ ] Estou pronto para avançar ao Módulo 4 (REST API com Spring Boot)

---

## Dicas de Estudo

**Não copie e cole o código.** Digite cada exemplo à mão. Isso pode parecer lento, mas é a forma mais eficaz de fixar a sintaxe e entender o que está acontecendo.

**Quebre o código de propósito.** Após cada exemplo funcionar, tente modificá-lo de formas erradas para entender as mensagens de erro. Isso vai te preparar para depurar problemas no futuro.

**Experimente com seu banco de dados.** Crie tabelas diferentes, insira dados variados, tente queries mais complexas. O objetivo é ganhar confiança.

**Leia as exceções com atenção.** O Java sempre te diz o que deu errado. `SQLException` normalmente contém o código de erro do Oracle, que você pode pesquisar na documentação oficial.

---

## Próximo Módulo

Após concluir este módulo, você estará pronto para o **Módulo 4 — REST API com Spring Boot**, onde você aprenderá a expor seus dados via HTTP, transformando sua aplicação de linha de comando em uma API web profissional.

---

*Módulo 3 da trilha Java Zero to Hero | Atualizado em 2026*
