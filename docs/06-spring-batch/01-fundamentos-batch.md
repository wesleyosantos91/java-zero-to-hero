# Módulo 6 — Spring Batch (Arquivo Local + Oracle)

## Revisão
Após construir APIs transacionais, agora você processará volume em lote.

## Spring Batch
- O que é: framework para processamento robusto em lote.
- Por que existe: jobs repetitivos, massivos e auditáveis.
- Problema que resolve: confiabilidade, reprocessamento e rastreabilidade.
- Quando usar: integrações periódicas, saneamento de dados, ETL leve.
- Quando evitar: operações online de baixa latência por requisição.

## Arquitetura
- Job
- Step
- ItemReader
- ItemProcessor
- ItemWriter
- Chunk processing
- Controle transacional (commit/rollback)
- Retry/Skip/Listeners
