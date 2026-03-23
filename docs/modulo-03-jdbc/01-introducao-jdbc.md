# Aula 1 — Introdução ao JDBC

## O que você vai aprender nesta aula

Nesta aula, você vai entender o que é o JDBC, por que ele existe, como funciona por baixo dos panos e como criar sua primeira conexão com um banco de dados Oracle usando Java. Ao final, você terá um programa funcional que se conecta ao Oracle e exibe uma mensagem de confirmação.

---

## 1. O Problema que JDBC Resolve

Imagine que você está desenvolvendo um sistema em Java e precisa salvar dados em um banco de dados. A pergunta natural é: **como o Java conversa com o banco de dados?**

Nos primórdios do desenvolvimento de software, cada banco de dados tinha sua própria API (Application Programming Interface) nativa. Isso significava que:

- Para usar o Oracle, você precisava aprender a API proprietária da Oracle
- Para usar o MySQL, você precisava aprender a API do MySQL
- Para usar o SQL Server, mais uma API completamente diferente
- Se a empresa decidisse trocar de banco de dados, você precisava **reescrever todo o código de acesso a dados**

Isso era um pesadelo de manutenção. Imagine uma empresa com milhões de linhas de código precisando migrar de Oracle para PostgreSQL — seria necessário reescrever toda a camada de banco de dados do zero.

**O JDBC veio para resolver exatamente esse problema.**

---

## 2. O que é JDBC

**JDBC** significa **Java Database Connectivity**. É uma API padrão do Java (definida na especificação Java SE) que fornece um conjunto de interfaces e classes para conectar aplicações Java a bancos de dados relacionais.

A ideia central do JDBC é simples e poderosa:

> O seu código Java sempre fala com as **mesmas interfaces** do JDBC, independentemente do banco de dados que está sendo usado. Quem faz a "tradução" para o banco específico é o **Driver JDBC**.

Pense assim: você sempre escreve em português para se comunicar. Se precisa falar com um americano, usa um tradutor (inglês). Se precisa falar com um japonês, usa outro tradutor (japonês). Você (o código Java) não muda — só o tradutor (o driver) muda.

### Benefícios do JDBC

1. **Portabilidade**: com pouquíssimas mudanças (basicamente a URL de conexão e o driver), você pode trocar de banco de dados.
2. **Padronização**: qualquer desenvolvedor Java já conhece a API JDBC. Não precisa aprender uma API nova para cada banco.
3. **Suporte universal**: todos os bancos de dados relacionais importantes possuem drivers JDBC. Oracle, MySQL, PostgreSQL, SQL Server, H2, SQLite — todos têm suporte.
4. **Maturidade**: o JDBC existe desde 1997 (Java 1.1). É uma tecnologia extremamente estável e bem documentada.

---

## 3. Arquitetura do JDBC

Para entender como tudo funciona, veja a cadeia de comunicação:

```
Seu código Java (usa interfaces JDBC)
          ↓
    API JDBC (java.sql.*)
          ↓
   Driver JDBC (fornecido pelo fabricante do banco)
          ↓
   Banco de Dados (Oracle, MySQL, etc.)
```

Cada camada tem uma responsabilidade clara:

| Camada | Responsável | Exemplo |
|---|---|---|
| Seu código | Você | `connection.prepareStatement(sql)` |
| API JDBC | Oracle/Java (parte do JDK) | `java.sql.Connection`, `java.sql.PreparedStatement` |
| Driver JDBC | Fabricante do banco | `ojdbc11.jar` (Oracle) |
| Banco de dados | Servidor de banco | Oracle Database 21c |

---

## 4. Driver JDBC: O que é e como funciona

O **Driver JDBC** é uma biblioteca (arquivo `.jar`) fornecida pelo fabricante do banco de dados. Ele implementa todas as interfaces do JDBC para aquele banco específico.

Quando você chama `DriverManager.getConnection(url, usuario, senha)`, o JDBC internamente:

1. Analisa a URL fornecida (ex: `jdbc:oracle:thin:@localhost:1521:XE`)
2. Identifica qual driver pode tratar aquela URL
3. Delega a criação da conexão para o driver adequado
4. O driver estabelece a conexão real com o banco de dados
5. Retorna um objeto `Connection` que você usa no seu código

