# Java Zero to Hero — Formação Profissional em Java, Oracle, JDBC, REST, Spring Boot e Spring Batch

Este repositório foi reconstruído como uma trilha completa para levar uma pessoa do **zero absoluto** até o nível **júnior/pleno inicial**, com foco em prática guiada, fundamentos sólidos e projetos aplicados.

## O que você vai aprender

1. Java Orientado a Objetos
2. Banco Relacional com Oracle + SQL
3. Java com JDBC
4. Fundamentos de REST API
5. Spring Boot para APIs e CRUD
6. Spring Batch para importação/exportação com Oracle

## Estrutura da formação

- `docs/00-visao-geral`: como estudar, ordem da trilha e preparo de ambiente.
- `docs/01-java-oo` até `docs/06-spring-batch`: módulos progressivos com revisão, exercícios e desafios.
- `db/oracle`: scripts de setup, schema, massa de dados e consultas.
- `examples/`: exemplos pequenos por módulo.
- `projects/`: projetos completos para portfólio.

## Como começar

1. Leia `docs/00-visao-geral/como-usar-esta-formacao.md`.
2. Prepare o ambiente com `docs/00-visao-geral/guia-de-ambiente.md`.
3. Siga a ordem proposta em `docs/00-visao-geral/ordem-de-estudo.md`.
4. Execute todos os exercícios e mini projetos antes de avançar.

## Oracle local

Este repositório **já possui** Docker Compose para Oracle em `docker/docker-compose.oracle.yml`. O passo a passo completo está em:

- `db/README.md`
- `docs/02-oracle-sql/02-ambiente-oracle-local.md`

## Resultado esperado ao final

Você será capaz de:

- Modelar e implementar domínio com OO em Java.
- Criar e consultar banco Oracle com SQL.
- Desenvolver CRUD com JDBC em camadas.
- Projetar APIs REST com boas práticas.
- Construir APIs em Spring Boot com validação, erros e testes.
- Implementar jobs Spring Batch para importação e exportação entre arquivo local e Oracle.
