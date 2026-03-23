# 02 — DDL: Criação e Alteração de Tabelas

## Revisão do Tópico Anterior
Você aprendeu o que é um banco relacional, instalou o Oracle com Docker e conectou via DBeaver. Agora vamos criar as estruturas (tabelas) do nosso projeto de e-commerce.

---

## O que é DDL?

**DDL — Data Definition Language** são os comandos SQL que definem a **estrutura** do banco:
- `CREATE` — cria objetos (tabela, sequence, índice, view)
- `ALTER` — modifica estrutura existente
- `DROP` — remove objetos
- `TRUNCATE` — remove todos os dados de uma tabela (sem WHERE)

> No Oracle, comandos DDL fazem **COMMIT automático** — não podem ser desfeitos com ROLLBACK.

---

## Tipos de Dados do Oracle

| Tipo | Descrição | Exemplo de Uso |
|------|-----------|----------------|
| `NUMBER(p,s)` | Número com precisão p e escala s | `preco NUMBER(10,2)` |
| `NUMBER` | Inteiro sem limite definido | `id NUMBER` |
| `VARCHAR2(n)` | Texto variável até n caracteres | `nome VARCHAR2(100)` |
| `CHAR(n)` | Texto fixo com n caracteres | `uf CHAR(2)` |
| `DATE` | Data e hora (sem fuso) | `data_cadastro DATE` |
| `TIMESTAMP` | Data e hora com precisão | `criado_em TIMESTAMP` |
| `CLOB` | Texto longo (até 4GB) | Observações longas |
| `BLOB` | Dados binários (até 4GB) | Arquivos, imagens |
| `BOOLEAN` | Não existe no Oracle! Use `NUMBER(1)` | `ativo NUMBER(1)` |

---

## Criando o Schema do Projeto

Vamos criar o schema de e-commerce completo. Execute no DBeaver conectado ao Oracle.

### Passo 1: Sequences para IDs

```sql
-- Sequences geram IDs únicos e sequenciais
-- Usadas na coluna DEFAULT ou chamadas explicitamente

CREATE SEQUENCE seq_categorias
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE seq_produtos
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE seq_clientes
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE seq_pedidos
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE seq_itens_pedido
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
```

### Passo 2: Tabela CATEGORIAS

```sql
CREATE TABLE categorias (
    categoria_id  NUMBER          DEFAULT seq_categorias.NEXTVAL PRIMARY KEY,
    nome          VARCHAR2(100)   NOT NULL,
    descricao     VARCHAR2(500),
    ativa         NUMBER(1)       DEFAULT 1 NOT NULL,
    criado_em     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT ck_categorias_ativa CHECK (ativa IN (0, 1)),
    CONSTRAINT uq_categorias_nome  UNIQUE (nome)
);

COMMENT ON TABLE  categorias           IS 'Categorias de produtos do e-commerce';
COMMENT ON COLUMN categorias.ativa     IS '1=Ativa, 0=Inativa';
```

### Passo 3: Tabela PRODUTOS

```sql
CREATE TABLE produtos (
    produto_id    NUMBER          DEFAULT seq_produtos.NEXTVAL PRIMARY KEY,
    nome          VARCHAR2(150)   NOT NULL,
    descricao     VARCHAR2(1000),
    preco         NUMBER(10,2)    NOT NULL,
    estoque       NUMBER          DEFAULT 0 NOT NULL,
    categoria_id  NUMBER          NOT NULL,
    ativo         NUMBER(1)       DEFAULT 1 NOT NULL,
    criado_em     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT fk_produtos_categoria
        FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id),
    CONSTRAINT ck_produtos_preco   CHECK (preco >= 0),
    CONSTRAINT ck_produtos_estoque CHECK (estoque >= 0),
    CONSTRAINT ck_produtos_ativo   CHECK (ativo IN (0, 1))
);

COMMENT ON TABLE  produtos            IS 'Catálogo de produtos disponíveis';
COMMENT ON COLUMN produtos.preco      IS 'Preço em reais (R$)';
COMMENT ON COLUMN produtos.estoque    IS 'Quantidade em estoque';
```

### Passo 4: Tabela CLIENTES

```sql
CREATE TABLE clientes (
    cliente_id     NUMBER          DEFAULT seq_clientes.NEXTVAL PRIMARY KEY,
    nome           VARCHAR2(150)   NOT NULL,
    email          VARCHAR2(200)   NOT NULL,
    telefone       VARCHAR2(20),
    cpf            VARCHAR2(14),
    cidade         VARCHAR2(100),
    estado         CHAR(2),
    data_cadastro  DATE            DEFAULT SYSDATE NOT NULL,
    ativo          NUMBER(1)       DEFAULT 1 NOT NULL,

    CONSTRAINT uq_clientes_email CHECK (email LIKE '%@%'),
    CONSTRAINT uq_clientes_cpf   UNIQUE (cpf),
    CONSTRAINT ck_clientes_ativo CHECK (ativo IN (0, 1))
);

-- Índice para busca frequente por email
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_clientes_nome  ON clientes(nome);

COMMENT ON TABLE  clientes               IS 'Cadastro de clientes';
COMMENT ON COLUMN clientes.estado        IS 'Sigla do estado (UF) - 2 caracteres';
```