O driver registra a si mesmo automaticamente quando é carregado pelo classloader do Java (desde JDBC 4.0, que veio com Java 6). Você não precisa mais chamar `Class.forName()` manualmente — basta ter o `.jar` no classpath.

### Como adicionar o Driver Oracle ao projeto Maven

O driver Oracle JDBC se chama **ojdbc** (Oracle JDBC Driver). Para Java 17, usamos o `ojdbc11` (compatível com JDBC 4.3).

Adicione esta dependência no `pom.xml` do seu projeto:

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

        <!-- ============================================ -->
        <!-- Driver JDBC do Oracle                        -->
        <!-- ojdbc11 = compatível com Java 11+ e JDBC 4.3-->
        <!-- ============================================ -->
        <dependency>
            <groupId>com.oracle.database.jdbc</groupId>
            <artifactId>ojdbc11</artifactId>
            <version>23.3.0.23.09</version>
        </dependency>

        <!-- ============================================ -->
        <!-- HikariCP - Connection Pool                   -->
        <!-- Será usado nas próximas aulas                -->
        <!-- ============================================ -->
        <dependency>
            <groupId>com.zaxxer</groupId>
            <artifactId>HikariCP</artifactId>
            <version>5.1.0</version>
        </dependency>

        <!-- ============================================ -->
        <!-- Logging: SLF4J + Logback                     -->
        <!-- ============================================ -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>2.0.9</version>
        </dependency>
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>1.4.14</version>
        </dependency>

        <!-- ============================================ -->
        <!-- Testes com JUnit 5                           -->
        <!-- ============================================ -->
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
                <configuration>
                    <source>17</source>
                    <target>17</target>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>
```

> **Por que ojdbc11 e não ojdbc8?**
> O número depois de "ojdbc" indica a versão do JDBC que o driver implementa, não a versão do Java. O `ojdbc11` implementa JDBC 4.3 e é compatível com Java 11 em diante. Para Java 17, use `ojdbc11`. O `ojdbc8` implementa JDBC 4.2 e é para Java 8.

---

## 5. Classes e Interfaces Fundamentais do JDBC

Antes de escrever código, você precisa conhecer os "atores principais" do JDBC. Todas essas classes e interfaces estão no pacote `java.sql`.

### 5.1 DriverManager

`java.sql.DriverManager` é uma classe utilitária (todos os métodos são estáticos) responsável por gerenciar os drivers JDBC registrados e criar conexões.

Método mais importante:
```java
// Cria e retorna uma conexão com o banco de dados
Connection conn = DriverManager.getConnection(url, usuario, senha);
```

### 5.2 Connection

`java.sql.Connection` representa **uma conexão ativa com o banco de dados**. É o objeto mais importante do JDBC — tudo parte dele.

Com uma `Connection` você pode:
- Criar `Statement` e `PreparedStatement` para executar SQL
- Gerenciar transações (commit, rollback)
- Verificar metadados do banco

```java
// Criar um PreparedStatement a partir da conexão
PreparedStatement ps = conn.prepareStatement("SELECT * FROM clientes WHERE id = ?");

