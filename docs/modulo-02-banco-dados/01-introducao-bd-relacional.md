# 01 — Introdução a Bancos de Dados Relacionais

> **Objetivo desta seção:** Entender o que é um banco de dados relacional, por que ele existe, como o Oracle se encaixa no mercado corporativo e como subir um ambiente Oracle local com Docker para praticar durante todo o módulo.

---

## 1. O Problema que os Bancos de Dados Resolvem

Imagine que você está desenvolvendo um sistema de gerenciamento de clientes para uma empresa. A empresa tem 50.000 clientes e precisa armazenar nome, e-mail, telefone, endereço, histórico de compras e preferências de cada um.

### Abordagem ingênua: arquivos de texto ou CSV

Uma primeira ideia seria guardar tudo em arquivos:

```
clientes.txt
---
João Silva,joao@email.com,11-9999-0001,São Paulo,SP,2024-01-15
Maria Santos,maria@email.com,21-8888-0002,Rio de Janeiro,RJ,2024-01-16
Carlos Oliveira,carlos@email.com,31-7777-0003,Belo Horizonte,MG,2024-01-17
```

Parece simples, mas agora considere os seguintes cenários:

**Cenário 1: Dois funcionários editam o arquivo ao mesmo tempo**
Funcionário A lê o arquivo, modifica o registro do João e salva. Funcionário B também leu o mesmo arquivo (antes da modificação do A), faz sua alteração e salva. A modificação do funcionário A é **perdida**. Este é o problema de **concorrência**.

**Cenário 2: O sistema cai durante a gravação**
O programa estava salvando 100 registros novos no arquivo, chegou no registro 60 e a energia acabou. Agora o arquivo tem 60 novos clientes, mas estava para ter 100. Os outros 40 se perderam sem aviso. Este é o problema de **atomicidade**.

**Cenário 3: Buscar todos os clientes de São Paulo**
Com um arquivo de 50.000 linhas, seu programa precisa ler **cada linha** do início ao fim para encontrar os clientes de SP. Lento, ineficiente. Este é o problema de **performance em buscas**.

**Cenário 4: Relacionar clientes com pedidos**
Para saber o histórico de compras, você teria um segundo arquivo `pedidos.txt`. Para buscar os pedidos de um cliente específico, você precisaria cruzar os dois arquivos manualmente no código. Complexo e propenso a erros.

### A solução: o Sistema Gerenciador de Banco de Dados (SGBD)

Um SGBD foi projetado especificamente para resolver esses problemas:

| Problema no arquivo | Solução no SGBD |
|---------------------|-----------------|
| Concorrência | Controle de locks e transações |
| Atomicidade | Transações: ou tudo funciona ou nada acontece |
| Performance em buscas | Índices que permitem busca em milissegundos |
| Relacionamentos | Joins e chaves estrangeiras nativos |
| Segurança | Usuários, senhas, permissões granulares |
| Backup | Mecanismos nativos de backup e recuperação |

---

## 2. O que é um Banco de Dados Relacional

O modelo relacional foi proposto por **Edgar F. Codd**, matemático da IBM, em 1970. A ideia central é organizar dados em **relações** — que na prática chamamos de **tabelas**.

### Conceitos fundamentais

**Tabela (Relação):** Uma estrutura bidimensional com linhas e colunas, similar a uma planilha.

```
CLIENTES
+------------+------------------+----------------------+----------+---------+
| cliente_id | nome             | email                | cidade   | estado  |
+------------+------------------+----------------------+----------+---------+
|          1 | João Silva       | joao@email.com       | São Paulo | SP     |
|          2 | Maria Santos     | maria@email.com      | Rio de J. | RJ     |
|          3 | Carlos Oliveira  | carlos@email.com     | B. Horiz. | MG     |
+------------+------------------+----------------------+----------+---------+
```

