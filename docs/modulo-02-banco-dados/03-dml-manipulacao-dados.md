# 03 — DML: Manipulação de Dados

## Revisão do Tópico Anterior
Você criou as tabelas do projeto com DDL: `CREATE TABLE`, sequences, constraints e índices. Agora vamos popular e consultar dados com DML.

---

## O que é DML?

**DML — Data Manipulation Language** opera sobre os **dados** dentro das tabelas:
- `INSERT` — insere novos registros
- `SELECT` — consulta dados
- `UPDATE` — atualiza registros existentes
- `DELETE` — remove registros

Diferente do DDL, o DML suporta **transações** — você pode desfazer com `ROLLBACK`.

---

## INSERT — Inserindo Dados

### Sintaxe básica

```sql
-- Inserindo em todas as colunas (na ordem do CREATE TABLE)
INSERT INTO categorias (nome, descricao)
VALUES ('Eletrônicos', 'Computadores, smartphones, acessórios');

INSERT INTO categorias (nome, descricao)
VALUES ('Livros', 'Livros técnicos e literatura');

INSERT INTO categorias (nome, descricao)
VALUES ('Móveis', 'Móveis para escritório e home office');

-- Confirmar (obrigatório para persistir)
COMMIT;
```

### Populando todas as tabelas do projeto

```sql
-- CATEGORIAS
INSERT INTO categorias (nome, descricao) VALUES ('Eletrônicos', 'Computadores, tablets e smartphones');
INSERT INTO categorias (nome, descricao) VALUES ('Livros', 'Livros técnicos e literatura em geral');
INSERT INTO categorias (nome, descricao) VALUES ('Periféricos', 'Mouse, teclado, monitor e acessórios');
INSERT INTO categorias (nome, descricao) VALUES ('Móveis', 'Cadeiras, mesas e móveis para escritório');

-- PRODUTOS (referenciando categorias por ID)
INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Notebook Dell Inspiron 15', 3499.90, 25, 1);

INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Smartphone Samsung Galaxy A54', 1799.00, 50, 1);

INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Clean Code - Robert C. Martin', 89.90, 100, 2);

INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Effective Java - Joshua Bloch', 99.90, 80, 2);

INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Mouse Logitech MX Master 3', 399.00, 40, 3);

INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Teclado Mecânico Keychron K2', 599.00, 20, 3);

INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Monitor LG 27" 4K', 2299.00, 15, 3);

INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Cadeira Ergonômica Premium', 1299.00, 30, 4);

-- CLIENTES
INSERT INTO clientes (nome, email, telefone, cpf, cidade, estado)
VALUES ('Ana Lima', 'ana.lima@email.com', '(11) 99999-1111', '111.111.111-11', 'São Paulo', 'SP');

INSERT INTO clientes (nome, email, telefone, cpf, cidade, estado)
VALUES ('Bruno Costa', 'bruno.costa@email.com', '(21) 98888-2222', '222.222.222-22', 'Rio de Janeiro', 'RJ');

INSERT INTO clientes (nome, email, telefone, cpf, cidade, estado)
VALUES ('Carlos Souza', 'carlos.souza@email.com', '(31) 97777-3333', '333.333.333-33', 'Belo Horizonte', 'MG');

INSERT INTO clientes (nome, email, telefone, cpf, cidade, estado)
VALUES ('Diana Ferreira', 'diana.ferreira@email.com', NULL, '444.444.444-44', 'Curitiba', 'PR');

INSERT INTO clientes (nome, email, telefone, cpf, cidade, estado)
VALUES ('Eduardo Alves', 'eduardo@email.com', '(41) 96666-5555', '555.555.555-55', 'Porto Alegre', 'RS');

-- PEDIDOS
INSERT INTO pedidos (cliente_id, status)
VALUES (1, 'CONFIRMADO');   -- Ana Lima

INSERT INTO pedidos (cliente_id, status)
VALUES (1, 'ENTREGUE');     -- Ana Lima (segundo pedido)

INSERT INTO pedidos (cliente_id, status)
VALUES (2, 'PENDENTE');     -- Bruno Costa

INSERT INTO pedidos (cliente_id, status)
VALUES (3, 'ENVIADO');      -- Carlos Souza

-- ITENS_PEDIDO
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (1, 1, 1, 3499.90);   -- Pedido 1: Notebook

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (1, 5, 1, 399.00);    -- Pedido 1: Mouse

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (2, 3, 2, 89.90);     -- Pedido 2: 2x Clean Code

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (2, 4, 1, 99.90);     -- Pedido 2: Effective Java

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (3, 2, 1, 1799.00);   -- Pedido 3: Smartphone

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (4, 7, 1, 2299.00);   -- Pedido 4: Monitor

-- Atualizar valor_total dos pedidos
UPDATE pedidos SET valor_total = (
    SELECT NVL(SUM(quantidade * preco_unitario), 0)
    FROM itens_pedido WHERE pedido_id = pedidos.pedido_id
);

COMMIT;
```

