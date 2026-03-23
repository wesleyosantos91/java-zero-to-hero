# 04 — Relacionamentos e JOINs

## Revisão do Tópico Anterior
Você aprendeu INSERT, SELECT (com WHERE, ORDER BY, GROUP BY, funções), UPDATE, DELETE e transações. Agora vamos combinar dados de múltiplas tabelas com JOINs.

---

## Relacionamentos entre Tabelas

### Tipos de Relacionamento

**1:1 (Um para Um)**
```
FUNCIONARIO (1) ────── (1) CARTAO_PONTO
Um funcionário tem exatamente um cartão ponto
```

**1:N (Um para Muitos)** — o mais comum
```
CLIENTE (1) ────── (N) PEDIDO
Um cliente pode ter muitos pedidos
Um pedido pertence a exatamente um cliente
```

**N:N (Muitos para Muitos)** — requer tabela associativa
```
PEDIDO (N) ────── (N) PRODUTO
Um pedido pode ter muitos produtos
Um produto pode estar em muitos pedidos

→ Tabela intermediária: ITENS_PEDIDO
PEDIDO (1) ────── (N) ITENS_PEDIDO (N) ────── (1) PRODUTO
```

### Chaves Estrangeiras (FK)

```sql
-- FK define o relacionamento no banco
-- A coluna cliente_id em PEDIDOS referencia cliente_id em CLIENTES

-- Consultar as FK existentes
SELECT
    a.constraint_name,
    a.table_name         AS tabela_filho,
    a.column_name        AS coluna_fk,
    c.table_name         AS tabela_pai,
    c.column_name        AS coluna_pk
FROM user_cons_columns a
JOIN user_constraints  b ON a.constraint_name = b.constraint_name
JOIN user_cons_columns c ON b.r_constraint_name = c.constraint_name
WHERE b.constraint_type = 'R'
ORDER BY a.table_name;
```

---

## JOINs — Combinando Tabelas

### Conceito Visual

```
CLIENTES            PEDIDOS
---------           -------
id | nome           id | cliente_id | status
1  | Ana            1  | 1          | CONFIRMADO
2  | Bruno          2  | 1          | ENTREGUE
3  | Carlos         3  | 2          | PENDENTE

INNER JOIN: apenas registros com correspondência em AMBAS as tabelas
  → Ana (tem pedido), Bruno (tem pedido) — Carlos (sem pedido) fica de fora

LEFT JOIN: todos da tabela ESQUERDA + correspondência da direita (null se não tiver)
  → Ana, Bruno, Carlos (Carlos aparece com null nos campos de pedido)

RIGHT JOIN: todos da tabela DIREITA + correspondência da esquerda
  → Pedido 1, Pedido 2, Pedido 3

FULL OUTER JOIN: todos de ambas as tabelas (null quando não há correspondência)
```

---

## INNER JOIN

Retorna apenas registros com correspondência em **ambas** as tabelas:

```sql
-- Pedidos com nome do cliente
SELECT
    p.pedido_id,
    c.nome          AS cliente,
    c.cidade,
    p.status,
    p.valor_total,
    p.data_pedido
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.cliente_id
ORDER BY p.data_pedido DESC;

-- Produtos com nome da categoria
SELECT
    pr.nome             AS produto,
    pr.preco,
    pr.estoque,
    ca.nome             AS categoria
FROM produtos pr
INNER JOIN categorias ca ON pr.categoria_id = ca.categoria_id
ORDER BY ca.nome, pr.preco;

-- JOIN de 3 tabelas: itens do pedido com produto e pedido
SELECT
    p.pedido_id,
    c.nome              AS cliente,
    pr.nome             AS produto,
    ip.quantidade,
    ip.preco_unitario,
    ip.quantidade * ip.preco_unitario AS subtotal
FROM itens_pedido ip
INNER JOIN pedidos  p  ON ip.pedido_id  = p.pedido_id
INNER JOIN clientes c  ON p.cliente_id  = c.cliente_id
INNER JOIN produtos pr ON ip.produto_id = pr.produto_id
ORDER BY p.pedido_id, pr.nome;
```

---

## LEFT JOIN (LEFT OUTER JOIN)

Retorna **todos** os registros da tabela esquerda, com ou sem correspondência na direita:

```sql
-- Clientes COM e SEM pedidos
SELECT
    c.nome,
    c.email,
    COUNT(p.pedido_id)  AS total_pedidos,
    NVL(SUM(p.valor_total), 0) AS total_gasto
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
GROUP BY c.cliente_id, c.nome, c.email
ORDER BY total_gasto DESC;

-- Apenas clientes SEM pedidos
SELECT
    c.nome,
    c.email,
    c.data_cadastro
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.pedido_id IS NULL;  -- sem correspondência = NULL na tabela direita

-- Produtos que nunca foram vendidos
SELECT
    pr.nome,
    pr.preco,
    pr.estoque
FROM produtos pr
LEFT JOIN itens_pedido ip ON ip.produto_id = pr.produto_id
WHERE ip.item_id IS NULL;
```

