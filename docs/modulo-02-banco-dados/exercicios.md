# Exercícios — Módulo 02: Banco de Dados com Oracle

Exercícios organizados por tópico em três níveis. Execute cada script no SQL*Plus ou DBeaver contra o Oracle XE local.

> **Convenção:** `[B]` = Básico · `[I]` = Intermediário · `[A]` = Avançado

---

## Tópico 01 — Introdução ao Modelo Relacional

**`[B]`** 1. Explique com suas palavras a diferença entre guardar dados em um arquivo texto e guardar em um banco de dados relacional. Cite pelo menos 3 vantagens do banco.

**`[B]`** 2. Identifique no esquema abaixo quais são as chaves primárias e chaves estrangeiras:
```
CLIENTES (cliente_id, nome, email)
PEDIDOS (pedido_id, cliente_id, data, total)
ITENS (item_id, pedido_id, produto_id, quantidade)
PRODUTOS (produto_id, nome, preco)
```

**`[I]`** 3. Desenhe o diagrama (pode ser texto) das tabelas do exercício 2 mostrando os relacionamentos 1:N e N:N.

---

## Tópico 02 — DDL: Criação de Tabelas

**`[B]`** 4. Crie a sequence e a tabela `CATEGORIAS`:
```sql
-- campos: categoria_id (PK), nome (VARCHAR2 100, NOT NULL, UNIQUE), descricao (VARCHAR2 500)
```

**`[B]`** 5. Crie a tabela `PRODUTOS` com os campos: `produto_id` (PK via sequence), `nome` (NOT NULL), `preco` (NUMBER 10,2, CHECK > 0), `estoque` (NUMBER DEFAULT 0, CHECK >= 0), `categoria_id` (FK para CATEGORIAS), `ativo` (NUMBER(1) DEFAULT 1).

**`[B]`** 6. Altere a tabela `PRODUTOS` para adicionar a coluna `data_cadastro` (DATE) com valor padrão `SYSDATE`.

**`[I]`** 7. Crie a tabela `CLIENTES` com: `cliente_id` (PK), `nome` (NOT NULL, máx 150), `email` (NOT NULL, UNIQUE, máx 200), `cpf` (UNIQUE, máx 14), `telefone` (máx 20), `cidade` (máx 100), `estado` (CHAR 2, CHECK em lista das 27 siglas UF), `ativo` (NUMBER(1) DEFAULT 1), `data_cadastro` (DATE DEFAULT SYSDATE).

**`[I]`** 8. Crie as tabelas `PEDIDOS` e `ITENS_PEDIDO`:
- `PEDIDOS`: `pedido_id`, `cliente_id` (FK), `status` (CHECK IN ('PENDENTE','CONFIRMADO','CANCELADO','ENTREGUE')), `total` (NUMBER 10,2), `data_pedido` (DATE DEFAULT SYSDATE)
- `ITENS_PEDIDO`: `item_id`, `pedido_id` (FK), `produto_id` (FK), `quantidade` (NOT NULL, > 0), `preco_unitario` (NOT NULL, > 0)

**`[A]`** 9. Crie índices para otimizar as seguintes buscas:
- Clientes por estado
- Pedidos por cliente e status
- Produtos por categoria e ativo=1

Explique por que cada índice melhora cada consulta específica.

---

## Tópico 03 — DML: Manipulação de Dados

**`[B]`** 10. Insira pelo menos 3 categorias, 10 produtos (distribuídos nas categorias) e 5 clientes. Use `INSERT` explícito com todos os campos.

**`[B]`** 11. Escreva queries `SELECT` para:
- Todos os produtos com `preco > 50` ordenados por preço crescente
- Clientes cadastrados no mês atual (`EXTRACT(MONTH FROM data_cadastro)`)
- Contagem de produtos por categoria (`GROUP BY`)

**`[B]`** 12. Atualize todos os produtos da categoria `'Eletrônicos'` com um reajuste de 10% no preço. Use `UPDATE` com subquery para encontrar o `categoria_id`.

