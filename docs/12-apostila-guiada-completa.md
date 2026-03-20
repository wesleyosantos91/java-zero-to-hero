# Apostila guiada completa (versao didatica)

## Contexto geral
- Publico: iniciante absoluto.
- Duracao: 1 semana (7 dias).
- Metodo: conceito -> codigo -> fixacao -> revisao.

## Objetivo final da semana
Ao final, o aluno deve conseguir construir e explicar:
1. programa Java basico.
2. modelagem OO com 4 pilares.
3. SQL DDL e DML.
4. API REST com CRUD em Oracle.
5. processo Batch de import e export.

---

## Dia 1 - Setup e fundamentos
- Validar Java e Maven.
- Criar HelloWorld.
- Entender `main`, tipos e variaveis.

Saida esperada:
- programa executando pelo terminal.

## Dia 2 - Logica e OO
- Decisao e repeticao.
- Classe e objeto.
- Encapsulamento, heranca, polimorfismo, abstracao.

Saida esperada:
- codigo com exemplos dos 4 pilares.

## Dia 3 - SQL
- Criar tabela com DDL.
- Inserir, consultar, atualizar e remover com DML.

Saida esperada:
- script rodando sem erro.

## Dia 4 - Oracle e JDBC
- Subir Oracle em Docker.
- Validar conexao SQL.
- Preparar dados JDBC para API.

Saida esperada:
- banco em `Up` e query de teste executada.

## Dia 5 - REST inicial
- Criar projeto Spring Boot no Initializr.
- Configurar `application.yml`.
- Criar `GET /clientes` e `POST /clientes`.
- Estudar anotacoes REST.

Saida esperada:
- API inicial respondendo 200, 201 e 400.

## Dia 6 - CRUD com Oracle
- Criar `@Entity` e `JpaRepository`.
- Evoluir controller para CRUD completo persistido.
- Entender status HTTP por cenario.

Saida esperada:
- fluxo create/read/update/delete completo no banco.

## Dia 7 - Spring Batch
- Criar `BatchConfig` e `BatchController`.
- Rodar import CSV -> banco.
- Rodar export banco -> CSV.
- Validar contagem API x arquivo.

Saida esperada:
- jobs funcionando e arquivo exportado.

---

## Regras obrigatorias da trilha
1. N1 concluido todos os dias.
2. Nao avancar sem explicar "o que faz" e "por que existe".
3. Corrigir erro no momento em que aparece.

## Evidencia de aprendizagem
Aluno deve demonstrar:
1. execucao tecnica sem ajuda.
2. explicacao conceitual sem leitura.
3. resolucao de erro comum com autonomia inicial.