---

## RIGHT JOIN e FULL OUTER JOIN

```sql
-- RIGHT JOIN: todos da tabela direita
-- (equivalente a LEFT JOIN com tabelas invertidas — raramente usado)
SELECT
    c.nome,
    p.pedido_id,
    p.status
FROM pedidos p
RIGHT JOIN clientes c ON p.cliente_id = c.cliente_id;
-- Mesmo resultado que:
SELECT c.nome, p.pedido_id, p.status
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id;

-- FULL OUTER JOIN: todos de ambas as tabelas
SELECT
    c.nome      AS cliente,
    p.pedido_id,
    p.status
FROM clientes c
FULL OUTER JOIN pedidos p ON c.cliente_id = p.cliente_id;
```

---

## Subqueries

Queries aninhadas — o resultado de uma query é usado como entrada de outra:

### Subquery no WHERE

```sql
-- Produtos mais caros que a média
SELECT nome, preco
FROM produtos
WHERE preco > (SELECT AVG(preco) FROM produtos)
ORDER BY preco DESC;

-- Clientes que fizeram pedido acima de R$2000
SELECT nome, email
FROM clientes
WHERE cliente_id IN (
    SELECT DISTINCT cliente_id
    FROM pedidos
    WHERE valor_total > 2000
);

-- Clientes que NUNCA fizeram pedido
SELECT nome, email
FROM clientes
WHERE cliente_id NOT IN (
    SELECT DISTINCT cliente_id FROM pedidos
);
```

### Subquery no FROM (inline view)

```sql
-- Ranking de clientes por total gasto
SELECT
    cliente,
    total_pedidos,
    total_gasto,
    RANK() OVER (ORDER BY total_gasto DESC) AS ranking
FROM (
    SELECT
        c.nome              AS cliente,
        COUNT(p.pedido_id)  AS total_pedidos,
        NVL(SUM(p.valor_total), 0) AS total_gasto
    FROM clientes c
    LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
    GROUP BY c.cliente_id, c.nome
) resumo
ORDER BY ranking;
```

### Subquery correlacionada

```sql
-- Produto mais caro de cada categoria
SELECT
    c.nome  AS categoria,
    p.nome  AS produto_mais_caro,
    p.preco
FROM categorias c
JOIN produtos p ON p.categoria_id = c.categoria_id
WHERE p.preco = (
    SELECT MAX(p2.preco)
    FROM produtos p2
    WHERE p2.categoria_id = c.categoria_id  -- correlaciona com a query externa
);
```

### EXISTS / NOT EXISTS

```sql
-- Categorias que têm pelo menos um produto
SELECT nome FROM categorias c
WHERE EXISTS (
    SELECT 1 FROM produtos p
    WHERE p.categoria_id = c.categoria_id
);

-- Categorias SEM produtos
SELECT nome FROM categorias c
WHERE NOT EXISTS (
    SELECT 1 FROM produtos p
    WHERE p.categoria_id = c.categoria_id
);
```

---

## Funções Analíticas (Window Functions)

```sql
-- ROW_NUMBER: numera linhas dentro de uma partição
SELECT
    p.nome,
    c.nome      AS categoria,
    p.preco,
    ROW_NUMBER() OVER (PARTITION BY p.categoria_id ORDER BY p.preco DESC) AS rank_na_categoria
FROM produtos p
JOIN categorias c ON p.categoria_id = c.categoria_id;

-- RANK: ranking com empates (pula números)
-- DENSE_RANK: ranking com empates (não pula)
SELECT
    nome,
    preco,
    RANK()       OVER (ORDER BY preco DESC) AS rank_rank,
    DENSE_RANK() OVER (ORDER BY preco DESC) AS dense_rank
FROM produtos;

-- SUM cumulativo
SELECT
    nome,
    preco,
    SUM(preco) OVER (ORDER BY preco) AS soma_cumulativa
FROM produtos
ORDER BY preco;
```

---

## Índices — Performance de Consulta

### Por que usar índices?

```sql
-- Sem índice: Oracle lê TODAS as linhas (Full Table Scan)
SELECT * FROM clientes WHERE email = 'ana@email.com';
-- Com 1 milhão de clientes: lento!

-- Com índice: Oracle localiza diretamente as linhas (Index Range Scan)
CREATE INDEX idx_clientes_email ON clientes(email);
-- Com 1 milhão de clientes: rápido!
```

### Tipos de índice

```sql
-- Índice simples (mais comum)
CREATE INDEX idx_produtos_preco ON produtos(preco);

-- Índice composto (para queries que filtram por múltiplas colunas)
CREATE INDEX idx_pedidos_cliente_status ON pedidos(cliente_id, status);

-- Índice único (garante unicidade como constraint)
CREATE UNIQUE INDEX idx_clientes_cpf ON clientes(cpf);

-- Índice de função (para buscas com UPPER/LOWER)
CREATE INDEX idx_clientes_email_upper ON clientes(UPPER(email));
-- Uso: WHERE UPPER(email) = 'ANA@EMAIL.COM'
```