**Coluna (Atributo):** Define um tipo de dado específico. Cada coluna tem um nome e um tipo (texto, número, data, etc.). No exemplo acima: `cliente_id`, `nome`, `email`, `cidade`, `estado`.

**Linha (Tupla ou Registro):** Representa uma entidade individual. No exemplo, cada linha é um cliente.

**Chave Primária (Primary Key - PK):** Uma coluna (ou conjunto de colunas) que **identifica de forma única** cada linha. Não pode ser nula, não pode se repetir. No exemplo, `cliente_id` é a chave primária: não existem dois clientes com o mesmo ID.

**Chave Estrangeira (Foreign Key - FK):** Uma coluna que referencia a chave primária de outra tabela, criando um **relacionamento**. Por exemplo, na tabela PEDIDOS, a coluna `cliente_id` referencia `cliente_id` de CLIENTES, indicando a qual cliente pertence cada pedido.

### Por que "relacional"?

O nome vem do conceito matemático de **relação** (um conjunto de tuplas). O modelo permite expressar **relacionamentos entre entidades** de forma natural e consistente — daí o nome banco de dados relacional.

---

## 3. SGBD — Sistema Gerenciador de Banco de Dados

O SGBD é o **software** que gerencia o banco de dados. Ele é o intermediário entre sua aplicação e os dados armazenados em disco.

```
[Sua Aplicação Java]
        |
        | SQL
        v
[  SGBD (Oracle)  ] <---> [Dados em disco]
        |
        | Resultados
        v
[Sua Aplicação Java]
```

O SGBD cuida de:
- **Armazenamento:** onde e como os dados ficam no disco
- **Recuperação:** como encontrar dados rapidamente (índices, planos de execução)
- **Segurança:** autenticação, autorização, auditoria
- **Concorrência:** múltiplos usuários simultâneos sem conflitos
- **Integridade:** garantir que as regras do banco são sempre respeitadas
- **Transações:** ACID (Atomicity, Consistency, Isolation, Durability)

### Principais SGBDs do mercado

| SGBD | Empresa | Licença | Perfil típico |
|------|---------|---------|--------------|
| **Oracle Database** | Oracle Corp. | Comercial | Grandes empresas, sistemas críticos |
| **PostgreSQL** | Comunidade | Open Source | Startups, sistemas modernos |
| **MySQL** | Oracle Corp. | Open Source / Comercial | Web, PHP, aplicações menores |
| **SQL Server** | Microsoft | Comercial | Ecossistema Microsoft (.NET) |
| **MariaDB** | Comunidade | Open Source | Fork do MySQL, Web |
| **IBM Db2** | IBM | Comercial | Mainframe, bancos, seguradoras |

---

## 4. Por que Oracle no Contexto Corporativo

Se você vai trabalhar em desenvolvimento Java para empresas de médio e grande porte no Brasil, a probabilidade de encontrar Oracle é **muito alta**. Veja os motivos:

### 4.1 Maturidade e Confiabilidade

O Oracle Database existe desde 1979. Décadas de desenvolvimento resultaram em um produto extremamente maduro, com recursos avançados de alta disponibilidade (Oracle RAC, Data Guard), gerenciamento de memória sofisticado e otimizador de queries poderoso.

### 4.2 Suporte Enterprise

Empresas que dependem do banco de dados para operações críticas — bancos, seguradoras, operadoras de telecomunicações — pagam pelo suporte Oracle justamente porque têm garantia de atendimento 24/7 e SLAs contratuais.

### 4.3 Ecosistema Oracle no Brasil

O Brasil é um dos maiores mercados Oracle do mundo. Sistemas legados (alguns com décadas de histórico) rodam em Oracle. Sistemas governamentais, bancários e de saúde frequentemente usam Oracle. Desenvolvedores Java que conhecem Oracle têm vantagem no mercado.

### 4.4 PL/SQL e recursos proprietários

