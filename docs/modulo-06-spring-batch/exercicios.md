# Exercícios — Módulo 06: Spring Batch

Exercícios práticos com Spring Batch 5.x integrado ao Oracle. Use os projetos dos tópicos como ponto de partida.

> **Convenção:** `[B]` = Básico · `[I]` = Intermediário · `[A]` = Avançado

---

## Tópico 01 — Introdução ao Spring Batch

**`[B]`** 1. Liste 5 casos de uso reais de batch processing que você encontraria no mercado brasileiro (bancos, saúde, varejo, governo). Para cada um, indique: frequência (diário, mensal...), volume estimado e por que batch é melhor que processamento online.

**`[B]`** 2. Adicione as dependências do Spring Batch e Oracle no `pom.xml`. Execute a aplicação e verifique que as tabelas `BATCH_JOB_INSTANCE`, `BATCH_JOB_EXECUTION` e `BATCH_STEP_EXECUTION` foram criadas automaticamente no Oracle.

**`[B]`** 3. Configure o primeiro job com um único step Tasklet que imprime `"Job executado com sucesso!"`. Execute e consulte as tabelas de metadados para ver o registro da execução.

**`[I]`** 4. Analise as tabelas de metadados após executar um job com sucesso e outro com falha (force um erro no Tasklet). Identifique:
- Qual tabela guarda os parâmetros passados?
- Qual campo indica o status final?
- Como distinguir uma instância de job de uma execução de job?

---

## Tópico 02 — Conceitos Fundamentais

**`[B]`** 5. Configure um `FlatFileItemReader` para ler o arquivo abaixo (separador `;`). O reader deve pular o cabeçalho e mapear para a classe `Produto(codigo, nome, preco)`:
```
codigo;nome;preco
PROD-001;Notebook;2999.90
PROD-002;Mouse;49.90
PROD-003;Teclado;129.90
```

**`[B]`** 6. Escreva um `ItemProcessor<Produto, Produto>` que:
- Retorna `null` (ignora) se o `preco` for negativo ou zero
- Converte o `nome` para title case (primeira letra maiúscula)
- Adiciona prefixo `"[IMPORTADO]"` ao nome

**`[B]`** 7. Configure um `JdbcBatchItemWriter` para inserir produtos na tabela `produtos`. Configure o step com `chunk(10)` e execute o job. Verifique os registros no banco.

**`[I]`** 8. Adicione um `JobExecutionListener` que:
- No `beforeJob`: imprime data/hora de início e nome do arquivo
- No `afterJob`: imprime duração em segundos e status final

**`[I]`** 9. Adicione um `StepExecutionListener` que imprime ao final do step: lidos, escritos, ignorados (filter count) e pulados (skip count).

**`[I]`** 10. Teste o comportamento de `null` no processor: crie um CSV com 5 linhas onde a 2ª e a 4ª têm preço negativo. Verifique que o `filterCount` no step é 2 e que apenas 3 itens são escritos.

**`[A]`** 11. Implemente `CompositeItemProcessor` encadeando dois processors: o primeiro valida (retorna null se inválido), o segundo transforma (normaliza campos). Use `CompositeItemProcessorBuilder`.

---

## Tópico 03 — Importação CSV para Oracle

**`[B]`** 12. Crie o arquivo `clientes-teste.csv` com 20 linhas (inclua 3 com dados inválidos: sem email, com quantidade negativa, linha vazia). Execute o job de importação do tópico 03 e verifique:
- Quantos foram inseridos no banco?
- Quantos foram ignorados pelo processor?
- O log mostra os registros ignorados?

**`[B]`** 13. Altere o `ValidarArquivoTasklet` para também verificar se o arquivo tem pelo menos 2 linhas (cabeçalho + 1 dado). Se o arquivo só tiver o cabeçalho, o step deve falhar com mensagem clara.

**`[I]`** 14. Configure `faultTolerant().skip(FlatFileParseException.class).skipLimit(5)`. Crie um CSV onde a linha 3 tem um campo a menos que o esperado (vai causar `FlatFileParseException`). Verifique que o job continua processando as demais linhas.

**`[I]`** 15. Altere o `skipLimit` para 0 (tolerância zero). Execute com o mesmo CSV defeituoso. Qual é o comportamento? O job falha ou ignora?

**`[I]`** 16. Adicione um 3º parâmetro ao job: `dataReferencia` (String no formato `yyyy-MM-dd`). Use `@Value("#{jobParameters['dataReferencia']}")` para gravar esse valor em uma coluna `data_importacao` na tabela `clientes`.

**`[A]`** 17. Use `JobParametersIncrementer` para permitir reexecutar o job com o mesmo nome de arquivo (normalmente o Spring Batch impede isso por considerar a execução já concluída). Implemente `RunIdIncrementer` e verifique que a re-execução cria uma nova instância na tabela `BATCH_JOB_INSTANCE`.

---

## Tópico 04 — Exportação Oracle para Arquivo

**`[B]`** 18. Configure um `JdbcCursorItemReader` que lê clientes ativos ordenados por estado e nome. Configure o step com `chunk(200)` e escreva os resultados em um CSV com cabeçalho.

