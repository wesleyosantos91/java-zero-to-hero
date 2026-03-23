# 05 — Exercícios e Projeto Prático

## Revisão do Módulo

Você concluiu os fundamentos de SQL com Oracle:
- **DDL**: CREATE TABLE, sequences, constraints, ALTER TABLE, DROP
- **DML**: INSERT, SELECT (WHERE, ORDER BY, GROUP BY, funções), UPDATE, DELETE
- **JOINs**: INNER, LEFT, RIGHT, FULL OUTER, subqueries, índices

Este arquivo consolida o aprendizado com exercícios graduais e um projeto completo.

---

## Parte 1: 15 Exercícios Graduais

Todos os exercícios usam o schema do e-commerce criado nos tópicos anteriores.

### Nível Básico (1–5)

**Exercício 1:** Liste todos os produtos ativos com nome e preço, ordenados do mais barato para o mais caro.

```sql
-- GABARITO:
SELECT nome, preco
FROM produtos
WHERE ativo = 1
ORDER BY preco ASC;
```

**Exercício 2:** Quantos clientes cadastrados há por estado? Mostre apenas estados com mais de 1 cliente.

```sql
-- GABARITO:
SELECT estado, COUNT(*) AS total
FROM clientes
WHERE estado IS NOT NULL
GROUP BY estado
HAVING COUNT(*) > 1
ORDER BY total DESC;
```

**Exercício 3:** Liste os clientes cadastrados nos últimos 30 dias.

```sql
-- GABARITO:
SELECT nome, email, data_cadastro
FROM clientes
WHERE data_cadastro >= SYSDATE - 30
ORDER BY data_cadastro DESC;
```

**Exercício 4:** Qual o produto mais caro e o mais barato de cada categoria?

```sql
-- GABARITO:
SELECT
    ca.nome         AS categoria,
    MAX(pr.preco)   AS maior_preco,
    MIN(pr.preco)   AS menor_preco,
    AVG(pr.preco)   AS preco_medio
FROM categorias ca
LEFT JOIN produtos pr ON pr.categoria_id = ca.categoria_id
GROUP BY ca.categoria_id, ca.nome
ORDER BY ca.nome;
```

**Exercício 5:** Liste todos os pedidos com status 'PENDENTE' ou 'CONFIRMADO', com o nome do cliente.

```sql
-- GABARITO:
SELECT
    p.pedido_id,
    c.nome          AS cliente,
    p.status,
    p.data_pedido,
    p.valor_total
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.cliente_id
WHERE p.status IN ('PENDENTE', 'CONFIRMADO')
ORDER BY p.data_pedido;
```

---

### Nível Intermediário (6–10)

**Exercício 6:** Para cada pedido, mostre o pedido_id, cliente, total de itens diferentes, quantidade total de produtos e valor total.

```sql
-- GABARITO:
SELECT
    p.pedido_id,
    c.nome                          AS cliente,
    COUNT(DISTINCT ip.produto_id)   AS itens_distintos,
    SUM(ip.quantidade)              AS qtd_total,
    SUM(ip.quantidade * ip.preco_unitario) AS valor_calculado,
    p.valor_total
FROM pedidos p
JOIN clientes     c  ON c.cliente_id = p.cliente_id
JOIN itens_pedido ip ON ip.pedido_id = p.pedido_id
GROUP BY p.pedido_id, c.nome, p.valor_total
ORDER BY p.pedido_id;
```

**Exercício 7:** Liste produtos cujo estoque está abaixo de 25 unidades e que pertencem à categoria 'Eletrônicos'.

```sql
-- GABARITO:
SELECT
    pr.nome,
    pr.estoque,
    pr.preco,
    ca.nome AS categoria
FROM produtos pr
JOIN categorias ca ON ca.categoria_id = pr.categoria_id
WHERE pr.estoque < 25
  AND ca.nome = 'Eletrônicos'
ORDER BY pr.estoque ASC;
```

**Exercício 8:** Encontre os 3 clientes que mais gastaram, com total de pedidos e valor total.