O Oracle tem recursos que não existem em outros SGBDs: PL/SQL (linguagem procedural proprietária), Autonomous Database, particionamento avançado, compressão, entre outros.

> **Nota prática:** O SQL que você aprenderá aqui é majoritariamente padrão ANSI SQL, válido em qualquer SGBD. As diferenças do Oracle (como `DUAL`, `ROWNUM`, `SEQUENCES`) serão destacadas ao longo do módulo.

---

## 5. Schema: Organizando o Banco de Dados

No Oracle, um **schema** é um container lógico que agrupa objetos do banco de dados (tabelas, views, sequences, procedures) pertencentes a um mesmo usuário/aplicação.

```
Oracle Instance
└── FREEPDB1 (Pluggable Database)
    ├── Schema: SYS (administração)
    ├── Schema: SYSTEM (administração)
    └── Schema: APP_USER (nossa aplicação)
        ├── Tabela: CLIENTES
        ├── Tabela: PEDIDOS
        ├── Tabela: PRODUTOS
        ├── Sequence: SEQ_CLIENTE_ID
        └── ...
```

### Schema vs. Database

No Oracle, o conceito difere de outros SGBDs:
- **MySQL/PostgreSQL:** Você cria múltiplos "databases" dentro do servidor, cada um com suas tabelas.
- **Oracle:** Há uma instância do banco, com **Pluggable Databases (PDBs)**, e dentro de cada PDB há múltiplos **schemas** (um por usuário).

Na prática, quando falamos de "nosso banco" neste curso, estamos falando do schema do usuário `APP_USER` dentro do PDB `FREEPDB1`.

---

## 6. SQL — Structured Query Language

SQL (pronuncia-se "S-Q-L" ou "sequel") é a linguagem padrão para se comunicar com bancos de dados relacionais. Foi padronizada pela ANSI e pela ISO, então o SQL básico funciona em qualquer SGBD relacional (com pequenas variações).

### 6.1 Categorias do SQL

**DDL — Data Definition Language (Linguagem de Definição de Dados)**
Comandos que **definem a estrutura** do banco de dados.
```sql
CREATE TABLE clientes (...);   -- cria uma tabela
ALTER TABLE clientes ADD ...;  -- modifica uma tabela
DROP TABLE clientes;           -- remove uma tabela
TRUNCATE TABLE clientes;       -- remove todos os dados de uma tabela
```

**DML — Data Manipulation Language (Linguagem de Manipulação de Dados)**
Comandos que **manipulam os dados** dentro das estruturas.
```sql
INSERT INTO clientes VALUES (...);       -- insere um registro
SELECT * FROM clientes WHERE ...;       -- consulta registros
UPDATE clientes SET nome = ... WHERE ...; -- atualiza registros
DELETE FROM clientes WHERE ...;         -- remove registros
```

**DCL — Data Control Language (Linguagem de Controle de Dados)**
Comandos que controlam **permissões de acesso**.
```sql
GRANT SELECT ON clientes TO app_user;   -- concede permissão
REVOKE SELECT ON clientes FROM app_user; -- revoga permissão
```

**TCL — Transaction Control Language (Linguagem de Controle de Transação)**
Comandos que controlam **transações**.
```sql
COMMIT;    -- confirma as alterações da transação atual
ROLLBACK;  -- desfaz as alterações da transação atual
SAVEPOINT nome_ponto; -- cria um ponto de salvamento dentro da transação
```

### 6.2 Regras básicas de SQL no Oracle

- Comandos SQL não são case-sensitive: `SELECT` é igual a `select`.
- Strings (texto) usam **aspas simples**: `'São Paulo'` (nunca aspas duplas).
- Nomes de colunas e tabelas: letras, números e underscore. Não usar acentos ou espaços.
- Termine seus comandos com `;` ao executar no SQL*Plus ou em scripts.
- Comentários: `--` para linha única, `/* ... */` para múltiplas linhas.

