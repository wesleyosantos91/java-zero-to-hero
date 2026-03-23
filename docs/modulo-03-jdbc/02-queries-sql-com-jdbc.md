# 02 — Executando Queries SQL com JDBC

## Revisão do Tópico Anterior
Você fez a primeira conexão com Oracle via JDBC: `DriverManager.getConnection()`, `Connection`, `Statement`, `ResultSet`. Agora vamos executar operações CRUD completas com segurança.

---

## Statement vs PreparedStatement

### Statement — apenas para SQL sem parâmetros variáveis

```java
// Statement: SQL construído por concatenação
String sql = "SELECT * FROM clientes WHERE estado = '" + estado + "'";
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery(sql);
```

**Problema: SQL Injection!** Se o usuário digitar `' OR '1'='1`:
```java
String estado = "' OR '1'='1";
// SQL resultante: SELECT * FROM clientes WHERE estado = '' OR '1'='1'
// Retorna TODOS os registros! Brecha de segurança grave.
```

### PreparedStatement — sempre use para SQL com parâmetros

```java
// PreparedStatement: parâmetros substituídos com segurança (bind variables)
String sql = "SELECT * FROM clientes WHERE estado = ?";
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setString(1, estado);  // índice começa em 1
ResultSet rs = pstmt.executeQuery();
// SQL Injection impossível: o parâmetro é tratado como DADO, não como SQL
```

**Vantagens adicionais do PreparedStatement:**
- Oracle compila o SQL uma vez e reutiliza (melhor performance)
- Código mais legível com muitos parâmetros
- Tipos Java mapeados corretamente para Oracle

---

## Métodos de Execução

```java
PreparedStatement pstmt = conn.prepareStatement(sql);

// Para SELECT — retorna ResultSet
ResultSet rs = pstmt.executeQuery();

// Para INSERT, UPDATE, DELETE — retorna linhas afetadas
int linhasAfetadas = pstmt.executeUpdate();

// Para qualquer tipo (retorna boolean: true se ResultSet, false se update count)
boolean hasResultSet = pstmt.execute();
```

---

## Tipos de Parâmetro do PreparedStatement

```java
PreparedStatement pstmt = conn.prepareStatement(
    "INSERT INTO clientes (nome, email, telefone, cpf, cidade, estado, data_cadastro, ativo) " +
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
);

// Métodos set* mapeiam tipos Java → Oracle
pstmt.setString(1, "Ana Lima");                    // VARCHAR2
pstmt.setString(2, "ana@email.com");               // VARCHAR2
pstmt.setString(3, "(11) 99999-1111");             // VARCHAR2 (ou null)
pstmt.setString(4, "111.111.111-11");              // VARCHAR2
pstmt.setString(5, "São Paulo");                   // VARCHAR2
pstmt.setString(6, "SP");                          // CHAR
pstmt.setDate(7, java.sql.Date.valueOf(LocalDate.now()));  // DATE
pstmt.setInt(8, 1);                                // NUMBER

// Para campos opcionais (nullable):
String telefone = null;
if (telefone != null) {
    pstmt.setString(3, telefone);
} else {
    pstmt.setNull(3, java.sql.Types.VARCHAR);
}

// Ou mais conciso:
pstmt.setObject(3, telefone);  // setObject aceita null automaticamente
```

---

## SELECT com ResultSet

### Navegando no ResultSet

```java
public List<Cliente> listarTodos(Connection conn) throws SQLException {
    List<Cliente> clientes = new ArrayList<>();
    String sql = "SELECT cliente_id, nome, email, telefone, cpf, cidade, estado " +
                 "FROM clientes WHERE ativo = 1 ORDER BY nome";

    try (PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {

        while (rs.next()) {  // avança para o próximo registro
            Cliente c = new Cliente();
            c.setId(rs.getLong("cliente_id"));
            c.setNome(rs.getString("nome"));
            c.setEmail(rs.getString("email"));

            // getString() retorna null se a coluna for NULL no banco
            c.setTelefone(rs.getString("telefone"));
            c.setCpf(rs.getString("cpf"));
            c.setCidade(rs.getString("cidade"));
            c.setEstado(rs.getString("estado"));

            clientes.add(c);
        }
    }
    return clientes;
}
```

### Verificar se coluna era NULL

