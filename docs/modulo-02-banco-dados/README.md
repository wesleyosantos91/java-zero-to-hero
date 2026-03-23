# Módulo 02 — Banco de Dados Relacional com Oracle

## Visão Geral

Este módulo apresenta os fundamentos de bancos de dados relacionais com foco no Oracle Database, o SGBD mais utilizado em ambientes corporativos no Brasil e no mundo. Ao finalizar este módulo, você será capaz de modelar, criar e consultar bancos de dados relacionais com confiança, utilizando SQL padrão com as particularidades do Oracle.

O conhecimento adquirido aqui é pré-requisito direto para o Módulo 03 (JDBC), onde você aprenderá a conectar aplicações Java ao banco de dados.

---

## Ementa Completa

### 1. Introdução a Bancos de Dados Relacionais
- O problema que bancos de dados resolvem
- Diferença entre armazenar dados em arquivos e em um SGBD
- O modelo relacional: tabelas, linhas, colunas e relacionamentos
- Principais SGBDs do mercado: Oracle, PostgreSQL, MySQL, SQL Server
- Por que Oracle é predominante no ambiente corporativo
- Conceito de Schema e organização do banco
- A linguagem SQL: categorias DDL, DML, DCL e TCL
- Configuração do ambiente: Oracle com Docker

### 2. DDL — Definição de Estrutura
- Tipos de dados Oracle: NUMBER, VARCHAR2, CHAR, DATE, TIMESTAMP, CLOB, BLOB
- Criação de tabelas com `CREATE TABLE`
- Constraints: PRIMARY KEY, NOT NULL, UNIQUE, CHECK, DEFAULT
- Definição de constraints inline e out-of-line
- Alteração de tabelas com `ALTER TABLE`
- Remoção de tabelas com `DROP TABLE`
- Diferença entre `TRUNCATE` e `DELETE`
- Sequences para geração de IDs

### 3. DML — Manipulação de Dados
- Inserção de dados com `INSERT`
- Consulta de dados com `SELECT`
- Filtros com `WHERE`
- Ordenação com `ORDER BY`
- Agrupamento com `GROUP BY` e funções de agregação
- Atualização com `UPDATE`
- Remoção com `DELETE`
- Controle de transação: `COMMIT` e `ROLLBACK`

### 4. Relacionamentos e JOINs
- Chaves estrangeiras (`FOREIGN KEY`)
- Tipos de relacionamento: 1:1, 1:N e N:N
- Tabelas associativas para relacionamentos N:N
- Integridade referencial: `ON DELETE CASCADE` e `ON DELETE SET NULL`
- `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`
- Subqueries simples e correlacionadas
- Índices: conceito, criação e boas práticas

### 5. Exercícios e Projeto Prático
- Revisão geral do módulo
- 15+ exercícios graduais de SQL
- Gabarito comentado
- Projeto completo: Sistema de Clientes e Pedidos
- Desafio avançado: relatório de vendas por categoria

---

## Objetivos de Aprendizagem

Ao concluir este módulo, você será capaz de:

1. **Explicar** o que é um banco de dados relacional e por que ele é preferível ao armazenamento em arquivos para sistemas corporativos.
2. **Identificar** as categorias da linguagem SQL (DDL, DML, DCL, TCL) e saber quando aplicar cada uma.
3. **Criar** tabelas no Oracle com os tipos de dados e constraints adequados.
4. **Inserir, consultar, atualizar e remover** dados com segurança, incluindo o uso correto de transações.
5. **Modelar** relacionamentos entre tabelas usando chaves estrangeiras.
6. **Escrever** queries com JOINs para combinar informações de múltiplas tabelas.
7. **Subir** um ambiente Oracle local com Docker e conectar com uma ferramenta visual.
8. **Reconhecer** particularidades do Oracle SQL que diferem de outros SGBDs.

---

## Pré-requisitos

Antes de iniciar este módulo, você deve ter concluído:

- **Módulo 01 — Java e Orientação a Objetos**: lógica de programação, variáveis, controle de fluxo e noções de orientação a objetos em Java.

Ferramentas necessárias no seu computador:
- **Docker Desktop** instalado e em execução
- **DBeaver** (gratuito) ou **Oracle SQL Developer** para conectar ao banco
- Terminal/linha de comando funcional

Conhecimentos prévios úteis (não obrigatórios):
- Noções básicas de modelagem de dados
- Familiaridade com o conceito de tabelas (como planilhas Excel)

---

## Estrutura dos Arquivos

```
modulo-02-banco-dados/
├── README.md                          ← Este arquivo (visão geral do módulo)
├── 01-introducao-bd-relacional.md     ← Conceitos, modelo relacional, ambiente
├── 02-ddl-criacao-tabelas.md          ← Criação e alteração de estruturas
├── 03-dml-manipulacao-dados.md        ← Inserção, consulta, atualização, remoção
├── 04-relacionamentos-e-joins.md      ← FK, JOINs, subqueries, índices
└── 05-exercicios-e-projeto.md         ← Exercícios práticos e projeto final
```