```sql
-- GABARITO:
SELECT *
FROM (
    SELECT
        c.nome,
        COUNT(p.pedido_id)  AS total_pedidos,
        SUM(p.valor_total)  AS total_gasto
    FROM clientes c
    JOIN pedidos p ON p.cliente_id = c.cliente_id
    WHERE p.status NOT IN ('CANCELADO')
    GROUP BY c.cliente_id, c.nome
    ORDER BY total_gasto DESC
)
WHERE ROWNUM <= 3;
-- Oracle 12c+:
-- FETCH FIRST 3 ROWS ONLY;
```

**Exercício 9:** Liste produtos que nunca foram pedidos.

```sql
-- GABARITO com LEFT JOIN:
SELECT pr.nome, pr.preco, pr.estoque
FROM produtos pr
LEFT JOIN itens_pedido ip ON ip.produto_id = pr.produto_id
WHERE ip.item_id IS NULL;

-- GABARITO com NOT EXISTS:
SELECT nome, preco, estoque
FROM produtos pr
WHERE NOT EXISTS (
    SELECT 1 FROM itens_pedido ip
    WHERE ip.produto_id = pr.produto_id
);
```

**Exercício 10:** Calcule o ticket médio por status de pedido.

```sql
-- GABARITO:
SELECT
    status,
    COUNT(*)            AS total_pedidos,
    AVG(valor_total)    AS ticket_medio,
    MIN(valor_total)    AS menor_pedido,
    MAX(valor_total)    AS maior_pedido,
    SUM(valor_total)    AS total_receita
FROM pedidos
GROUP BY status
ORDER BY ticket_medio DESC;
```

---

### Nível Avançado (11–15)

**Exercício 11:** Para cada cliente, mostre o pedido mais recente com seu status e valor.

```sql
-- GABARITO com subquery:
SELECT
    c.nome,
    p.pedido_id,
    p.status,
    p.valor_total,
    p.data_pedido
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.data_pedido = (
    SELECT MAX(p2.data_pedido)
    FROM pedidos p2
    WHERE p2.cliente_id = c.cliente_id
)
ORDER BY c.nome;
```

**Exercício 12:** Rankeie os produtos dentro de cada categoria por preço (do mais caro ao mais barato), mostrando a posição no ranking.

```sql
-- GABARITO com função analítica:
SELECT
    ca.nome         AS categoria,
    pr.nome         AS produto,
    pr.preco,
    RANK() OVER (PARTITION BY pr.categoria_id ORDER BY pr.preco DESC) AS posicao
FROM produtos pr
JOIN categorias ca ON ca.categoria_id = pr.categoria_id
ORDER BY ca.nome, posicao;
```

**Exercício 13:** Calcule a participação percentual de cada categoria na receita total.

```sql
-- GABARITO:
SELECT
    ca.nome                     AS categoria,
    SUM(ip.quantidade * ip.preco_unitario) AS receita,
    ROUND(
        SUM(ip.quantidade * ip.preco_unitario) /
        SUM(SUM(ip.quantidade * ip.preco_unitario)) OVER () * 100,
        2
    ) AS percentual
FROM itens_pedido ip
JOIN produtos   pr ON pr.produto_id   = ip.produto_id
JOIN categorias ca ON ca.categoria_id = pr.categoria_id
JOIN pedidos     p ON p.pedido_id     = ip.pedido_id
WHERE p.status != 'CANCELADO'
GROUP BY ca.categoria_id, ca.nome
ORDER BY receita DESC;
```

**Exercício 14:** Liste os pares de produtos que apareceram juntos em pelo menos um pedido.

```sql
-- GABARITO (self-join em itens_pedido):
SELECT DISTINCT
    pr1.nome    AS produto_1,
    pr2.nome    AS produto_2,
    COUNT(DISTINCT ip1.pedido_id) AS vezes_juntos
FROM itens_pedido ip1
JOIN itens_pedido ip2 ON ip1.pedido_id = ip2.pedido_id
                     AND ip1.produto_id < ip2.produto_id  -- evita duplicatas e auto-combinação
JOIN produtos pr1 ON pr1.produto_id = ip1.produto_id
JOIN produtos pr2 ON pr2.produto_id = ip2.produto_id
GROUP BY pr1.produto_id, pr1.nome, pr2.produto_id, pr2.nome
ORDER BY vezes_juntos DESC;
```

**Exercício 15:** Escreva uma query que mostra, para cada mês, o total de pedidos, receita e a variação percentual em relação ao mês anterior.

