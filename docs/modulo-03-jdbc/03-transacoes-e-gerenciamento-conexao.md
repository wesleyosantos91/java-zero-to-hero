# 03 — Transações e Gerenciamento de Conexão

## Revisão do Tópico Anterior
PreparedStatement, SQL Injection, ResultSet, INSERT/UPDATE/DELETE, batch updates. Agora vamos aprender a gerenciar conexões corretamente e trabalhar com transações.

---

## O Problema das Conexões

Cada conexão com o banco de dados é um **recurso caro**:
- Abre um socket TCP com o Oracle
- Autentica o usuário
- Aloca memória no servidor

Se você não fechar as conexões:
```java
// ERRADO: conexão aberta para sempre = memory leak + banco fica sem conexões disponíveis
Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
// ... usa o banco
// esqueceu de fechar!
```

---

## Connection Pool com HikariCP

Em aplicações reais, nunca conecte diretamente com `DriverManager`. Use um **pool de conexões**:

```
┌──────────────────────────────────────────────────────┐
│                  HikariCP (Pool)                      │
│                                                       │
│  Conexão 1 ←─── disponível                           │
│  Conexão 2 ←─── em uso por Thread A                  │
│  Conexão 3 ←─── em uso por Thread B                  │
│  Conexão 4 ←─── disponível                           │
│  Conexão 5 ←─── disponível                           │
│                                                       │
│  Thread A termina → devolve Conexão 2 ao pool        │
└──────────────────────────────────────────────────────┘
```

**Vantagens do pool:**
- Conexões são reutilizadas (não recriadas a cada request)
- Limite máximo de conexões configurável
- Timeout automático para conexões presas

### Configuração do HikariCP

```xml
<!-- pom.xml -->
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
    <version>5.1.0</version>
</dependency>
<dependency>
    <groupId>com.oracle.database.jdbc</groupId>
    <artifactId>ojdbc11</artifactId>
    <version>23.3.0.23.09</version>
</dependency>
```

```java
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import javax.sql.DataSource;

public class ConexaoOracle {

    private static final HikariDataSource dataSource;

    static {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:oracle:thin:@localhost:1521/FREEPDB1");
        config.setUsername("system");
        config.setPassword("oracle");
        config.setDriverClassName("oracle.jdbc.OracleDriver");

        // Pool: mínimo 5, máximo 20 conexões
        config.setMinimumIdle(5);
        config.setMaximumPoolSize(20);

        // Tempo máximo esperando por conexão do pool: 30 segundos
        config.setConnectionTimeout(30_000);

        // Tempo máximo que uma conexão pode ficar parada no pool: 10 minutos
        config.setIdleTimeout(600_000);

        // Tempo máximo de vida de uma conexão: 30 minutos
        config.setMaxLifetime(1_800_000);

        // Query de teste de saúde
        config.setConnectionTestQuery("SELECT 1 FROM DUAL");

        // Nome do pool (aparece nos logs)
        config.setPoolName("OraclePool");

        dataSource = new HikariDataSource(config);
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    // Método para fechar o pool (no encerramento da aplicação)
    public static void fechar() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}
```

### Usando o pool

```java
// Try-with-resources: garante que a conexão seja DEVOLVIDA ao pool
try (Connection conn = ConexaoOracle.getConnection()) {
    // usa o banco normalmente
    // ao sair do bloco try: conn.close() é chamado automaticamente
    // com pool: close() devolve a conexão ao pool (não fecha realmente)
}
```

---

## Transações com JDBC

### Auto-commit: comportamento padrão

```java
// Por padrão, cada SQL é confirmado imediatamente (auto-commit = true)
Connection conn = ConexaoOracle.getConnection();
// conn.getAutoCommit() → true

PreparedStatement pstmt = conn.prepareStatement("UPDATE ...");
pstmt.executeUpdate();  // COMMIT automático → não pode desfazer!
```

### Controlando transações manualmente

```java
// Exemplo: transferência bancária — deve ser atômico
public void transferir(Long idOrigem, Long idDestino, BigDecimal valor) throws SQLException {
    try (Connection conn = ConexaoOracle.getConnection()) {

        conn.setAutoCommit(false);  // DESABILITA auto-commit

        try {
            // Operação 1: debitar da conta origem
            debitarConta(conn, idOrigem, valor);

            // Operação 2: creditar na conta destino
            creditarConta(conn, idDestino, valor);

            // REGISTRAR operação no histórico
            registrarTransferencia(conn, idOrigem, idDestino, valor);

            conn.commit();  // CONFIRMAR tudo de uma vez (atômico)
            System.out.println("Transferência realizada com sucesso!");

        } catch (Exception e) {
            conn.rollback();  // DESFAZER tudo
            throw new RuntimeException("Transferência falhou: " + e.getMessage(), e);
        }
        // não precisa setar autoCommit de volta — conexão volta ao pool
    }
}

private void debitarConta(Connection conn, Long id, BigDecimal valor) throws SQLException {
    String sql = "UPDATE contas SET saldo = saldo - ? WHERE conta_id = ? AND saldo >= ?";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setBigDecimal(1, valor);
        pstmt.setLong(2, id);
        pstmt.setBigDecimal(3, valor);  // verifica saldo suficiente
        int linhas = pstmt.executeUpdate();
        if (linhas == 0) {
            throw new SQLException("Saldo insuficiente na conta " + id);
        }
    }
}
```