### Quando criar e quando não criar índice

**CRIAR índice quando:**
- Coluna usada frequentemente em WHERE
- Coluna de chave estrangeira (FK)
- Coluna usada em JOIN
- Coluna em ORDER BY de queries críticas

**NÃO criar índice quando:**
- Tabela com poucos registros (< 1000 linhas)
- Coluna com poucos valores distintos (ex: `ativo` = 0 ou 1)
- Tabela com muitos INSERTs/UPDATEs (índice tem custo de manutenção)

### Verificar plano de execução

```sql
-- EXPLAIN PLAN: ver como o Oracle vai executar a query
EXPLAIN PLAN FOR
SELECT * FROM clientes WHERE email = 'ana@email.com';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- Procure por: INDEX RANGE SCAN (usa índice) ou TABLE ACCESS FULL (não usa)
```

---

## Queries Práticas do Projeto

```sql
-- 1. Relatório completo de pedidos
SELECT
    p.pedido_id,
    c.nome          AS cliente,
    c.cidade        AS cidade_cliente,
    p.status,
    p.data_pedido,
    COUNT(ip.item_id)           AS qtd_itens,
    SUM(ip.quantidade)          AS qtd_produtos,
    p.valor_total
FROM pedidos p
JOIN clientes     c  ON c.cliente_id  = p.cliente_id
JOIN itens_pedido ip ON ip.pedido_id  = p.pedido_id
GROUP BY p.pedido_id, c.nome, c.cidade, p.status, p.data_pedido, p.valor_total
ORDER BY p.data_pedido DESC;

-- 2. Top 5 produtos mais vendidos
SELECT
    pr.nome             AS produto,
    ca.nome             AS categoria,
    SUM(ip.quantidade)  AS total_vendido,
    SUM(ip.quantidade * ip.preco_unitario) AS receita_total
FROM itens_pedido ip
JOIN produtos   pr ON pr.produto_id   = ip.produto_id
JOIN categorias ca ON ca.categoria_id = pr.categoria_id
GROUP BY pr.produto_id, pr.nome, ca.nome
ORDER BY total_vendido DESC
FETCH FIRST 5 ROWS ONLY;

-- 3. Vendas por categoria
SELECT
    ca.nome         AS categoria,
    COUNT(DISTINCT p.pedido_id) AS total_pedidos,
    SUM(ip.quantidade)          AS total_unidades,
    SUM(ip.quantidade * ip.preco_unitario) AS receita
FROM itens_pedido ip
JOIN produtos   pr ON pr.produto_id   = ip.produto_id
JOIN categorias ca ON ca.categoria_id = pr.categoria_id
JOIN pedidos    p  ON p.pedido_id     = ip.pedido_id
WHERE p.status != 'CANCELADO'
GROUP BY ca.categoria_id, ca.nome
ORDER BY receita DESC;

-- 4. Clientes com maior ticket médio
SELECT
    c.nome,
    COUNT(p.pedido_id)      AS total_pedidos,
    SUM(p.valor_total)      AS total_gasto,
    AVG(p.valor_total)      AS ticket_medio
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.status != 'CANCELADO'
GROUP BY c.cliente_id, c.nome
HAVING COUNT(p.pedido_id) >= 1
ORDER BY ticket_medio DESC;
```

---

## Resumo do Tópico

| Conceito | O que faz |
|----------|----------|
| `INNER JOIN` | Retorna registros com correspondência em ambas as tabelas |
| `LEFT JOIN` | Todos da esquerda + correspondência da direita (null se ausente) |
| `RIGHT JOIN` | Todos da direita + correspondência da esquerda |
| `FULL OUTER JOIN` | Todos de ambas as tabelas |
| Subquery | Query aninhada dentro de outra |
| `EXISTS/NOT EXISTS` | Verifica existência de registros |
| Índice | Estrutura que acelera buscas |
| `EXPLAIN PLAN` | Mostra o plano de execução de uma query |

---

## Exercícios

### Básico
1. Liste todos os pedidos com o nome do cliente correspondente (INNER JOIN)
2. Liste todos os itens do pedido de número 1 com o nome de cada produto
3. Encontre clientes que nunca fizeram pedido (LEFT JOIN + WHERE IS NULL)

### Intermediário
4. Calcule o valor total de cada pedido somando seus itens (GROUP BY + JOIN)
5. Encontre o produto mais caro de cada categoria usando subquery
6. Crie um índice em `pedidos.status` e verifique o plano de execução de uma query que filtra por status

### Avançado
7. Escreva a query do "Relatório de vendas por categoria" (exercício 3 das queries práticas)
8. Usando funções analíticas, rankeie os clientes por total gasto dentro de cada cidade
9. Escreva uma query que detecta produtos em estoque baixo (menos de 10 unidades) que nunca foram pedidos no último mês