```sql
-- GABARITO com LAG (Oracle):
SELECT
    mes,
    total_pedidos,
    receita,
    LAG(receita) OVER (ORDER BY mes) AS receita_mes_anterior,
    ROUND(
        (receita - LAG(receita) OVER (ORDER BY mes)) /
        NULLIF(LAG(receita) OVER (ORDER BY mes), 0) * 100,
        2
    ) AS variacao_percentual
FROM (
    SELECT
        TO_CHAR(data_pedido, 'YYYY-MM') AS mes,
        COUNT(*)                         AS total_pedidos,
        SUM(valor_total)                 AS receita
    FROM pedidos
    WHERE status != 'CANCELADO'
    GROUP BY TO_CHAR(data_pedido, 'YYYY-MM')
)
ORDER BY mes;
```

---

## Parte 2: Projeto Final — E-commerce Completo

### Objetivo
Implementar o schema completo do e-commerce, populá-lo com dados realistas e executar consultas de relatório.

### Script Completo de Criação e População

```sql
-- ===== RESET DO AMBIENTE =====
BEGIN
    FOR obj IN (SELECT object_name, object_type FROM user_objects
                WHERE object_type IN ('TABLE','SEQUENCE')
                ORDER BY object_type DESC) LOOP
        BEGIN
            IF obj.object_type = 'TABLE' THEN
                EXECUTE IMMEDIATE 'DROP TABLE '||obj.object_name||' CASCADE CONSTRAINTS';
            ELSE
                EXECUTE IMMEDIATE 'DROP SEQUENCE '||obj.object_name;
            END IF;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- ===== SEQUENCES =====
CREATE SEQUENCE seq_categorias  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_produtos    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_clientes    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_pedidos     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_itens       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ===== TABELAS =====
CREATE TABLE categorias (
    categoria_id NUMBER DEFAULT seq_categorias.NEXTVAL PRIMARY KEY,
    nome         VARCHAR2(100) NOT NULL,
    CONSTRAINT uq_cat_nome UNIQUE (nome)
);

CREATE TABLE produtos (
    produto_id   NUMBER DEFAULT seq_produtos.NEXTVAL PRIMARY KEY,
    nome         VARCHAR2(150) NOT NULL,
    preco        NUMBER(10,2)  NOT NULL,
    estoque      NUMBER        DEFAULT 0,
    categoria_id NUMBER        NOT NULL REFERENCES categorias(categoria_id),
    CONSTRAINT ck_prod_preco   CHECK (preco >= 0),
    CONSTRAINT ck_prod_estoque CHECK (estoque >= 0)
);

CREATE TABLE clientes (
    cliente_id    NUMBER DEFAULT seq_clientes.NEXTVAL PRIMARY KEY,
    nome          VARCHAR2(150) NOT NULL,
    email         VARCHAR2(200) NOT NULL,
    cidade        VARCHAR2(100),
    estado        CHAR(2),
    data_cadastro DATE DEFAULT SYSDATE,
    CONSTRAINT uq_cli_email UNIQUE (email)
);

CREATE TABLE pedidos (
    pedido_id   NUMBER DEFAULT seq_pedidos.NEXTVAL PRIMARY KEY,
    cliente_id  NUMBER NOT NULL REFERENCES clientes(cliente_id),
    status      VARCHAR2(20) DEFAULT 'PENDENTE',
    valor_total NUMBER(12,2)  DEFAULT 0,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_ped_status CHECK (status IN
        ('PENDENTE','CONFIRMADO','EM_PREPARACAO','ENVIADO','ENTREGUE','CANCELADO'))
);

CREATE TABLE itens_pedido (
    item_id        NUMBER DEFAULT seq_itens.NEXTVAL PRIMARY KEY,
    pedido_id      NUMBER NOT NULL REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
    produto_id     NUMBER NOT NULL REFERENCES produtos(produto_id),
    quantidade     NUMBER NOT NULL,
    preco_unitario NUMBER(10,2) NOT NULL,
    CONSTRAINT ck_it_qtd CHECK (quantidade > 0),
    CONSTRAINT uq_it_ped_prod UNIQUE (pedido_id, produto_id)
);

-- ===== ÍNDICES =====
CREATE INDEX idx_prod_cat   ON produtos(categoria_id);
CREATE INDEX idx_ped_cli    ON pedidos(cliente_id);
CREATE INDEX idx_ped_status ON pedidos(status);
CREATE INDEX idx_it_ped     ON itens_pedido(pedido_id);
CREATE INDEX idx_it_prod    ON itens_pedido(produto_id);

-- ===== DADOS =====
INSERT INTO categorias (nome) VALUES ('Eletrônicos');
INSERT INTO categorias (nome) VALUES ('Livros');
INSERT INTO categorias (nome) VALUES ('Periféricos');
INSERT INTO categorias (nome) VALUES ('Móveis');

INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES ('Notebook Dell', 3499.90, 25, 1);
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES ('Smartphone Samsung', 1799.00, 50, 1);
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES ('Clean Code', 89.90, 100, 2);
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES ('Effective Java', 99.90, 80, 2);
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES ('Mouse Logitech', 399.00, 40, 3);
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES ('Teclado Mecânico', 599.00, 20, 3);
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES ('Monitor LG 27"', 2299.00, 15, 3);
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES ('Cadeira Ergonômica', 1299.00, 30, 4);

INSERT INTO clientes (nome, email, cidade, estado) VALUES ('Ana Lima','ana@email.com','São Paulo','SP');
INSERT INTO clientes (nome, email, cidade, estado) VALUES ('Bruno Costa','bruno@email.com','Rio de Janeiro','RJ');
INSERT INTO clientes (nome, email, cidade, estado) VALUES ('Carlos Souza','carlos@email.com','Belo Horizonte','MG');
INSERT INTO clientes (nome, email, cidade, estado) VALUES ('Diana Ferreira','diana@email.com','Curitiba','PR');
INSERT INTO clientes (nome, email, cidade, estado) VALUES ('Eduardo Alves','eduardo@email.com','Porto Alegre','RS');

INSERT INTO pedidos (cliente_id, status) VALUES (1, 'ENTREGUE');
INSERT INTO pedidos (cliente_id, status) VALUES (1, 'CONFIRMADO');
INSERT INTO pedidos (cliente_id, status) VALUES (2, 'PENDENTE');
INSERT INTO pedidos (cliente_id, status) VALUES (3, 'ENVIADO');
INSERT INTO pedidos (cliente_id, status) VALUES (4, 'ENTREGUE');

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (1, 1, 1, 3499.90);
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (1, 5, 1, 399.00);
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (2, 3, 2, 89.90);
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (2, 4, 1, 99.90);
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (3, 2, 1, 1799.00);
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (4, 7, 1, 2299.00);
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (5, 8, 1, 1299.00);
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES (5, 6, 1, 599.00);

UPDATE pedidos SET valor_total = (
    SELECT NVL(SUM(quantidade * preco_unitario), 0)
    FROM itens_pedido WHERE pedido_id = pedidos.pedido_id
);

COMMIT;
```