// Gerenciar transações
conn.setAutoCommit(false); // inicia controle manual de transação
conn.commit();             // confirma as alterações
conn.rollback();           // desfaz as alterações
```

> **IMPORTANTE**: `Connection` consome recursos do banco de dados. Sempre feche a conexão quando terminar. Veremos como fazer isso corretamente com `try-with-resources` na Aula 3.

### 5.3 Statement

`java.sql.Statement` é usado para executar SQL **simples** e **sem parâmetros variáveis**.

```java
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery("SELECT * FROM clientes");
```

**Atenção**: `Statement` tem um problema grave chamado **SQL Injection** (veremos na Aula 2). Na prática, quase sempre usamos `PreparedStatement` no lugar.

### 5.4 PreparedStatement

`java.sql.PreparedStatement` é a forma **correta e segura** de executar SQL com parâmetros. O SQL é pré-compilado e os parâmetros são passados separadamente, o que previne SQL Injection.

```java
// O "?" é um placeholder para o parâmetro
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM clientes WHERE email = ? AND ativo = ?"
);
ps.setString(1, "joao@email.com"); // Primeiro parâmetro (índice 1, não 0!)
ps.setInt(2, 1);                   // Segundo parâmetro
ResultSet rs = ps.executeQuery();
```

### 5.5 ResultSet

`java.sql.ResultSet` representa o **resultado de uma query SELECT**. Funciona como um cursor que aponta para uma linha por vez.

```java
ResultSet rs = ps.executeQuery();
while (rs.next()) {                          // Move para a próxima linha
    Long id     = rs.getLong("id");          // Pega o valor da coluna "id"
    String nome = rs.getString("nome");      // Pega o valor da coluna "nome"
    int idade   = rs.getInt("idade");        // Pega o valor da coluna "idade"
    Date data   = rs.getDate("criado_em");   // Pega o valor de uma data
}
```

O cursor do `ResultSet` começa **antes** da primeira linha. O método `next()` move o cursor para a próxima linha e retorna `true` se existir uma linha, ou `false` se não houver mais linhas.

### 5.6 CallableStatement

`java.sql.CallableStatement` é usado para chamar **procedures e functions** armazenadas no banco de dados. Veremos em detalhes mais adiante.

```java
// Chamando uma stored procedure do Oracle
CallableStatement cs = conn.prepareCall("{call calcula_desconto(?, ?)}");
cs.setLong(1, clienteId);
cs.registerOutParameter(2, Types.DECIMAL);
cs.execute();
BigDecimal desconto = cs.getBigDecimal(2);
```

---

## 6. URL de Conexão Oracle — Entendendo Cada Parte

A URL de conexão é uma string que diz ao JDBC onde encontrar o banco de dados e como se conectar a ele. Para o Oracle, existem alguns formatos.

### Formato Thin (mais comum)

```
jdbc:oracle:thin:@//HOST:PORTA/SERVICE_NAME
```

Exemplo real:
```
jdbc:oracle:thin:@//localhost:1521/XEPDB1
```

Quebrando em partes:

| Parte | Valor | Significado |
|---|---|---|
| `jdbc:` | `jdbc:` | Prefixo obrigatório de toda URL JDBC |
| `oracle:` | `oracle:` | Indica que é um banco Oracle |
| `thin:` | `thin:` | Tipo do driver (thin = puro Java, sem Oracle Client instalado) |
| `@//` | `@//` | Separador e início do endereço |
| `localhost` | `localhost` | Host onde o Oracle está rodando |
| `1521` | `1521` | Porta padrão do Oracle listener |
| `/XEPDB1` | `/XEPDB1` | Nome do serviço (Service Name) do banco |

### Formato com SID (mais antigo)

```
jdbc:oracle:thin:@HOST:PORTA:SID
```

Exemplo:
```
jdbc:oracle:thin:@localhost:1521:XE
```

> **Service Name vs SID**: O Service Name (ex: `XEPDB1`) é o nome lógico de um banco plugável (PDB - Pluggable Database), enquanto o SID (ex: `XE`) é o identificador da instância do Oracle. Em Oracle 12c ou superior com PDB, use sempre o Service Name com o formato `@//host:porta/service_name`.

### Verificando as informações da sua instalação Oracle Docker

Se estiver usando Oracle XE via Docker:

```bash
# Ver o container Oracle rodando
docker ps | grep oracle

# Verificar o Service Name disponível
docker exec -it oracle-db sqlplus / as sysdba <<EOF
SELECT name, cdb FROM v\$database;
SHOW PDBS;
EXIT;
EOF
```

Os valores típicos para Oracle XE 21c no Docker:
- Host: `localhost`
- Porta: `1521`
- Service Name: `XEPDB1` (banco plugável)
- Usuario padrão: `system`
- Senha: a que você definiu ao criar o container

---

## 7. Sua Primeira Conexão com o Oracle

Agora vamos ao código. Crie a seguinte classe no seu projeto:

```java
package br.com.zerotohero.jdbc.aula01;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Demonstração básica de conexão com Oracle via JDBC.
 *
 * ANTES DE EXECUTAR:
 * 1. Verifique que o Oracle está rodando (docker ps)
 * 2. Ajuste URL, USUARIO e SENHA conforme sua instalação
 * 3. Execute a classe como aplicação Java normal
 */
public class PrimeiraConexao {

    // Constantes de configuração — em projeto real, viria de arquivo .properties
    private static final String URL     = "jdbc:oracle:thin:@//localhost:1521/XEPDB1";
    private static final String USUARIO = "system";
    private static final String SENHA   = "oracle123";

    public static void main(String[] args) {
        System.out.println("=== Testando Conexão com Oracle via JDBC ===");
        System.out.println();

        // O try-with-resources garante que a conexão será fechada automaticamente
        // mesmo que ocorra uma exceção — veremos isso em detalhes na Aula 3
        try (Connection conexao = DriverManager.getConnection(URL, USUARIO, SENHA)) {

            // Se chegou aqui, a conexão foi estabelecida com sucesso!
            System.out.println("SUCESSO! Conexão estabelecida com o banco de dados.");
            System.out.println();

            // DatabaseMetaData contém informações sobre o banco conectado
            DatabaseMetaData metaDados = conexao.getMetaData();

            System.out.println("Informações do banco de dados:");
            System.out.println("  Produto: " + metaDados.getDatabaseProductName());
            System.out.println("  Versão:  " + metaDados.getDatabaseProductVersion());
            System.out.println("  Driver:  " + metaDados.getDriverName());
            System.out.println("  Versão do Driver: " + metaDados.getDriverVersion());
            System.out.println();

            // Verificando se a conexão está ativa
            boolean conexaoAtiva = !conexao.isClosed();
            System.out.println("Conexão está ativa: " + conexaoAtiva);

            // Verificando o auto-commit (por padrão, é true)
            System.out.println("Auto-commit ativado: " + conexao.getAutoCommit());

        } catch (SQLException e) {
            // SQLException é a exceção raiz de todos os erros do JDBC
            // Ela contém informações valiosas para diagnóstico:
            System.err.println("ERRO ao conectar ao banco de dados!");
            System.err.println("Mensagem:    " + e.getMessage());
            System.err.println("SQLState:    " + e.getSQLState());
            System.err.println("Error Code:  " + e.getErrorCode());
            e.printStackTrace();
        }

        System.out.println();
        System.out.println("=== Fim do programa ===");
        // Nota: a conexão já foi fechada automaticamente pelo try-with-resources
        // antes de chegarmos aqui
    }
}
```

### Saída esperada (conexão bem-sucedida):

```
=== Testando Conexão com Oracle via JDBC ===

SUCESSO! Conexão estabelecida com o banco de dados.

Informações do banco de dados:
  Produto: Oracle
  Versão:  Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
  Driver:  Oracle JDBC driver
  Versão do Driver: 23.3.0.23.09

Conexão está ativa: true
Auto-commit ativado: true

=== Fim do programa ===
```

---

## 8. Problemas Comuns de Conexão e Como Resolver

Esta seção é uma referência rápida para os erros mais frequentes que você vai encontrar.

### Erro 1: ORA-12541 — No listener

```
ORA-12541: TNS:no listener
```

**Causa**: O Oracle não está rodando ou o listener não está ativo.

**Solução**:
```bash
# Verificar se o container Docker está ativo
docker ps | grep oracle

# Iniciar o container se estiver parado
docker start oracle-db

# Aguardar o banco inicializar (pode levar 30-60 segundos)
# Verificar os logs:
docker logs -f oracle-db
```

### Erro 2: ORA-01017 — Usuário/senha inválidos

```
ORA-01017: invalid username/password; logon denied
```

**Causa**: Usuário ou senha incorretos na URL de conexão.

**Solução**: Verifique as credenciais. Para Oracle XE no Docker, a senha foi definida na criação do container. Se não lembrar:
```bash
# Recriar o container (ATENÇÃO: apaga todos os dados)
docker stop oracle-db
docker rm oracle-db
docker run -d --name oracle-db \
  -p 1521:1521 \
  -e ORACLE_PASSWORD=oracle123 \
  container-registry.oracle.com/database/express:21.3.0-xe
```

### Erro 3: ClassNotFoundException — Driver não encontrado

```
java.lang.ClassNotFoundException: oracle.jdbc.driver.OracleDriver
```

**Causa**: O arquivo `.jar` do driver JDBC não está no classpath.

**Solução**: Verifique se a dependência `ojdbc11` está no `pom.xml` e execute:
```bash
mvn dependency:resolve
mvn clean compile
```