### Savepoints

```java
public void processarPedidoComplexo(Connection conn, Pedido pedido) throws SQLException {
    conn.setAutoCommit(false);
    Savepoint spPedido = null;

    try {
        // Inserir cabeçalho do pedido
        Long pedidoId = inserirPedido(conn, pedido);
        spPedido = conn.setSavepoint("sp_pedido_cabecalho");

        // Inserir itens
        for (ItemPedido item : pedido.getItens()) {
            try {
                inserirItem(conn, pedidoId, item);
                baixarEstoque(conn, item.getProdutoId(), item.getQuantidade());
            } catch (SQLException e) {
                // Se um item falhar, pula para o próximo mas mantém o pedido
                System.err.println("Falha no item " + item.getProdutoId() + ": " + e.getMessage());
                conn.rollback(spPedido);  // volta ao ponto após inserir o pedido
                // recria o savepoint
                spPedido = conn.setSavepoint("sp_pedido_cabecalho");
            }
        }

        conn.commit();

    } catch (Exception e) {
        conn.rollback();  // desfaz tudo incluindo o pedido
        throw e;
    }
}
```

---

## Padrão DAO — Data Access Object

O padrão DAO separa a lógica de acesso ao banco da lógica de negócio:

```java
// Interface DAO — define o contrato
public interface ClienteDao {
    Cliente salvar(Cliente cliente);
    Optional<Cliente> buscarPorId(Long id);
    Optional<Cliente> buscarPorEmail(String email);
    List<Cliente> listarTodos();
    List<Cliente> buscarPorEstado(String estado);
    Cliente atualizar(Cliente cliente);
    void desativar(Long id);
    int contar();
}
```

