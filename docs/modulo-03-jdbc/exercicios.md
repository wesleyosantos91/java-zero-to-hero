# Exercícios — Módulo 03: Java + JDBC

Exercícios práticos com Java puro conectado ao Oracle. Use o schema de clientes e produtos criado no Módulo 02.

> **Convenção:** `[B]` = Básico · `[I]` = Intermediário · `[A]` = Avançado

---

## Tópico 01 — Introdução ao JDBC

**`[B]`** 1. Escreva um programa que abre uma conexão com o Oracle, imprime `"Conectado com sucesso!"` e fecha a conexão no bloco `finally`. Use `DriverManager.getConnection(url, user, pass)`.

**`[B]`** 2. Verifique o que acontece quando a URL de conexão está errada (host inválido, porta errada). Capture a `SQLException` e imprima: o código de erro (`getErrorCode()`), o SQL State (`getSQLState()`) e a mensagem.

**`[I]`** 3. Configure o **HikariCP** com um pool de 3 conexões, timeout de 15s e `connectionTestQuery = "SELECT 1 FROM DUAL"`. Abra 3 conexões simultâneas e observe que a 4ª aguarda. Use `Thread.sleep(1000)` para simular uso.

---

## Tópico 02 — Queries com JDBC

**`[B]`** 4. Escreva um método `listarClientes()` que executa `SELECT * FROM clientes WHERE ativo = 1 ORDER BY nome` e imprime cada linha no formato: `"[1] João Silva — joao@email.com"`.

**`[B]`** 5. Escreva um método `buscarClientePorId(Long id)` que retorna um `Optional<Cliente>`. Use `PreparedStatement` com `?` para o id.

**`[B]`** 6. Escreva o método `inserirCliente(Cliente c)` usando `PreparedStatement`. Após inserir, recupere o `cliente_id` gerado usando `RETURNING cliente_id INTO ?` ou `getGeneratedKeys()`.

**`[I]`** 7. Escreva o método `buscarComFiltros(String estado, String nome)` que monta a query dinamicamente: se `estado != null` adiciona `AND estado = ?`, se `nome != null` adiciona `AND UPPER(nome) LIKE ?`. **Não use concatenação de String** — use `StringBuilder` para o SQL e parâmetros indexados.

**`[I]`** 8. Demonstre **SQL Injection**: crie um método vulnerável com `Statement` e concatenação, e outro seguro com `PreparedStatement`. Use a entrada `"'; DROP TABLE clientes; --"` e mostre a diferença.

**`[I]`** 9. Use **batch update** para inserir 1.000 clientes fictícios. Compare o tempo com inserção um a um. Use `addBatch()` e `executeBatch()` com commit a cada 100 registros.

**`[A]`** 10. Use `ResultSetMetaData` para escrever o método `executarQueryGenerica(String sql)` que imprime os resultados em formato de tabela, descobrindo os nomes e tipos das colunas dinamicamente.

---

## Tópico 03 — Transações e Gerenciamento de Conexão

**`[B]`** 11. Implemente a transferência entre contas em uma transação:
```java
// 1. setAutoCommit(false)
// 2. sacar da conta origem
// 3. depositar na conta destino
// 4. commit se tudo OK, rollback se qualquer exceção
```
Force um erro entre os passos 2 e 3 para confirmar que o rollback funciona.

**`[B]`** 12. Use `SAVEPOINT` em Java para processar uma lista de 5 clientes, onde o 3º tem email inválido. O savepoint deve permitir pular o 3º e continuar com os demais.

**`[I]`** 13. Implemente a interface `ClienteDao` com os métodos:
```java
Optional<Cliente> findById(Long id);
List<Cliente> findAll();
List<Cliente> findByEstado(String estado);
Long save(Cliente cliente);   // retorna o ID gerado
void update(Cliente cliente);
void delete(Long id);
boolean existsByEmail(String email);
```

**`[I]`** 14. Crie `ClienteDaoOracle` implementando `ClienteDao`. Use HikariCP para obter conexões. Garanta que toda conexão é fechada (use try-with-resources).

**`[I]`** 15. Escreva um teste manual do `ClienteDaoOracle`:
- Inserir 3 clientes
- Listar todos
- Buscar por id
- Atualizar o nome do 2º cliente
- Deletar o 3º
- Verificar que a lista final tem 2 itens

**`[A]`** 16. Implemente `ProdutoDao` e `PedidoDao`. O `PedidoDao.salvarPedidoCompleto(Pedido p)` deve inserir o pedido e todos os itens numa única transação. Se qualquer item falhar (produto sem estoque), toda a transação é revertida.

---

## Desafio Integrador — Sistema de Estoque via Console

Construa um sistema CLI completo com menu interativo usando `Scanner`, JDBC e HikariCP:

### Estrutura Esperada

```
src/main/java/
├── br/com/javazero/estoque/
│   ├── Main.java                 (menu principal)
│   ├── dao/
│   │   ├── ProdutoDao.java       (interface)
│   │   └── ProdutoDaoOracle.java (implementação)
│   ├── model/
│   │   └── Produto.java
│   └── service/
│       └── EstoqueService.java   (regras de negócio)
```

### Menu do Sistema

```
=== SISTEMA DE ESTOQUE ===
1. Listar todos os produtos
2. Buscar produto por ID
3. Cadastrar novo produto
4. Atualizar estoque
5. Desativar produto
6. Relatório: produtos com estoque crítico (< 5)
0. Sair
```

### Requisitos por Nível

**`[B]`** — Opções 1, 2 e 3 funcionando com CRUD básico

**`[I]`** — Opções 4 e 5 com transação correta + opção 6 com relatório

**`[A]`** — Adicionar opção 7: "Importar produtos de CSV" lendo arquivo linha a linha e inserindo em batch, reportando ao final: inseridos, ignorados (duplicados) e erros

---

*Exercícios do Módulo 03 — 16 exercícios + desafio integrador*