**`[B]`** 19. Modifique o `RelatorioProcessor` para mascarar o email: `"joao@email.com"` vira `"j***@email.com"`. Apenas o primeiro caractere e o domínio ficam visíveis.

**`[I]`** 20. Configure `JdbcPagingItemReader` com `pageSize=100` como alternativa ao `JdbcCursorItemReader`. Execute e compare:
- O SQL gerado (use `show-sql=true`)
- O número de queries executadas para 500 registros
- O tempo total de execução

**`[I]`** 21. Implemente `ClassifierCompositeItemWriter` que separa os clientes em dois arquivos:
- `clientes-sul.csv` para estados RS, SC, PR
- `clientes-outros.csv` para os demais estados

**`[A]`** 22. Configure `MultiResourceItemWriter` para criar um novo arquivo a cada 100 registros. Os arquivos devem se chamar `clientes-parte-1.csv`, `clientes-parte-2.csv`, etc. Use `ResourceSuffixCreator`.

---

## Tópico 05 — Jobs Avançados

**`[B]`** 23. Configure `startLimit(3)` em um step e force-o a falhar sempre (lance uma `RuntimeException` no processor). Observe que após 3 tentativas o step fica com status `ABANDONED`. Consulte `BATCH_STEP_EXECUTION` para ver as 3 execuções.

**`[B]`** 24. Consulte as tabelas de metadados para responder:
- Qual a duração média dos seus jobs? (em segundos)
- Qual step tem mais erros?
- Quantos registros foram escritos no total em todos os jobs executados?

**`[I]`** 25. Implemente `EstadoPartitioner` que divide os clientes por estado (cada estado = uma partição). Configure o master step com `gridSize=4`. Verifique nos logs que múltiplas threads processam em paralelo.

**`[I]`** 26. Crie um job com dois fluxos paralelos usando `split()`:
- Flow 1: exporta clientes para CSV
- Flow 2: gera relatório de estoque crítico (produtos com estoque < 5)

Ambos devem rodar ao mesmo tempo. Adicione um step final que consolida os resultados (apenas imprime "Todos os relatórios gerados").

**`[I]`** 27. Implemente `JobExecutionDecider` chamado `TemArquivoPendenteDecider` que verifica se existe um arquivo em `/tmp/batch/input/`. Retorna `"TEM_ARQUIVO"` se existir ou `"SEM_ARQUIVO"` se não. Configure o job para executar o step de importação apenas se `"TEM_ARQUIVO"`.

**`[A]`** 28. Injete `JobOperator` em um `@RestController` e exponha os endpoints:
```
GET  /batch/jobs               → lista execuções recentes
GET  /batch/jobs/{id}/status   → status de uma execução
POST /batch/jobs/{id}/parar    → para um job em execução
POST /batch/jobs/{id}/reiniciar→ reinicia job com falha
```

---

## Tópico 06 — Projeto Final

**`[B]`** 29. Execute o projeto de processamento de pedidos (`06-projeto-final-batch.md`) completo com o arquivo de exemplo. Verifique:
- O CSV de saída foi gerado corretamente?
- O status dos pedidos no banco está correto?
- O listener imprimiu as métricas ao final?

**`[I]`** 30. Adicione ao projeto final um 5º step: `GerarResumoStep` que:
- Conta pedidos por status (APROVADO, SEM_ESTOQUE)
- Calcula o valor total de pedidos aprovados
- Imprime o resumo no log e grava em uma tabela `RESUMO_PROCESSAMENTO`

**`[I]`** 31. Implemente um `SkipListener<PedidoInput, Pedido>` que salva os pedidos rejeitados em um arquivo `pedidos-rejeitados-{data}.csv` com: número do pedido, motivo da rejeição e linha do arquivo original.

**`[A]`** 32. Adicione monitoramento ao projeto:
- Grave métricas de cada execução em `METRICAS_BATCH(job_name, data_exec, lidos, escritos, ignorados, duracao_seg)`
- Crie a query: total processado por mês, taxa de rejeição média por job, duração média por job
- Exponha `GET /batch/metricas?mes=2026-03` via REST que retorna o relatório mensal

---

## Desafio Final do Módulo — Pipeline de Integração Completo

Construa um pipeline completo de integração de dados para um cenário de folha de pagamento:

### Cenário

Uma empresa recebe mensalmente um arquivo CSV com os contracheques dos funcionários. O sistema deve:
1. Validar o arquivo e os dados
2. Importar para o Oracle
3. Calcular descontos (INSS, IRRF) e líquido
4. Gerar holerite em arquivo TXT formatado por funcionário
5. Gerar relatório gerencial em CSV

### Entidades

```
Funcionario (matricula, nome, cargo, salario_bruto, departamento)
Holerite (matricula, competencia, bruto, inss, irrf, liquido)
```

### Requisitos

**`[B]`** — Steps 1 e 2: validação do arquivo e importação para banco

**`[I]`** — Step 3: cálculo dos descontos em `processor` e atualização no banco

**`[A]`** — Steps 4 e 5: geração de holerite individual (arquivo por funcionário) e relatório gerencial, com particionamento por departamento para processamento paralelo

---

*Exercícios do Módulo 06 — 32 exercícios + desafio final*
