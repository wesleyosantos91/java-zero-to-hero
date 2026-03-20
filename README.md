# Capacitacao Java Guiada Para Iniciante Absoluto (21/03/2026 a 27/03/2026)

Este repositorio e uma apostila completa para aluno sem experiencia previa.
Tudo foi pensado para aprendizagem guiada: conceito, pratica, erro comum e correcao.

Nao existe projeto pronto: o aluno cria e evolui o projeto durante a semana.

## Resultado esperado ao final da semana
1. Entender Java basico e rodar programas simples sozinho.
2. Explicar os 4 pilares de OO com exemplos do proprio codigo.
3. Executar SQL com DDL e DML entendendo o motivo de cada comando.
4. Subir Oracle em Docker e conectar via JDBC.
5. Criar API REST com Spring Boot do zero.
6. Evoluir para CRUD persistido em Oracle.
7. Implementar Spring Batch para importacao e exportacao de dados.

## Estrutura do repositorio
- `docs/`: apostila principal e guias conceituais.
- `exercicios/`: atividades N1/N2/N3 por dia.
- `respostas/`: gabaritos comentados e criterio de correcao.
- `sql/`: scripts DDL e DML usados na trilha.
- `docker/`: ambiente Oracle local.

## Regra didatica da trilha
- Nao avancar para o proximo topico sem concluir N1 do topico atual.
- Sempre responder 3 perguntas ao final de cada bloco:
1. O que isso faz?
2. Por que isso existe?
3. O que acontece se eu remover essa parte?

## Projeto do aluno
- Caminho padrao de criacao:
`C:\dev\java-zero-to-hero\workspace-aluno\sistema-clientes`

## Comando inicial da semana
```powershell
cd C:\dev\java-zero-to-hero
docker compose -f docker/docker-compose.oracle.yml up -d
```

## Ordem recomendada de estudo
1. `docs/00-como-usar-este-material.md`
2. `docs/10-glossario-para-iniciante.md`
3. `docs/01-dia-1-setup-e-hello-world.md`
4. `docs/02-dia-2-logica-e-oo.md`
5. `docs/03-dia-3-sql-ddl-dml.md`
6. `docs/04-dia-4-oracle-docker-e-jdbc.md`
7. `docs/05-dia-5-rest-com-spring.md`
8. `docs/13-guia-anotacoes-rest.md`
9. `docs/06-dia-6-crud-rest-oracle.md`
10. `docs/07-dia-7-spring-batch.md`
11. `docs/14-guia-anotacoes-batch.md`
12. `docs/08-checklist-final.md`
13. `docs/11-erros-comuns-e-correcoes.md`
14. `docs/12-apostila-guiada-completa.md`

## Se travar
- Primeiro: revisar o bloco do dia.
- Segundo: usar `docs/11-erros-comuns-e-correcoes.md`.
- Terceiro: refazer N1 com foco em explicar em voz alta cada linha.
