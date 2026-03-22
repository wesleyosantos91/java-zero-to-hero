# Fluxo 1 — Importação (CSV/TXT → Oracle)

## Passo a passo
1. Reader lê arquivo local.
2. Processor valida e transforma.
3. Writer persiste em Oracle.
4. Registros inválidos vão para arquivo de rejeição.
5. Retry para falhas transitórias.
6. Skip para registros irrecuperáveis.
7. Listeners para auditoria.

## Erros comuns
- Layout de arquivo sem versionamento.
- Chaves duplicadas sem tratamento.
- Chunk muito grande causando consumo alto de memória.

## Diagnóstico
- Consulte metadados de execução do Batch.
- Registre contadores de leitura/processamento/escrita.