**Sequência recomendada:** leia os arquivos em ordem numérica. Cada arquivo pressupõe o conteúdo do anterior.

---

## Schema do Projeto Prático

Durante todo o módulo, trabalharemos com um schema de e-commerce simplificado composto pelas seguintes tabelas:

```
CATEGORIAS          PRODUTOS               CLIENTES
-----------         --------               --------
categoria_id (PK)   produto_id (PK)        cliente_id (PK)
nome                nome                   nome
descricao           descricao              email
                    preco                  telefone
                    estoque                cidade
                    categoria_id (FK)      estado
                                           data_cadastro

PEDIDOS                     ITENS_PEDIDO
-------                     ------------
pedido_id (PK)              item_id (PK)
cliente_id (FK)             pedido_id (FK)
data_pedido                 produto_id (FK)
status                      quantidade
valor_total                 preco_unitario
observacao
```

Este schema serve como fio condutor do aprendizado: você criará as tabelas no módulo de DDL, populará com dados no módulo de DML e consultará com JOINs no módulo de relacionamentos.

---

## Checklist de Conclusão

Marque cada item conforme você avança no módulo. Só passe para o próximo módulo quando todos estiverem marcados.

### Conceitos Fundamentais
- [ ] Consigo explicar a diferença entre arquivo e banco de dados
- [ ] Sei o que é um SGBD e cito pelo menos três exemplos
- [ ] Entendo o modelo relacional: tabela, linha, coluna, chave
- [ ] Conheço as quatro categorias do SQL (DDL, DML, DCL, TCL)

### Ambiente
- [ ] Subi o Oracle com Docker usando o `docker-compose.oracle.yml`
- [ ] Verifiquei que o container está saudável com `docker ps`
- [ ] Consigo conectar no banco com DBeaver ou SQL Developer
- [ ] Sei verificar logs do Docker quando algo dá errado

### DDL
- [ ] Criei as tabelas do projeto (CATEGORIAS, PRODUTOS, CLIENTES, PEDIDOS, ITENS_PEDIDO)
- [ ] Defini as constraints corretas em cada tabela (PK, NOT NULL, UNIQUE, CHECK)
- [ ] Criei as sequences para geração de IDs
- [ ] Usei `ALTER TABLE` para adicionar uma coluna em uma tabela existente
- [ ] Sei a diferença entre `DROP TABLE` e `TRUNCATE`

### DML
- [ ] Inseri dados nas cinco tabelas do projeto
- [ ] Escrevi ao menos cinco SELECTs com cláusulas WHERE diferentes
- [ ] Usei funções de agregação (COUNT, SUM, AVG) em pelo menos uma query
- [ ] Fiz um UPDATE com WHERE para não afetar todos os registros
- [ ] Fiz um DELETE com WHERE e usei ROLLBACK para desfazer
- [ ] Usei COMMIT para confirmar uma transação

### Relacionamentos e JOINs
- [ ] Escrevi um INNER JOIN entre PEDIDOS e CLIENTES
- [ ] Escrevi um LEFT JOIN para encontrar clientes sem pedidos
- [ ] Criei um índice em uma coluna de busca frequente
- [ ] Escrevi uma subquery em um SELECT

### Projeto Final
- [ ] Completei os 15+ exercícios do arquivo 05
- [ ] Implementei o schema completo do projeto com todos os scripts DDL
- [ ] Populei o banco com os dados de exemplo
- [ ] Executei as 10 consultas práticas do projeto
- [ ] Tentei o desafio avançado do relatório de vendas

---

## Tempo Estimado

| Seção | Tempo Estimado |
|-------|---------------|
| 01 - Introdução e Ambiente | 3-4 horas |
| 02 - DDL | 4-5 horas |
| 03 - DML | 4-5 horas |
| 04 - Relacionamentos e JOINs | 5-6 horas |
| 05 - Exercícios e Projeto | 6-8 horas |
| **Total** | **22-28 horas** |

> Este é um módulo denso e fundamental. Não tenha pressa. Cada conceito de SQL que você aprender aqui será utilizado diariamente na sua carreira como desenvolvedor Java.

---

## Ferramentas de Apoio

### Docker
O banco de dados Oracle é executado localmente via Docker. O arquivo de configuração está em:
```
/home/user/java-zero-to-hero/docker/docker-compose.oracle.yml
```

### Conexão com o banco
- **Host:** localhost
- **Porta:** 1521
- **Serviço (Service Name):** FREEPDB1
- **Usuário da aplicação:** app_user
- **Senha:** app_password
- **Usuário admin:** system / oracle

### DBeaver — Configuração de Conexão
No DBeaver, crie uma nova conexão Oracle com os dados acima. Selecione "Service Name" (não SID) e use `FREEPDB1`.

---

## Próximo Módulo

Após concluir este módulo, você estará pronto para o:

**Módulo 03 — JDBC: Conectando Java ao Oracle**

Onde você aprenderá a usar a API JDBC do Java para executar as queries SQL que aprendeu aqui diretamente de uma aplicação Java, incluindo prepared statements, gerenciamento de transações e boas práticas de conexão.