### Passo 5: Tabela PEDIDOS

```sql
CREATE TABLE pedidos (
    pedido_id    NUMBER         DEFAULT seq_pedidos.NEXTVAL PRIMARY KEY,
    cliente_id   NUMBER         NOT NULL,
    data_pedido  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status       VARCHAR2(20)   DEFAULT 'PENDENTE' NOT NULL,
    valor_total  NUMBER(12,2)   DEFAULT 0 NOT NULL,
    observacao   VARCHAR2(500),

    CONSTRAINT fk_pedidos_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    CONSTRAINT ck_pedidos_status
        CHECK (status IN ('PENDENTE', 'CONFIRMADO', 'EM_PREPARACAO', 'ENVIADO', 'ENTREGUE', 'CANCELADO')),
    CONSTRAINT ck_pedidos_valor_total
        CHECK (valor_total >= 0)
);

CREATE INDEX idx_pedidos_cliente   ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_status    ON pedidos(status);
CREATE INDEX idx_pedidos_data      ON pedidos(data_pedido);
```

### Passo 6: Tabela ITENS_PEDIDO

```sql
CREATE TABLE itens_pedido (
    item_id         NUMBER         DEFAULT seq_itens_pedido.NEXTVAL PRIMARY KEY,
    pedido_id       NUMBER         NOT NULL,
    produto_id      NUMBER         NOT NULL,
    quantidade      NUMBER         NOT NULL,
    preco_unitario  NUMBER(10,2)   NOT NULL,

    CONSTRAINT fk_itens_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id)
        ON DELETE CASCADE,  -- se o pedido for deletado, os itens também são
    CONSTRAINT fk_itens_produto
        FOREIGN KEY (produto_id) REFERENCES produtos(produto_id),
    CONSTRAINT ck_itens_quantidade
        CHECK (quantidade > 0),
    CONSTRAINT ck_itens_preco
        CHECK (preco_unitario >= 0),
    CONSTRAINT uq_itens_pedido_produto
        UNIQUE (pedido_id, produto_id)  -- produto não pode aparecer duas vezes no mesmo pedido
);

CREATE INDEX idx_itens_pedido_id   ON itens_pedido(pedido_id);
CREATE INDEX idx_itens_produto_id  ON itens_pedido(produto_id);
```

---

## Verificando as Tabelas Criadas

```sql
-- Listar tabelas criadas
SELECT table_name FROM user_tables ORDER BY table_name;

-- Ver estrutura de uma tabela
DESC clientes;

-- Ver constraints de uma tabela
SELECT constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name = 'CLIENTES'
ORDER BY constraint_type;

-- Ver índices de uma tabela
SELECT index_name, column_name
FROM user_ind_columns
WHERE table_name = 'CLIENTES'
ORDER BY index_name;
```

---

## ALTER TABLE — Modificando Estrutura

Após criar as tabelas, você pode adicionar, modificar ou remover colunas e constraints:

### Adicionando coluna
```sql
-- Adicionar coluna de CEP nos clientes
ALTER TABLE clientes ADD (cep VARCHAR2(9));

-- Adicionar coluna com valor padrão
ALTER TABLE produtos ADD (destaque NUMBER(1) DEFAULT 0 NOT NULL);
ALTER TABLE produtos ADD CONSTRAINT ck_destaque CHECK (destaque IN (0, 1));
```

### Modificando coluna
```sql
-- Aumentar tamanho de uma coluna
ALTER TABLE clientes MODIFY (telefone VARCHAR2(30));

-- Não é possível diminuir tamanho se há dados!
-- ALTER TABLE clientes MODIFY (nome VARCHAR2(50));  -- ERRO se nomes > 50 chars

-- Adicionar NOT NULL a coluna existente (tabela deve estar vazia ou sem nulls)
ALTER TABLE clientes MODIFY (cidade VARCHAR2(100) NOT NULL);
```

### Removendo coluna
```sql
-- Marcar para remoção (eficiente em tabelas grandes)
ALTER TABLE clientes SET UNUSED COLUMN cep;

-- Remover efetivamente as colunas marcadas como UNUSED
ALTER TABLE clientes DROP UNUSED COLUMNS;

-- Remover coluna diretamente (lento em tabelas grandes)
ALTER TABLE clientes DROP COLUMN destaque;
```