```java
String telefone = rs.getString("telefone");
if (rs.wasNull()) {
    // a coluna estava NULL no banco
    c.setTelefone("Não informado");
} else {
    c.setTelefone(telefone);
}
```

### Lendo diferentes tipos

```java
// Numéricos
long id          = rs.getLong("cliente_id");
int  estoque     = rs.getInt("estoque");
double preco     = rs.getDouble("preco");
BigDecimal valor = rs.getBigDecimal("valor_total");  // mais preciso para dinheiro

// Datas
java.sql.Date   dataSql    = rs.getDate("data_cadastro");
LocalDate       data       = dataSql != null ? dataSql.toLocalDate() : null;
java.sql.Timestamp ts      = rs.getTimestamp("criado_em");
LocalDateTime   datahora   = ts != null ? ts.toLocalDateTime() : null;

// Boolean (Oracle usa NUMBER(1))
boolean ativo = rs.getInt("ativo") == 1;
```

---

## INSERT — Inserindo e Obtendo o ID Gerado

### INSERT simples

```java
public void inserir(Connection conn, Cliente cliente) throws SQLException {
    String sql = "INSERT INTO clientes (nome, email, telefone, cpf, cidade, estado) " +
                 "VALUES (?, ?, ?, ?, ?, ?)";

    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setString(1, cliente.getNome());
        pstmt.setString(2, cliente.getEmail());
        pstmt.setObject(3, cliente.getTelefone());  // pode ser null
        pstmt.setObject(4, cliente.getCpf());
        pstmt.setObject(5, cliente.getCidade());
        pstmt.setObject(6, cliente.getEstado());

        int linhas = pstmt.executeUpdate();
        System.out.println("Inserido: " + linhas + " registro(s)");
    }
}
```

### INSERT com retorno do ID gerado (Oracle)

```java
public Long inserirRetornandoId(Connection conn, Cliente cliente) throws SQLException {
    String sql = "INSERT INTO clientes (nome, email, cidade, estado) " +
                 "VALUES (?, ?, ?, ?)";

    // RETURN_GENERATED_KEYS instrui o driver a retornar o ID
    try (PreparedStatement pstmt = conn.prepareStatement(sql,
            new String[]{"CLIENTE_ID"})) {  // nome da coluna de ID no Oracle

        pstmt.setString(1, cliente.getNome());
        pstmt.setString(2, cliente.getEmail());
        pstmt.setObject(3, cliente.getCidade());
        pstmt.setObject(4, cliente.getEstado());

        pstmt.executeUpdate();

        // Recuperar o ID gerado
        try (ResultSet rs = pstmt.getGeneratedKeys()) {
            if (rs.next()) {
                Long id = rs.getLong(1);
                cliente.setId(id);
                return id;
            }
        }
    }
    throw new SQLException("Falha ao obter ID gerado");
}
```

---

## UPDATE e DELETE

```java
public int atualizar(Connection conn, Cliente cliente) throws SQLException {
    String sql = "UPDATE clientes SET nome = ?, email = ?, telefone = ?, cidade = ?, estado = ? " +
                 "WHERE cliente_id = ?";

    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setString(1, cliente.getNome());
        pstmt.setString(2, cliente.getEmail());
        pstmt.setObject(3, cliente.getTelefone());
        pstmt.setObject(4, cliente.getCidade());
        pstmt.setObject(5, cliente.getEstado());
        pstmt.setLong(6, cliente.getId());

        int linhas = pstmt.executeUpdate();
        if (linhas == 0) {
            throw new SQLException("Cliente não encontrado: id=" + cliente.getId());
        }
        return linhas;
    }
}

public int deletar(Connection conn, Long id) throws SQLException {
    // NUNCA delete físico em produção! Use soft delete (ativo = 0)
    String sql = "UPDATE clientes SET ativo = 0 WHERE cliente_id = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setLong(1, id);
        return pstmt.executeUpdate();
    }
}

// Se realmente precisar deletar:
public int deletarFisico(Connection conn, Long id) throws SQLException {
    String sql = "DELETE FROM clientes WHERE cliente_id = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setLong(1, id);
        return pstmt.executeUpdate();
    }
}
```

---

## Batch Updates — Eficiência em Inserções em Massa