---

## SELECT — Consultando Dados

### Básico

```sql
-- Selecionar todos os campos
SELECT * FROM categorias;

-- Selecionar campos específicos
SELECT nome, preco, estoque FROM produtos;

-- Alias (apelido) para colunas e tabelas
SELECT
    p.nome          AS produto,
    p.preco         AS "Preço (R$)",
    p.estoque       AS "Qtd. Estoque"
FROM produtos p;

-- Expressão na coluna
SELECT
    nome,
    preco,
    preco * 1.1     AS preco_com_frete,
    estoque * preco AS valor_em_estoque
FROM produtos;
```

### WHERE — Filtrando resultados

```sql
-- Operadores de comparação
SELECT * FROM produtos WHERE preco > 1000;
SELECT * FROM produtos WHERE preco BETWEEN 50 AND 500;
SELECT * FROM clientes WHERE estado = 'SP';
SELECT * FROM clientes WHERE estado != 'SP';

-- IS NULL / IS NOT NULL
SELECT * FROM clientes WHERE telefone IS NULL;
SELECT * FROM clientes WHERE telefone IS NOT NULL;

-- LIKE — busca por padrão
-- % = qualquer sequência, _ = qualquer um caractere
SELECT * FROM produtos WHERE nome LIKE '%Mouse%';
SELECT * FROM clientes WHERE email LIKE '%.com';
SELECT * FROM clientes WHERE nome LIKE 'A%';  -- começa com A

-- IN — lista de valores
SELECT * FROM clientes WHERE estado IN ('SP', 'RJ', 'MG');
SELECT * FROM pedidos WHERE status IN ('PENDENTE', 'CONFIRMADO');

-- Operadores lógicos
SELECT * FROM produtos WHERE preco > 1000 AND estoque > 10;
SELECT * FROM produtos WHERE categoria_id = 1 OR categoria_id = 3;
SELECT * FROM produtos WHERE NOT (preco > 3000);

-- NVL: substituir NULL por valor padrão
SELECT nome, NVL(telefone, 'Não informado') AS telefone
FROM clientes;
```

### ORDER BY — Ordenando

```sql
-- Crescente (padrão)
SELECT nome, preco FROM produtos ORDER BY preco;
SELECT nome, preco FROM produtos ORDER BY preco ASC;

-- Decrescente
SELECT nome, preco FROM produtos ORDER BY preco DESC;

-- Múltiplos critérios
SELECT nome, preco FROM produtos
ORDER BY categoria_id ASC, preco DESC;

-- Por posição da coluna (evite em produção)
SELECT nome, preco FROM produtos ORDER BY 2 DESC;
```

### Funções de Agregação

