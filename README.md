# Java Zero to Hero

Formação completa de Java para iniciantes absolutos até desenvolvedor júnior/pleno, com foco em **Oracle Database**, **Spring Boot 3** e **Spring Batch**.

Todo o conteúdo está em **português brasileiro**, com exemplos práticos, projetos reais e exercícios graduados.

---

## Trilha de Aprendizado

```
Módulo 1     Módulo 2       Módulo 3     Módulo 4       Módulo 5          Módulo 6
Java OO  →  Oracle SQL  →   JDBC     →  REST API   →  Spring Boot   →  Spring Batch
```

Siga a ordem. Cada módulo depende do anterior.

Para o mapa completo com descrições, carga horária e checklist: [`docs/TRILHA-DE-APRENDIZADO.md`](docs/TRILHA-DE-APRENDIZADO.md)

---

## Módulos

| # | Módulo | Tópicos | Projeto Prático |
|---|--------|---------|----------------|
| 01 | [Java — Orientação a Objetos](docs/modulo-01-java-oo/README.md) | Fundamentos, OOP, Exceções, Collections, Boas Práticas | Sistema de Biblioteca |
| 02 | [Banco de Dados com Oracle](docs/modulo-02-banco-dados/README.md) | DDL, DML, JOINs, Subqueries, Window Functions | Schema e-commerce |
| 03 | [Java + JDBC](docs/modulo-03-jdbc/README.md) | Conexão, PreparedStatement, Transactions, DAO Pattern | CRUD de Clientes |
| 04 | [Fundamentos REST API](docs/modulo-04-rest-api/README.md) | HTTP, REST, JSON, Autenticação, OpenAPI | Documentação de API |
| 05 | [Spring Boot 3](docs/modulo-05-spring-boot/README.md) | Controllers, JPA, Validation, Exception Handling | API REST de Clientes |
| 06 | [Spring Batch](docs/modulo-06-spring-batch/README.md) | Chunk Processing, Import/Export, Particionamento | Processamento de Pedidos |

---

## Pré-Requisitos de Ambiente

```bash
# Java 21+
java -version

# Maven 3.9+
mvn -version

# Docker (para Oracle)
docker -version
```

### Subir Oracle com Docker

```bash
docker compose -f docker/docker-compose.oracle.yml up -d

# Aguardar ~60 segundos e verificar
docker logs oracle-xe | grep "DATABASE IS READY"
```

Conexão: `jdbc:oracle:thin:@localhost:1521/XEPDB1` | user: `javazero` | senha: `senha123`

---

## Estrutura do Repositório

```
java-zero-to-hero/
├── docs/
│   ├── modulo-01-java-oo/          # 9 tópicos + exercicios.md + README
│   ├── modulo-02-banco-dados/      # 5 tópicos + exercicios.md + README
│   ├── modulo-03-jdbc/             # 4 tópicos + exercicios.md + README
│   ├── modulo-04-rest-api/         # 5 tópicos + exercicios.md + README
│   ├── modulo-05-spring-boot/      # 5 tópicos + exercicios.md + README
│   ├── modulo-06-spring-batch/     # 6 tópicos + exercicios.md + README
│   ├── TRILHA-DE-APRENDIZADO.md    # Mapa completo da formação
│   └── 00-como-usar-este-material.md
├── docker/                         # docker-compose.oracle.yml
└── sql/                            # Scripts DDL e DML
```

---

## Como Estudar

1. **Leia** o conteúdo teórico
2. **Digite** os exemplos de código na sua IDE — não copie e cole
3. **Execute** e observe o resultado
4. **Faça** os exercícios Básico → Intermediário → Avançado
5. **Construa** o projeto prático do módulo antes de avançar

### Regra de Ouro

> Não avance para o próximo tópico sem conseguir explicar o anterior com suas próprias palavras.

---

## Referências Rápidas

| Recurso | Link |
|---------|------|
| Trilha completa | [`docs/TRILHA-DE-APRENDIZADO.md`](docs/TRILHA-DE-APRENDIZADO.md) |
| Como usar este material | [`docs/00-como-usar-este-material.md`](docs/00-como-usar-este-material.md) |
| Módulo 1 — Java OO | [`docs/modulo-01-java-oo/`](docs/modulo-01-java-oo/) |
| Módulo 2 — Oracle SQL | [`docs/modulo-02-banco-dados/`](docs/modulo-02-banco-dados/) |
| Módulo 3 — JDBC | [`docs/modulo-03-jdbc/`](docs/modulo-03-jdbc/) |
| Módulo 4 — REST API | [`docs/modulo-04-rest-api/`](docs/modulo-04-rest-api/) |
| Módulo 5 — Spring Boot | [`docs/modulo-05-spring-boot/`](docs/modulo-05-spring-boot/) |
| Módulo 6 — Spring Batch | [`docs/modulo-06-spring-batch/`](docs/modulo-06-spring-batch/) |

---

## Objetivos ao Concluir a Formação

1. Escrever e explicar código Java orientado a objetos com boas práticas
2. Modelar e consultar bancos de dados Oracle com SQL
3. Conectar aplicações Java ao Oracle via JDBC com transações seguras
4. Projetar e documentar APIs REST seguindo padrões do mercado
5. Construir APIs REST completas com Spring Boot 3 + JPA + validação
6. Implementar jobs de processamento em lote com Spring Batch