### Adicionando e removendo constraints
```sql
-- Adicionar constraint
ALTER TABLE clientes
ADD CONSTRAINT ck_estado CHECK (estado IN ('AC','AL','AP','AM','BA','CE','DF','ES',
    'GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC',
    'SP','SE','TO'));

-- Remover constraint
ALTER TABLE clientes DROP CONSTRAINT ck_estado;

-- Desabilitar/habilitar constraint
ALTER TABLE clientes DISABLE CONSTRAINT ck_clientes_ativo;
ALTER TABLE clientes ENABLE  CONSTRAINT ck_clientes_ativo;
```

---

## DROP e TRUNCATE

### DROP — remove a tabela completamente
```sql
-- CUIDADO: não tem volta! Remove estrutura E dados
DROP TABLE itens_pedido;

-- Com CASCADE CONSTRAINTS: remove FKs que referenciam esta tabela
DROP TABLE categorias CASCADE CONSTRAINTS;

-- Verificar se existe antes de dropar (Oracle 23c+)
DROP TABLE IF EXISTS tabela_temporaria;

-- Para versões anteriores:
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE tabela_temporaria';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
```

### TRUNCATE — remove todos os dados, mantém estrutura
```sql
-- Remove todos os dados da tabela (muito mais rápido que DELETE sem WHERE)
-- NÃO pode ser desfeito com ROLLBACK (DDL = commit automático)
TRUNCATE TABLE itens_pedido;

-- Diferença entre DELETE e TRUNCATE:
-- DELETE: DML, pode ter WHERE, pode ser desfeito com ROLLBACK, mais lento
-- TRUNCATE: DDL, sem WHERE, não pode ser desfeito, muito mais rápido
```

---

## Script de Reset Completo

Útil para recriar o schema do zero durante o aprendizado:

```sql
-- Script para dropar tudo e recriar (execute ao precisar resetar)
BEGIN
    FOR obj IN (SELECT object_name, object_type
                FROM user_objects
                WHERE object_type IN ('TABLE', 'SEQUENCE')
                ORDER BY object_type DESC) LOOP
        BEGIN
            IF obj.object_type = 'TABLE' THEN
                EXECUTE IMMEDIATE 'DROP TABLE ' || obj.object_name || ' CASCADE CONSTRAINTS';
            ELSIF obj.object_type = 'SEQUENCE' THEN
                EXECUTE IMMEDIATE 'DROP SEQUENCE ' || obj.object_name;
            END IF;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- Agora execute novamente todos os CREATE TABLE e CREATE SEQUENCE
```

---

## Boas Práticas de DDL

1. **Sempre use sequences para IDs** — nunca deixe o código Java gerar o ID
2. **Coluna por coluna, constraint por constraint** — nomeie todas as constraints
3. **Comente tabelas e colunas importantes** — `COMMENT ON TABLE/COLUMN`
4. **Crie índices nas FKs** — Oracle não cria automaticamente
5. **Use VARCHAR2, não CHAR** — CHAR preenche com espaços até o limite
6. **Nunca use boolean** — use `NUMBER(1) DEFAULT 0 CHECK IN (0,1)`
7. **Guarde os scripts DDL versionados** — nunca altere produção na mão

---

## Resumo do Tópico

| Comando | O que faz |
|---------|----------|
| `CREATE TABLE` | Cria nova tabela |
| `CREATE SEQUENCE` | Cria gerador de IDs |
| `CREATE INDEX` | Cria índice para acelerar buscas |
| `ALTER TABLE ADD` | Adiciona coluna ou constraint |
| `ALTER TABLE MODIFY` | Altera definição de coluna |
| `ALTER TABLE DROP` | Remove coluna ou constraint |
| `DROP TABLE` | Remove tabela e dados permanentemente |
| `TRUNCATE TABLE` | Remove todos os dados, mantém estrutura |

---

## Exercícios

### Básico
1. Crie a tabela `FORNECEDORES` com: id, cnpj (único), nome, email, telefone, ativo
2. Adicione à tabela PRODUTOS uma coluna `codigo_barras VARCHAR2(13) UNIQUE`
3. Execute `DESC produtos` e `DESC clientes` e anote as diferenças entre as tabelas

### Intermediário
4. Crie uma sequence `seq_fornecedores` e configure como DEFAULT da coluna id
5. Adicione uma constraint CHECK em PEDIDOS para que `data_pedido` não seja futura
6. Crie um índice composto em ITENS_PEDIDO para `(pedido_id, produto_id)`

### Avançado
7. Escreva um script que recria todo o schema do projeto do zero (drop + create)
8. Por que `ON DELETE CASCADE` foi usado em ITENS_PEDIDO mas não em PRODUTOS → CATEGORIAS?
9. Qual a diferença de performance entre `DELETE FROM pedidos` e `TRUNCATE TABLE pedidos`? Quando usar cada um?