```sql
-- COUNT: contar registros
SELECT COUNT(*) AS total_produtos FROM produtos;
SELECT COUNT(*) AS produtos_caros FROM produtos WHERE preco > 1000;
SELECT COUNT(DISTINCT categoria_id) AS total_categorias FROM produtos;

-- SUM, AVG, MIN, MAX
SELECT
    SUM(estoque * preco)    AS valor_total_estoque,
    AVG(preco)              AS preco_medio,
    MIN(preco)              AS menor_preco,
    MAX(preco)              AS maior_preco
FROM produtos;

-- Por categoria: GROUP BY
SELECT
    c.nome          AS categoria,
    COUNT(p.produto_id) AS quantidade_produtos,
    AVG(p.preco)    AS preco_medio,
    SUM(p.estoque)  AS total_estoque
FROM categorias c
JOIN produtos p ON p.categoria_id = c.categoria_id
GROUP BY c.nome
ORDER BY quantidade_produtos DESC;

-- HAVING — filtra após o GROUP BY (como WHERE mas para grupos)
SELECT
    categoria_id,
    COUNT(*) AS total,
    AVG(preco) AS media_preco
FROM produtos
GROUP BY categoria_id
HAVING COUNT(*) >= 2 AND AVG(preco) > 200;
```

### Funções de String

```sql
-- UPPER, LOWER, INITCAP
SELECT UPPER(nome), LOWER(email) FROM clientes;
SELECT INITCAP('ana lima silva') FROM dual;  -- Ana Lima Silva

-- SUBSTR, LENGTH, INSTR
SELECT SUBSTR(nome, 1, 5) FROM clientes;     -- primeiros 5 chars
SELECT LENGTH(nome) AS tamanho FROM clientes;
SELECT INSTR(email, '@') AS pos_arroba FROM clientes;

-- TRIM, LTRIM, RTRIM
SELECT TRIM('  texto com espaços  ') FROM dual;

-- CONCAT e ||
SELECT nome || ' — ' || email AS info FROM clientes;
SELECT CONCAT(nome, CONCAT(' (', estado || ')')) FROM clientes;

-- REPLACE
SELECT REPLACE(telefone, '(', '') FROM clientes;
```

### Funções de Data

```sql
-- Data atual
SELECT SYSDATE FROM dual;          -- DATA atual do servidor
SELECT CURRENT_TIMESTAMP FROM dual;  -- TIMESTAMP atual

-- Formatação
SELECT TO_CHAR(data_cadastro, 'DD/MM/YYYY') AS data FROM clientes;
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') FROM dual;

-- Diferença entre datas
SELECT nome, TRUNC(SYSDATE - data_cadastro) AS dias_cadastrado
FROM clientes;

-- Adicionar dias
SELECT SYSDATE + 30 AS vencimento FROM dual;

-- ADD_MONTHS
SELECT ADD_MONTHS(SYSDATE, 6) AS seis_meses FROM dual;

-- MONTHS_BETWEEN
SELECT MONTHS_BETWEEN(SYSDATE, data_cadastro) AS meses
FROM clientes;
```

### Funções de Número

```sql
-- ROUND, TRUNC, CEIL, FLOOR
SELECT ROUND(3.567, 2) FROM dual;   -- 3.57
SELECT TRUNC(3.999, 0) FROM dual;   -- 3
SELECT CEIL(3.1)       FROM dual;   -- 4
SELECT FLOOR(3.9)      FROM dual;   -- 3

-- MOD: resto da divisão
SELECT MOD(10, 3) FROM dual;  -- 1

-- ABS: valor absoluto
SELECT ABS(-15.5) FROM dual;  -- 15.5

-- Formatação
SELECT TO_CHAR(preco, '999G990D00') AS preco_formatado FROM produtos;
-- Saída: 3.499,90
```

---

## UPDATE — Atualizando Dados

```sql
-- Atualizar um registro específico
UPDATE clientes
SET telefone = '(11) 11111-1111'
WHERE cliente_id = 1;

-- Atualizar múltiplas colunas
UPDATE produtos
SET preco = preco * 1.10,   -- reajuste de 10%
    ativo = 1
WHERE categoria_id = 1;

-- CUIDADO: UPDATE sem WHERE atualiza TODOS os registros!
UPDATE produtos SET estoque = 0;  -- ZERA TUDO!

-- Sempre verifique com SELECT antes:
SELECT * FROM produtos WHERE categoria_id = 1;
-- Depois faça o UPDATE
UPDATE produtos SET preco = preco * 1.10 WHERE categoria_id = 1;
COMMIT;
```