### Erro 4: IOException — Connection refused

```
java.net.ConnectException: Connection refused
```

**Causa**: O host ou porta na URL estão errados, ou o Oracle não está escutando nessa porta.

**Solução**: Verifique a URL. A porta padrão do Oracle é `1521`. Verifique se o Docker está mapeando a porta corretamente:
```bash
docker ps
# Deve mostrar: 0.0.0.0:1521->1521/tcp
```

### Erro 5: ORA-12505 — SID não encontrado

```
ORA-12505: TNS:listener does not currently know of SID given in connect descriptor
```

**Causa**: O SID informado na URL não existe. Isso acontece quando você usa o formato antigo com SID mas devia usar Service Name.

**Solução**: Troque o formato da URL de:
```
jdbc:oracle:thin:@localhost:1521:XE
```
Para:
```
jdbc:oracle:thin:@//localhost:1521/XEPDB1
```

### Tabela de Diagnóstico Rápido

| Erro | O que verificar |
|---|---|
| No listener | Oracle está rodando? Docker container ativo? |
| Invalid username/password | Usuário e senha corretos? |
| ClassNotFoundException | Dependência ojdbc11 no pom.xml? Maven update? |
| Connection refused | Host e porta corretos? Firewall bloqueando? |
| SID não encontrado | Usar Service Name (XEPDB1) ao invés de SID (XE)? |

---

## 9. Testando a Conexão com uma Query Simples

Após confirmar que a conexão funciona, vamos ir um passo além e executar uma query simples para validar que tudo está funcionando corretamente:

```java
package br.com.zerotohero.jdbc.aula01;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Testa a conexão executando uma query simples no Oracle.
 * O Oracle tem uma tabela especial chamada DUAL que sempre tem exatamente uma linha.
 * É muito usada para testar expressões e funções do Oracle.
 */
public class TesteConexaoComQuery {

    private static final String URL     = "jdbc:oracle:thin:@//localhost:1521/XEPDB1";
    private static final String USUARIO = "system";
    private static final String SENHA   = "oracle123";

    public static void main(String[] args) {
        System.out.println("=== Teste de Conexão com Query ===");

        // A query "SELECT SYSDATE FROM DUAL" retorna a data e hora atual do servidor Oracle.
        // DUAL é uma tabela especial do Oracle com exatamente uma linha — perfeita para testes.
        String sql = "SELECT SYSDATE FROM DUAL";

        try (Connection conexao = DriverManager.getConnection(URL, USUARIO, SENHA);
             PreparedStatement ps = conexao.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            // O try-with-resources acima fecha automaticamente, na ordem inversa:
            // primeiro o ResultSet, depois o PreparedStatement, depois a Connection.

            System.out.println("Conexão estabelecida com sucesso!");
            System.out.println("Executando query: " + sql);
            System.out.println();

            if (rs.next()) {
                // getDate(1) pega o valor da primeira coluna como java.sql.Date
                java.sql.Date dataAtual = rs.getDate(1);
                System.out.println("Data/hora atual no servidor Oracle: " + dataAtual);
            }

            System.out.println();
            System.out.println("Query executada com sucesso! JDBC está funcionando corretamente.");

        } catch (SQLException e) {
            System.err.println("Falha no teste de conexão.");
            System.err.println("Erro: " + e.getMessage());
            System.err.println("SQLState: " + e.getSQLState());
            System.err.println("Código do erro Oracle: " + e.getErrorCode());
        }
    }
}
```

---

## 10. Entendendo a SQLException

`java.sql.SQLException` é a exceção raiz de todos os erros relacionados ao JDBC. Quando algo dá errado em qualquer operação de banco de dados, uma `SQLException` é lançada.

Ela tem três informações críticas para diagnóstico:

```java
catch (SQLException e) {
    // 1. getMessage() — descrição humana do erro
    //    Exemplo: "ORA-01017: invalid username/password; logon denied"
    System.err.println("Mensagem: " + e.getMessage());

    // 2. getSQLState() — código padrão XOPEN/SQL99 de 5 caracteres
    //    Exemplos: "08001" (falha de conexão), "23000" (violação de integridade)
    System.err.println("SQLState: " + e.getSQLState());

    // 3. getErrorCode() — código específico do banco de dados
    //    Para Oracle: ORA-XXXXX → getErrorCode() retorna o número XXXXX
    //    Exemplo: ORA-01017 → getErrorCode() retorna 1017
    System.err.println("Código do erro: " + e.getErrorCode());

    // 4. getNextException() — exceções encadeadas (pode haver mais de um erro)
    SQLException proxima = e.getNextException();
    while (proxima != null) {
        System.err.println("Próximo erro: " + proxima.getMessage());
        proxima = proxima.getNextException();
    }
}
```

### Códigos de erro Oracle mais comuns

| Código ORA | Significado |
|---|---|
| ORA-00001 | Violação de unique constraint |
| ORA-01017 | Usuário ou senha inválidos |
| ORA-01400 | Violação de NOT NULL constraint |
| ORA-02291 | Violação de foreign key (pai não existe) |
| ORA-02292 | Violação de foreign key (filho existe, não pode deletar pai) |
| ORA-12541 | Listener não encontrado |
| ORA-12505 | SID não reconhecido |

---

## 11. Exercícios da Aula 1

### Exercício 1 — Conexão Básica (Obrigatório)

Configure seu projeto Maven com as dependências corretas e escreva um programa que:
1. Conecta ao banco de dados Oracle
2. Exibe a versão do banco de dados conectado
3. Exibe a data e hora atual do servidor (usando `SELECT SYSDATE FROM DUAL`)
4. Fecha a conexão corretamente com `try-with-resources`
5. Trata adequadamente a `SQLException`

### Exercício 2 — Diagnóstico de Erros (Obrigatório)

Modifique o programa do Exercício 1 para testar cenários de erro:
1. Altere a senha para uma senha errada e observe o erro
2. Altere a porta para `9999` e observe o erro
3. Altere o host para `bancoquenoexiste` e observe o erro

Para cada caso, anote:
- Qual exceção foi lançada?
- Qual é o `getMessage()`?
- Qual é o `getSQLState()`?
- Qual é o `getErrorCode()`?

### Exercício 3 — Query de Verificação (Avançado)

Escreva um programa que:
1. Conecta ao Oracle
2. Executa a query: `SELECT TABLE_NAME FROM USER_TABLES ORDER BY TABLE_NAME`
3. Exibe o nome de todas as tabelas do usuário conectado
4. Conta e exibe o número total de tabelas encontradas

> **Dica**: `USER_TABLES` é uma view do Oracle que lista as tabelas do usuário atual. Se não houver tabelas, crie uma primeiro com: `CREATE TABLE teste_jdbc (id NUMBER PRIMARY KEY, nome VARCHAR2(100))`

### Exercício 4 — Extração de Informações de Conexão (Avançado)

Escreva uma classe utilitária `InfoConexao` com um método estático que recebe uma `Connection` e imprime:
- Nome do produto (ex: "Oracle")
- Versão do produto
- URL de conexão usada
- Nome do usuário conectado
- Se suporta transações
- Nível de isolamento de transação padrão

Use `DatabaseMetaData` para obter todas essas informações.

---

## Resumo da Aula 1

Nesta aula você aprendeu:

- **JDBC** é a API padrão do Java para comunicação com bancos de dados relacionais
- O problema que JDBC resolve: antes existia uma API diferente para cada banco
- A **arquitetura em camadas**: seu código -> API JDBC -> Driver JDBC -> Banco de dados
- O **Driver JDBC** é um `.jar` fornecido pelo fabricante (Oracle = `ojdbc11`)
- Como adicionar o driver Oracle ao projeto via **Maven**
- As **classes fundamentais**: `DriverManager`, `Connection`, `Statement`, `PreparedStatement`, `ResultSet`, `CallableStatement`
- Os **formatos de URL** do Oracle e o significado de cada parte
- Como criar uma **conexão simples** com o Oracle
- Como usar **try-with-resources** para fechar a conexão automaticamente
- Os **problemas comuns** de conexão e como diagnosticá-los
- As informações importantes de **SQLException** para diagnóstico

Na próxima aula, você aprenderá a executar queries SQL reais: SELECT, INSERT, UPDATE e DELETE!

---

*Aula 1 de 4 — Módulo 3: Java + JDBC | Java Zero to Hero*