```java
public void inserirEmMassa(Connection conn, List<Cliente> clientes) throws SQLException {
    String sql = "INSERT INTO clientes (nome, email, cidade, estado) VALUES (?, ?, ?, ?)";

    // Desabilitar auto-commit para controlar a transação
    conn.setAutoCommit(false);
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        int count = 0;
        for (Cliente c : clientes) {
            pstmt.setString(1, c.getNome());
            pstmt.setString(2, c.getEmail());
            pstmt.setObject(3, c.getCidade());
            pstmt.setObject(4, c.getEstado());

            pstmt.addBatch();  // adiciona ao lote
            count++;

            // Executar em lotes de 500 para não sobrecarregar a memória
            if (count % 500 == 0) {
                pstmt.executeBatch();
                conn.commit();
                System.out.println("Lote commitado: " + count + " registros");
            }
        }
        // Executar registros restantes
        pstmt.executeBatch();
        conn.commit();
        System.out.println("Total inserido: " + count + " registros");

    } catch (SQLException e) {
        conn.rollback();  // desfazer tudo em caso de erro
        throw e;
    } finally {
        conn.setAutoCommit(true);
    }
}
```

### Performance: Batch vs um a um

| Cenário | 1.000 registros | 100.000 registros |
|---------|----------------|-------------------|
| INSERT um a um | ~2 segundos | ~200 segundos |
| INSERT em batch (500) | ~0.1 segundos | ~10 segundos |
| **Ganho de performance** | **20x** | **20x** |

---

## Buscas com Filtros Opcionais

```java
public List<Cliente> buscar(Connection conn, String nome, String estado, Boolean ativo)
        throws SQLException {

    StringBuilder sql = new StringBuilder(
        "SELECT cliente_id, nome, email, cidade, estado, ativo FROM clientes WHERE 1=1"
    );
    List<Object> params = new ArrayList<>();

    if (nome != null && !nome.isBlank()) {
        sql.append(" AND UPPER(nome) LIKE ?");
        params.add("%" + nome.toUpperCase() + "%");
    }
    if (estado != null && !estado.isBlank()) {
        sql.append(" AND estado = ?");
        params.add(estado.toUpperCase());
    }
    if (ativo != null) {
        sql.append(" AND ativo = ?");
        params.add(ativo ? 1 : 0);
    }
    sql.append(" ORDER BY nome");

    List<Cliente> resultado = new ArrayList<>();
    try (PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
        for (int i = 0; i < params.size(); i++) {
            pstmt.setObject(i + 1, params.get(i));
        }
        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                resultado.add(mapearCliente(rs));
            }
        }
    }
    return resultado;
}

private Cliente mapearCliente(ResultSet rs) throws SQLException {
    Cliente c = new Cliente();
    c.setId(rs.getLong("cliente_id"));
    c.setNome(rs.getString("nome"));
    c.setEmail(rs.getString("email"));
    c.setCidade(rs.getString("cidade"));
    c.setEstado(rs.getString("estado"));
    c.setAtivo(rs.getInt("ativo") == 1);
    return c;
}
```

---

## Resumo do Tópico

| Conceito | O que usar |
|----------|-----------|
| SQL sem parâmetros | `Statement` |
| SQL com parâmetros | `PreparedStatement` (sempre!) |
| Buscar registros | `executeQuery()` → `ResultSet` |
| Inserir/Atualizar/Deletar | `executeUpdate()` → int (linhas afetadas) |
| Obter ID gerado | `getGeneratedKeys()` |
| Inserção em massa | `addBatch()` + `executeBatch()` |

---

## Exercícios

### Básico
1. Escreva um método `buscarPorId(Long id)` que retorna um `Optional<Cliente>`
2. Implemente `contarTotal()` que retorna o número de clientes ativos
3. Implemente `existeEmail(String email)` que retorna boolean

### Intermediário
4. Adicione paginação ao método `listarTodos()`: parâmetros `pagina` e `tamanhoPagina` (use `FETCH FIRST n ROWS ONLY` no Oracle 12c+)
5. Implemente um método que atualiza **apenas os campos não nulos** do objeto Cliente
6. Escreva um método `inserirLote(List<Cliente>)` com batch de 100 e rollback em caso de erro

### Avançado
7. Demonstre SQL Injection: crie um método vulnerável com Statement e outro seguro com PreparedStatement
8. Implemente um método de busca com filtros dinâmicos (nome, cidade, estado, faixa de data)
9. Meça a diferença de tempo entre 1000 INSERTs individuais vs batch
