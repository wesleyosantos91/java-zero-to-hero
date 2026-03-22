# Fluxo 2 — Exportação (Oracle → Arquivo Local)

## Passo a passo
1. Reader consulta Oracle em páginas/chunks.
2. Processor enriquece/formata.
3. Writer grava CSV/TXT local com cabeçalho e padrão de data.
4. Job gera relatório de execução.

## Transações e falhas
- Commit por chunk.
- Rollback no chunk atual em caso de erro.
- Política de retry para indisponibilidade momentânea.

## Resultado esperado
Arquivo exportado reproduzível, auditável e compatível com consumo externo.