---

## DELETE — Removendo Dados

```sql
-- Remover registro específico
DELETE FROM clientes WHERE cliente_id = 5;

-- Remover com condição
DELETE FROM itens_pedido WHERE pedido_id = 3;

-- CUIDADO: DELETE sem WHERE remove TUDO!
DELETE FROM pedidos;  -- APAGA TODOS OS PEDIDOS!

-- Sempre verifique antes:
SELECT COUNT(*) FROM pedidos WHERE status = 'CANCELADO';
DELETE FROM pedidos WHERE status = 'CANCELADO';
COMMIT;
```

---

## Transações: COMMIT e ROLLBACK

```sql
-- Cenário: transferência de estoque entre produtos
-- Se qualquer operação falhar, devemos desfazer tudo

-- Início implícito da transação (ao executar o primeiro DML)
UPDATE produtos SET estoque = estoque - 5 WHERE produto_id = 1;
UPDATE produtos SET estoque = estoque + 5 WHERE produto_id = 2;

-- Verificar resultado antes de confirmar
SELECT produto_id, estoque FROM produtos WHERE produto_id IN (1, 2);

-- Se tudo ok: confirmar
COMMIT;

-- Se houver problema: desfazer
ROLLBACK;

-- SAVEPOINT — ponto intermediário de salvamento
UPDATE clientes SET cidade = 'São Paulo' WHERE estado = 'SP';
SAVEPOINT sp_cidades;

UPDATE clientes SET cidade = 'Rio de Janeiro' WHERE estado = 'RJ';
-- Ops! Erro nas cidades do RJ
ROLLBACK TO sp_cidades;  -- volta ao savepoint, mantem o UPDATE do SP

COMMIT;
```

---

## DUAL — A Tabela Especial do Oracle

`DUAL` é uma tabela especial com uma linha e uma coluna, usada para calcular expressões sem tabela real:

```sql
SELECT 2 + 2 FROM dual;                  -- 4
SELECT UPPER('oracle') FROM dual;         -- ORACLE
SELECT SYSDATE FROM dual;                 -- data atual
SELECT seq_clientes.NEXTVAL FROM dual;    -- próximo valor da sequence
SELECT seq_clientes.CURRVAL FROM dual;    -- valor atual da sequence
```

---

## Resumo do Tópico

| Comando | O que faz |
|---------|----------|
| `INSERT INTO ... VALUES` | Insere um registro |
| `SELECT ... FROM ... WHERE` | Consulta com filtro |
| `ORDER BY` | Ordena o resultado |
| `GROUP BY / HAVING` | Agrupa e filtra grupos |
| `UPDATE ... SET ... WHERE` | Atualiza registros |
| `DELETE FROM ... WHERE` | Remove registros |
| `COMMIT` | Confirma a transação |
| `ROLLBACK` | Desfaz a transação |
| `SAVEPOINT` | Ponto intermediário de controle |

---

## Exercícios

### Básico
1. Insira 3 novos clientes com cidades e estados diferentes
2. Selecione todos os produtos com preço entre R$100 e R$500, ordenados pelo preço
3. Encontre todos os clientes cujo email termina com `.com` e não tem telefone cadastrado

### Intermediário
4. Calcule o valor total do estoque por categoria (quantidade × preço, agrupado por categoria)
5. Atualize o preço de todos os produtos da categoria 'Livros' com um desconto de 5%
6. Encontre os pedidos cujo valor_total é maior que a média de todos os pedidos

### Avançado
7. Escreva um UPDATE que recalcula o `valor_total` de todos os pedidos baseado nos itens
8. Use SAVEPOINT para: atualizar preços de eletrônicos, verificar o resultado, e depois fazer rollback só nessa operação
9. Escreva uma query que encontra clientes que nunca fizeram pedidos (dica: subquery com NOT IN)
