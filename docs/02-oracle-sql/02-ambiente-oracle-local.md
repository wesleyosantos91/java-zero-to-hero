# Ambiente Oracle Local (Passo a Passo)

## Reuso de configuração existente
Este repositório já possui `docker/docker-compose.oracle.yml`. Use esse arquivo como base operacional.

## Subindo Oracle
```bash
docker compose -f docker/docker-compose.oracle.yml up -d
```

## Validando container
```bash
docker ps
```

## Executando scripts SQL manualmente
1. Conecte via cliente SQL (DBeaver/SQLcl).
2. Rode na ordem:
   - `db/oracle/schema/01-schema.sql`
   - `db/oracle/data/01-seed.sql`
   - `db/oracle/queries/01-consultas.sql`

## Troubleshooting rápido
- Banco não sobe: verifique memória Docker.
- Falha de autenticação: valide usuário/senha no compose.
- Porta em uso: altere mapeamento local.