### 10 Consultas de Relatório para Executar

```sql
-- R1: Resumo geral do banco de dados
SELECT 'Categorias' AS objeto, COUNT(*) AS total FROM categorias UNION ALL
SELECT 'Produtos',    COUNT(*) FROM produtos UNION ALL
SELECT 'Clientes',    COUNT(*) FROM clientes UNION ALL
SELECT 'Pedidos',     COUNT(*) FROM pedidos UNION ALL
SELECT 'Itens',       COUNT(*) FROM itens_pedido;

-- R2: Produtos com estoque crítico (< 20)
SELECT nome, estoque FROM produtos WHERE estoque < 20 ORDER BY estoque;

-- R3: Receita total (pedidos não cancelados)
SELECT TO_CHAR(SUM(valor_total), 'R$999G990D00') AS receita_total
FROM pedidos WHERE status != 'CANCELADO';

-- R4: Ranking de clientes
SELECT c.nome, COUNT(p.pedido_id) pedidos, SUM(p.valor_total) total
FROM clientes c LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
GROUP BY c.cliente_id, c.nome ORDER BY total DESC NULLS LAST;

-- R5: Produtos mais vendidos
SELECT pr.nome, SUM(ip.quantidade) total_vendido
FROM itens_pedido ip JOIN produtos pr ON pr.produto_id = ip.produto_id
GROUP BY pr.produto_id, pr.nome ORDER BY total_vendido DESC;

-- R6: Pedidos entregues vs pendentes
SELECT status, COUNT(*) total, SUM(valor_total) receita
FROM pedidos GROUP BY status ORDER BY total DESC;

-- R7: Clientes sem pedidos
SELECT c.nome FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.cliente_id
WHERE p.pedido_id IS NULL;

-- R8: Valor médio dos pedidos por estado do cliente
SELECT c.estado, AVG(p.valor_total) ticket_medio, COUNT(p.pedido_id) pedidos
FROM clientes c JOIN pedidos p ON p.cliente_id = c.cliente_id
GROUP BY c.estado ORDER BY ticket_medio DESC;

-- R9: Itens do pedido mais caro
SELECT pr.nome, ip.quantidade, ip.preco_unitario, ip.quantidade*ip.preco_unitario subtotal
FROM itens_pedido ip
JOIN produtos pr ON pr.produto_id = ip.produto_id
WHERE ip.pedido_id = (SELECT pedido_id FROM pedidos WHERE valor_total = (SELECT MAX(valor_total) FROM pedidos));

-- R10: Receita por categoria
SELECT ca.nome, SUM(ip.quantidade * ip.preco_unitario) receita
FROM itens_pedido ip
JOIN produtos pr ON pr.produto_id = ip.produto_id
JOIN categorias ca ON ca.categoria_id = pr.categoria_id
GROUP BY ca.categoria_id, ca.nome ORDER BY receita DESC;
```

