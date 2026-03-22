# Banco de Dados Oracle da Formação

## Estrutura
- `oracle/setup`: instruções de subida de ambiente.
- `oracle/schema`: criação de objetos.
- `oracle/data`: carga inicial.
- `oracle/queries`: consultas de estudo.

## Subir Oracle com compose existente
```bash
docker compose -f docker/docker-compose.oracle.yml up -d
```

## Ordem de execução dos scripts
1. `db/oracle/schema/01-schema.sql`
2. `db/oracle/data/01-seed.sql`
3. `db/oracle/queries/01-consultas.sql`