---

## 7. Configurando o Ambiente: Oracle com Docker

### 7.1 Por que Docker?

Instalar o Oracle Database diretamente é complexo e consome muito espaço. Com Docker, você sobe um Oracle funcional em minutos, sem modificar seu sistema operacional, e pode destruir e recriar o ambiente a qualquer momento.

### 7.2 O arquivo docker-compose.oracle.yml

O repositório já contém o arquivo de configuração em:
```
/home/user/java-zero-to-hero/docker/docker-compose.oracle.yml
```

Veja o conteúdo e a explicação de cada linha:

```yaml
# Oracle local para a trilha
# Este compose sobe Oracle Free com usuario da aplicacao ja criado.

services:
  oracle-free:                          # Nome do serviço no compose
    image: gvenzl/oracle-free:23-slim   # Imagem Docker do Oracle 23c (versão slim)
    container_name: oracle-free-capacitacao  # Nome do container no Docker
    restart: unless-stopped             # Reinicia automaticamente exceto se você parar manualmente
    environment:
      ORACLE_PASSWORD: oracle           # Senha do usuário SYS e SYSTEM (administração)
      APP_USER: app_user                # Cria automaticamente este usuário de aplicação
      APP_USER_PASSWORD: app_password   # Senha do usuário app_user
    ports:
      - "1521:1521"   # Porta padrão do Oracle (host:container)
      - "5500:5500"   # Oracle Enterprise Manager Express (interface web)
    healthcheck:
      test: ["CMD", "healthcheck.sh"]   # Script interno que verifica se o Oracle está pronto
      interval: 20s    # Verifica a cada 20 segundos
      timeout: 10s     # Aguarda até 10 segundos por resposta
      retries: 20      # Tenta 20 vezes antes de considerar falha
      start_period: 60s # Aguarda 60s antes de começar a verificar (Oracle demora para iniciar)
    volumes:
      - oracle-data:/opt/oracle/oradata  # Persiste os dados em um volume Docker

volumes:
  oracle-data:   # Define o volume nomeado para persistência
```

**Por que a imagem `gvenzl/oracle-free:23-slim`?**
- `gvenzl/oracle-free` é uma imagem mantida pela comunidade, amplamente usada e confiável
- `23-slim` refere-se ao Oracle Database 23c Free (versão gratuita oficial da Oracle) na variante slim (menor tamanho)
- A variante slim tem todos os recursos que precisamos para aprender SQL

### 7.3 Subindo o Oracle — passo a passo

**Passo 1: Verificar que o Docker está funcionando**
```bash
docker --version
# Esperado: Docker version 24.x.x ou superior

docker compose version
# Esperado: Docker Compose version v2.x.x ou superior
```

**Passo 2: Navegar até a pasta do docker-compose**
```bash
cd /home/user/java-zero-to-hero/docker
```

**Passo 3: Iniciar o container**
```bash
docker compose -f docker-compose.oracle.yml up -d
```
- `-f docker-compose.oracle.yml` especifica qual arquivo usar
- `-d` significa "detached" (em segundo plano, libera o terminal)

A primeira execução faz o download da imagem (~1.5 GB). Tenha paciência.

**Passo 4: Acompanhar a inicialização**
```bash
docker logs -f oracle-free-capacitacao
```
- `-f` significa "follow" (exibe logs em tempo real)
- Pressione `Ctrl+C` para parar de acompanhar os logs (o container continua rodando)

Aguarde ver a mensagem:
```
#########################
DATABASE IS READY TO USE!
#########################
```
Isso pode levar de 2 a 5 minutos na primeira vez.

**Passo 5: Verificar o status do container**
```bash
docker ps
```

Você verá algo assim:
```
CONTAINER ID   IMAGE                         STATUS                   PORTS
abc123def456   gvenzl/oracle-free:23-slim    Up 5 minutes (healthy)   0.0.0.0:1521->1521/tcp
```