**`[I]`** 13. Crie um pedido completo em uma transação:
```sql
-- 1. INSERT em PEDIDOS
-- 2. INSERT de 3 itens em ITENS_PEDIDO
-- 3. UPDATE PEDIDOS.total = soma dos itens
-- 4. UPDATE PRODUTOS.estoque -= quantidade (para cada item)
-- 5. COMMIT
```
Teste o `ROLLBACK`: insira um item com produto inexistente e verifique que tudo é desfeito.

**`[I]`** 14. Use funções Oracle para:
- Formatar todos os nomes de clientes em maiúsculas: `UPPER(nome)`
- Mostrar preços formatados como `'R$ 1.299,90'`: use `TO_CHAR`
- Listar produtos sem estoque substituindo `NULL` por `0`: `NVL`

**`[A]`** 15. Implemente um `SAVEPOINT` no cenário: processar 3 pedidos em sequência. Se o 2º falhar, use `ROLLBACK TO SAVEPOINT` para desfazer apenas ele e continuar com o 3º.

---

## Tópico 04 — Relacionamentos e JOINs

**`[B]`** 16. Escreva um `INNER JOIN` entre `PEDIDOS` e `CLIENTES` que retorna: nome do cliente, data do pedido e total.

**`[B]`** 17. Escreva um `LEFT JOIN` entre `CLIENTES` e `PEDIDOS` que mostra TODOS os clientes, inclusive os que não fizeram nenhum pedido (total = 0 nesse caso).

**`[I]`** 18. Escreva a query que retorna o **ticket médio por cliente** (total médio dos pedidos), ordenando do maior para o menor. Use `INNER JOIN`, `GROUP BY` e `AVG`.

**`[I]`** 19. Escreva a query que retorna os **10 produtos mais vendidos** (maior quantidade total nos itens). Use `JOIN`, `GROUP BY`, `ORDER BY DESC` e `FETCH FIRST 10 ROWS ONLY`.

**`[I]`** 20. Use subquery para encontrar os clientes que gastaram **acima da média** de todos os clientes:
```sql
-- WHERE total_cliente > (SELECT AVG(total_pedido) FROM ...)
```

**`[A]`** 21. Use **window functions** para rankear os produtos mais vendidos por categoria:
```sql
SELECT
    c.nome AS categoria,
    p.nome AS produto,
    SUM(i.quantidade) AS total_vendido,
    RANK() OVER (PARTITION BY c.categoria_id ORDER BY SUM(i.quantidade) DESC) AS rank_categoria
FROM ...
```

**`[A]`** 22. Escreva a query que mostra, para cada pedido, o valor acumulado do cliente até aquela data:
```sql
-- SUM(total) OVER (PARTITION BY cliente_id ORDER BY data_pedido)
```

---

## Desafio Integrador — Relatórios de E-commerce

Use o schema completo criado nos exercícios acima para escrever os seguintes relatórios:

**`[B]`** R1. **Estoque crítico**: produtos com `estoque < 5`, mostrando nome, categoria e estoque atual.

**`[B]`** R2. **Resumo de vendas por mês**: total de pedidos e valor total agrupados por mês/ano.

**`[I]`** R3. **Clientes inativos**: clientes que não fizeram nenhum pedido nos últimos 90 dias (use `SYSDATE - 90`).

**`[I]`** R4. **Ranking de categorias**: categorias ordenadas por faturamento total (soma dos itens vendidos).

**`[I]`** R5. **Análise de conversão**: clientes cadastrados vs clientes que fizeram pelo menos 1 pedido. Mostre o percentual de conversão.

**`[A]`** R6. **Crie uma VIEW** chamada `VW_RESUMO_PEDIDOS` que consolida: cliente, total de pedidos, valor total gasto, data do primeiro pedido e data do último pedido.

**`[A]`** R7. Use `EXPLAIN PLAN FOR` nas queries R3 e R4. Compare o plano com e sem os índices criados no exercício 9. Documente a diferença no número de operações.

---

*Exercícios do Módulo 02 — 22 exercícios + 7 relatórios de desafio*
