# Módulo 2 — Banco de Dados Relacional com Oracle

## Revisão do módulo anterior
Você modelou objetos; agora vai persistir dados com modelagem relacional.

## Conceitos centrais
Para cada conceito, use a régua didática abaixo.

### Tabelas e colunas
1. O que é: estrutura de armazenamento.
2. Por que existe: organizar dados com esquema.
3. Problema que resolve: consistência e consulta.
4. Quando usar: dados estruturados e relacionáveis.
5. Quando evitar: dados não estruturados em alto volume sem esquema estável.
6. Funcionamento: linhas representam registros; colunas, atributos tipados.
7. Exemplo simples: tabela `clientes(id, nome)`.
8. Exemplo aplicado: `clientes`, `pedidos`, `itens_pedido`.
9. Erro comum: tipos incorretos para data/valor monetário.
10. Boa prática: nomear padrão snake_case e constraints explícitas.
11. Resumo: modelagem correta reduz erro a longo prazo.
12. Exercícios: criar 3 tabelas com PK/FK.

### DDL, DML e constraints
- DDL: `CREATE`, `ALTER`, `DROP`.
- DML: `INSERT`, `UPDATE`, `DELETE`.
- Constraints: `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`.

## Fechamento do tópico
- Pontos de atenção: integridade referencial e tipos.
- Checklist: criou schema, tabelas e constraints.
- Exercícios básicos/intermediários/avançados em `exercicios.md`.