```java
// Implementação Oracle — toda SQL fica aqui
public class ClienteDaoOracle implements ClienteDao {

    private static final String INSERT =
        "INSERT INTO clientes (nome, email, telefone, cpf, cidade, estado) " +
        "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SELECT_BY_ID =
        "SELECT cliente_id, nome, email, telefone, cpf, cidade, estado, ativo, data_cadastro " +
        "FROM clientes WHERE cliente_id = ? AND ativo = 1";

    private static final String SELECT_ALL =
        "SELECT cliente_id, nome, email, telefone, cpf, cidade, estado, ativo, data_cadastro " +
        "FROM clientes WHERE ativo = 1 ORDER BY nome";

    private static final String SELECT_BY_EMAIL =
        "SELECT cliente_id, nome, email, telefone, cpf, cidade, estado, ativo, data_cadastro " +
        "FROM clientes WHERE email = ? AND ativo = 1";

    private static final String UPDATE =
        "UPDATE clientes SET nome=?, email=?, telefone=?, cpf=?, cidade=?, estado=? " +
        "WHERE cliente_id = ?";

    private static final String DESATIVAR =
        "UPDATE clientes SET ativo = 0 WHERE cliente_id = ?";

    private static final String COUNT =
        "SELECT COUNT(*) FROM clientes WHERE ativo = 1";

    @Override
    public Cliente salvar(Cliente cliente) {
        try (Connection conn = ConexaoOracle.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(INSERT,
                     new String[]{"CLIENTE_ID"})) {

            pstmt.setString(1, cliente.getNome());
            pstmt.setString(2, cliente.getEmail());
            pstmt.setObject(3, cliente.getTelefone());
            pstmt.setObject(4, cliente.getCpf());
            pstmt.setObject(5, cliente.getCidade());
            pstmt.setObject(6, cliente.getEstado());
            pstmt.executeUpdate();

            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) cliente.setId(rs.getLong(1));
            }
            return cliente;

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao salvar cliente", e);
        }
    }

    @Override
    public Optional<Cliente> buscarPorId(Long id) {
        try (Connection conn = ConexaoOracle.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SELECT_BY_ID)) {

            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return Optional.of(mapear(rs));
            }
            return Optional.empty();

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao buscar cliente por id", e);
        }
    }

    @Override
    public List<Cliente> listarTodos() {
        List<Cliente> lista = new ArrayList<>();
        try (Connection conn = ConexaoOracle.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SELECT_ALL);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) lista.add(mapear(rs));
            return lista;

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao listar clientes", e);
        }
    }

    @Override
    public Optional<Cliente> buscarPorEmail(String email) {
        try (Connection conn = ConexaoOracle.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SELECT_BY_EMAIL)) {

            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return Optional.of(mapear(rs));
            }
            return Optional.empty();

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao buscar por email", e);
        }
    }

    @Override
    public Cliente atualizar(Cliente cliente) {
        try (Connection conn = ConexaoOracle.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(UPDATE)) {

            pstmt.setString(1, cliente.getNome());
            pstmt.setString(2, cliente.getEmail());
            pstmt.setObject(3, cliente.getTelefone());
            pstmt.setObject(4, cliente.getCpf());
            pstmt.setObject(5, cliente.getCidade());
            pstmt.setObject(6, cliente.getEstado());
            pstmt.setLong(7, cliente.getId());

            int linhas = pstmt.executeUpdate();
            if (linhas == 0) throw new RuntimeException("Cliente não encontrado: " + cliente.getId());
            return cliente;

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao atualizar cliente", e);
        }
    }

    @Override
    public void desativar(Long id) {
        try (Connection conn = ConexaoOracle.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(DESATIVAR)) {

            pstmt.setLong(1, id);
            int linhas = pstmt.executeUpdate();
            if (linhas == 0) throw new RuntimeException("Cliente não encontrado: " + id);

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao desativar cliente", e);
        }
    }

    @Override
    public List<Cliente> buscarPorEstado(String estado) {
        String sql = SELECT_ALL.replace("WHERE ativo = 1",
                "WHERE ativo = 1 AND estado = ?");
        // (alternativa: usar método separado com SQL dedicado)
        List<Cliente> lista = new ArrayList<>();
        try (Connection conn = ConexaoOracle.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                 "SELECT cliente_id, nome, email, telefone, cpf, cidade, estado, ativo, data_cadastro " +
                 "FROM clientes WHERE ativo = 1 AND estado = ? ORDER BY nome")) {

            pstmt.setString(1, estado);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
            return lista;

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao buscar por estado", e);
        }
    }

    @Override
    public int contar() {
        try (Connection conn = ConexaoOracle.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(COUNT);
             ResultSet rs = pstmt.executeQuery()) {

            return rs.next() ? rs.getInt(1) : 0;

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao contar clientes", e);
        }
    }

    private Cliente mapear(ResultSet rs) throws SQLException {
        Cliente c = new Cliente();
        c.setId(rs.getLong("cliente_id"));
        c.setNome(rs.getString("nome"));
        c.setEmail(rs.getString("email"));
        c.setTelefone(rs.getString("telefone"));
        c.setCpf(rs.getString("cpf"));
        c.setCidade(rs.getString("cidade"));
        c.setEstado(rs.getString("estado"));
        c.setAtivo(rs.getInt("ativo") == 1);
        java.sql.Date d = rs.getDate("data_cadastro");
        if (d != null) c.setDataCadastro(d.toLocalDate());
        return c;
    }
}
```

---

## Resumo do Tópico

| Conceito | Como usar |
|----------|----------|
| Connection Pool | `HikariCP.getConnection()` em try-with-resources |
| Transação manual | `setAutoCommit(false)` → `commit()` ou `rollback()` |
| Savepoint | `conn.setSavepoint()` → `conn.rollback(savepoint)` |
| Padrão DAO | Interface + implementação específica do banco |

---

## Exercícios

### Básico
1. Configure o HikariCP com as configurações do Oracle local e teste a conexão
2. Implemente o `ProdutoDao` com os métodos: `salvar()`, `buscarPorId()`, `listarTodos()`, `atualizar()`, `desativar()`
3. Teste o pool: abra 21 conexões simultâneas e veja o que acontece com `maximumPoolSize=20`

### Intermediário
4. Implemente uma transação que: insere um pedido, insere seus itens e baixa o estoque — com rollback total em caso de erro
5. Adicione `buscarPorEstado(String estado)` e `buscarPorCidade(String cidade)` no DAO
6. Monitore o pool via JMX ou logging: configure `config.setLeakDetectionThreshold(5000)` e provoque um leak

### Avançado
7. Implemente o padrão Unit of Work: agrupe múltiplas operações DAO em uma única transação passando a Connection como parâmetro
8. Crie um `RepositorioGenerico<T, ID>` com operações CRUD genéricas via reflection
9. Compare performance: 10.000 inserções com pool vs sem pool
