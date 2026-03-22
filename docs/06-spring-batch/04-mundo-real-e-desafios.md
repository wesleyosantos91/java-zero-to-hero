# Como Pensar Batch no Mundo Real

## Heurísticas práticas
- Defina SLA do job (tempo máximo).
- Modele idempotência de processamento.
- Tenha estratégia clara de reprocessamento.
- Separe erro técnico de erro de dado.

## Desafio final de consolidação
Construir pipeline completo:
- Importa pedidos de CSV para Oracle com validações.
- Exporta pedidos consolidados para arquivo diário.
- Gera sumário com total lido, rejeitado e gravado.

## Critérios de conclusão do módulo
- Jobs import/export executáveis localmente.
- Tratamento de falhas com retry/skip.
- Documentação de operação e diagnóstico.