O status `(healthy)` confirma que o Oracle está pronto para receber conexões.

**Passo 6: Testar a conexão via linha de comando (opcional)**
```bash
docker exec -it oracle-free-capacitacao sqlplus app_user/app_password@FREEPDB1
```

Se o SQL*Plus abrir, você está conectado:
```
SQL*Plus: Release 23.0.0.0.0
Connected to:
Oracle Database 23c Free, Release 23.0.0.0.0

SQL>
```

Para sair: `EXIT;`

### 7.4 Comandos úteis do Docker

```bash
# Parar o container (sem destruir os dados)
docker compose -f docker-compose.oracle.yml stop

# Iniciar novamente (após parar)
docker compose -f docker-compose.oracle.yml start

# Parar e remover o container (dados persistem no volume)
docker compose -f docker-compose.oracle.yml down

# Parar, remover container E volume (APAGA OS DADOS)
docker compose -f docker-compose.oracle.yml down -v

# Ver logs das últimas 50 linhas
docker logs --tail 50 oracle-free-capacitacao

# Ver uso de recursos do container
docker stats oracle-free-capacitacao
```

### 7.5 Conectando com DBeaver

O DBeaver é uma ferramenta gráfica gratuita para gerenciar bancos de dados. Baixe em [dbeaver.io](https://dbeaver.io).

**Configurando a conexão:**

1. Abra o DBeaver
2. Clique em **Database > New Database Connection** (ou `Ctrl+Shift+N`)
3. Selecione **Oracle** e clique em **Next**
4. Preencha os campos:
   - **Host:** `localhost`
   - **Port:** `1521`
   - **Database:** `FREEPDB1` (certifique-se de selecionar **Service Name**, não SID)
   - **Username:** `app_user`
   - **Password:** `app_password`
5. Clique em **Test Connection**
   - Se for a primeira vez, o DBeaver baixará o driver JDBC do Oracle automaticamente
6. Clique em **Finish**

**Testando a conexão:**

No DBeaver, abra um editor SQL (clique no ícone de SQL ou `Ctrl+]`) e execute:
```sql
SELECT SYSDATE FROM DUAL;
```

`DUAL` é uma tabela especial do Oracle com uma única linha, usada para executar expressões e funções sem precisar de uma tabela real. `SYSDATE` retorna a data e hora atual do servidor.

Se retornar a data atual, a conexão está funcionando perfeitamente.

### 7.6 Conectando com Oracle SQL Developer

O SQL Developer é a ferramenta oficial da Oracle, gratuita. Disponível em oracle.com/tools/sqldev.

1. Abra o SQL Developer
2. Clique no ícone **+** em "Connections" (canto superior esquerdo)
3. Preencha:
   - **Name:** `Oracle Local`
   - **Username:** `app_user`
   - **Password:** `app_password`
   - **Hostname:** `localhost`
   - **Port:** `1521`
   - **Service name:** `FREEPDB1`
4. Clique em **Test** e depois em **Connect**

### 7.7 Solução de Problemas Comuns

**Problema: Container não inicia / erro de porta em uso**
```
Error: Bind for 0.0.0.0:1521 failed: port is already allocated
```
Solução: Outra instância do Oracle (ou outro software) está usando a porta 1521.
```bash
# No Linux/Mac, verificar o que usa a porta 1521
lsof -i :1521

# Parar o processo ou mudar a porta no docker-compose (ex: 1522:1521)
```

**Problema: Container fica em status "starting" por muito tempo**

O Oracle 23c pode demorar 3-8 minutos para iniciar completamente. Verifique os logs:
```bash
docker logs oracle-free-capacitacao | tail -20
```
Aguarde a mensagem "DATABASE IS READY TO USE!".

**Problema: Erro de memória — "ORA-04031: unable to allocate ... bytes"**

O Oracle precisa de pelo menos **2 GB de RAM** para funcionar. Verifique as configurações de memória do Docker Desktop em Settings > Resources.

**Problema: Erro de conexão "Listener refused the connection"**

O container ainda está inicializando. Aguarde o status `(healthy)` aparecer no `docker ps`.

**Problema: DBeaver não conecta mas o container está saudável**

Verifique:
1. O tipo de conexão é **Service Name** (não SID)
2. O Service Name é exatamente `FREEPDB1` (maiúsculas)
3. O usuário é `app_user` (não `system` ou `sys`)

---

## 8. A Tabela DUAL — Particularidade do Oracle

Antes de encerrar a introdução, é importante conhecer a tabela `DUAL`.

O Oracle exige que todo `SELECT` tenha uma cláusula `FROM`. Para executar expressões simples (como calcular `2+2` ou obter a data atual) sem precisar de uma tabela real, o Oracle oferece a tabela `DUAL`.

```sql
-- Calcular expressões
SELECT 2 + 2 FROM DUAL;
-- Resultado: 4

-- Obter data e hora atual
SELECT SYSDATE FROM DUAL;
-- Resultado: 22/03/26

-- Obter data e hora com timestamp
SELECT SYSTIMESTAMP FROM DUAL;
-- Resultado: 22/03/26 14:30:25.123456000 -03:00

-- Converter tipos
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') FROM DUAL;
-- Resultado: 22/03/2026 14:30:25

-- Concatenar strings
SELECT 'Olá, ' || 'Mundo!' FROM DUAL;
-- Resultado: Olá, Mundo!
```

> **Dica Oracle:** No Oracle 23c (a versão que estamos usando), a cláusula `FROM DUAL` é opcional para expressões. Mas é uma boa prática mantê-la por compatibilidade com versões anteriores e código legado que você encontrará nas empresas.

---

## 9. Resumo dos Dados de Conexão

Guarde estas informações — você as usará durante todo o módulo:

| Parâmetro | Valor |
|-----------|-------|
| Host | `localhost` |
| Porta | `1521` |
| Service Name | `FREEPDB1` |
| Usuário da aplicação | `app_user` |
| Senha da aplicação | `app_password` |
| Usuário admin | `system` |
| Senha admin | `oracle` |
| Container Docker | `oracle-free-capacitacao` |

---

## 10. Exercícios Conceituais

Responda sem consultar o material. Se não souber, revise a seção correspondente.

**1.** Cite três problemas que surgem quando armazenamos dados em arquivos de texto ao invés de usar um SGBD.

**2.** O que é a chave primária de uma tabela? Quais as regras que ela deve seguir?

**3.** Explique, com suas palavras, a diferença entre DDL e DML.

**4.** Por que usamos `FROM DUAL` no Oracle?

**5.** Qual é a mensagem que o Oracle exibe nos logs quando está pronto para receber conexões?

**6.** Um desenvolvedor precisa verificar se o container do Oracle está saudável. Qual comando Docker ele deve executar?

**7.** Qual é a diferença entre `COMMIT` e `ROLLBACK`? Em qual categoria do SQL esses comandos se encaixam?

**8.** Em qual categoria do SQL se encaixa o comando `GRANT`? O que ele faz?

**9.** Sua empresa tem um sistema que roda Oracle 11g (versão antiga). Você aprendeu SQL no Oracle 23c Free. O SQL que você aprendeu funcionará no Oracle 11g? Justifique.

**10.** O serviço Oracle está na porta 1521. Como você verificaria, no terminal Linux, se algo está ouvindo nessa porta?

---

## Próxima Seção

No arquivo `02-ddl-criacao-tabelas.md`, você aprenderá a criar as tabelas do nosso projeto de e-commerce, definir tipos de dados, constraints e sequences. Mãos à obra!

---

*Módulo 02 — Banco de Dados Relacional com Oracle*
*Trilha Java Zero to Hero*