---

## Desafio Avançado: Relatório de Vendas

Escreva uma query que produza o seguinte relatório:

```
RELATÓRIO DE DESEMPENHO POR CATEGORIA
======================================
Categoria    | Produtos | Qtd Vendida | Receita    | % Receita | Ticket Médio
-------------|----------|-------------|------------|-----------|-------------
Eletrônicos  |    2     |      3      | R$5.298,90 |   63,2%   |  R$2.649,45
Periféricos  |    3     |      2      | R$2.898,00 |   34,6%   |  R$1.449,00
Móveis       |    1     |      2      | R$1.898,00 |   22,6%   |    R$949,00
Livros       |    2     |      3      |   R$279,70 |    3,3%   |     R$93,23
```

```sql
-- SOLUÇÃO:
SELECT
    ca.nome                     AS categoria,
    COUNT(DISTINCT pr.produto_id) AS total_produtos,
    NVL(SUM(ip.quantidade), 0)  AS qtd_vendida,
    NVL(SUM(ip.quantidade * ip.preco_unitario), 0) AS receita,
    NVL(ROUND(
        SUM(ip.quantidade * ip.preco_unitario) /
        SUM(SUM(ip.quantidade * ip.preco_unitario)) OVER () * 100, 1
    ), 0) AS perc_receita,
    NVL(AVG(ip.preco_unitario), 0) AS ticket_medio
FROM categorias ca
LEFT JOIN produtos pr     ON pr.categoria_id = ca.categoria_id
LEFT JOIN itens_pedido ip ON ip.produto_id   = pr.produto_id
LEFT JOIN pedidos p       ON p.pedido_id     = ip.pedido_id
    AND p.status != 'CANCELADO'
GROUP BY ca.categoria_id, ca.nome
ORDER BY receita DESC;
```

---

## Checklist Final do Módulo 2

- [ ] Criei todas as tabelas com constraints corretas
- [ ] Entendi a diferença entre DDL e DML
- [ ] Usei sequences para geração de IDs
- [ ] Escrevi SELECTs com WHERE, ORDER BY, GROUP BY e HAVING
- [ ] Usei as principais funções (NVL, TO_CHAR, SYSDATE, COUNT, SUM, AVG)
- [ ] Escrevi INNER JOIN e LEFT JOIN com resultado correto
- [ ] Identifiquei clientes sem pedidos com LEFT JOIN + IS NULL
- [ ] Escrevi pelo menos uma subquery
- [ ] Criei índices nas colunas de FK e busca frequente
- [ ] Completei os 15 exercícios
- [ ] Executei as 10 queries do projeto
- [ ] Completei o desafio avançado

**Parabéns! Módulo 2 concluído. Próximo: Módulo 03 — JDBC.**
