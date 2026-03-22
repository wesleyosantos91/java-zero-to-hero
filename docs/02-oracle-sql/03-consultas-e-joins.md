# Consultas SQL: do Básico ao Intermediário

## Ponte
Com schema pronto, vamos consultar dados para responder perguntas de negócio.

## SELECT, filtros e ordenação
- `SELECT ... FROM`
- `WHERE`
- `ORDER BY`

## JOINS
- `INNER JOIN`: interseção entre tabelas relacionadas.
- `LEFT JOIN`: mantém lado esquerdo.

## Exemplo aplicado
```sql
SELECT c.nome, p.id, p.total
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.id
WHERE p.status = 'PAGO'
ORDER BY p.data_pedido DESC;
```

## Erros comuns
- Join sem condição (produto cartesiano).
- Filtro em coluna errada.
- Falta de índice para consultas frequentes.

## Boas práticas
- Selecionar colunas necessárias.
- Nomear alias de forma clara.
- Documentar consultas de relatório.

## Fechamento
Checklist + exercícios práticos no arquivo `exercicios.md`.
