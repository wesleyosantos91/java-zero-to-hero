# Guia de anotacoes Batch (conceito aprofundado)

Para cada item: o que faz, por que usar, o que quebra sem ele.

## `@Configuration`
- Faz: marca classe de configuracao Spring.
- Por que: permitir declaracao de beans.
- Sem ela: metodos `@Bean` podem nao ser processados.

## `@EnableBatchProcessing`
- Faz: habilita infraestrutura Batch.
- Por que: disponibilizar componentes de execucao de job.
- Sem ela: configuracao batch pode falhar.

## `@Bean`
- Faz: registra objeto no container Spring.
- Por que: jobs/steps precisam ser gerenciados pelo Spring.
- Sem ela: nao ha injecao nem ciclo de vida gerenciado.

## `JobRepository`
- Faz: salva metadados da execucao.
- Por que: historico e controle de job.
- Sem ele: rastreabilidade de execucao fica comprometida.

## `PlatformTransactionManager`
- Faz: controla transacao em step/tasklet.
- Por que: manter consistencia em falhas.
- Sem ele: risco maior de estado inconsistente.

## `@Value("${...}")`
- Faz: injeta propriedade externa.
- Por que: evitar caminho hardcoded.
- Sem ele: manutencao mais dificil e acoplada ao codigo.

## `JobLauncher`
- Faz: dispara job com parametros.
- Por que: controlar execucao manual via endpoint.
- Sem ele: job nao e iniciado por demanda.

## `@Qualifier`
- Faz: escolhe bean especifico entre varios do mesmo tipo.
- Por que: temos import e export (ambos `Job`).
- Sem ele: ambiguidade de injecao.

## `JobParametersBuilder`
- Faz: monta parametros da execucao.
- Por que: identificar instancia de execucao.
- Sem parametros unicos: Spring pode recusar execucao duplicada.

## `RepeatStatus.FINISHED`
- Faz: sinaliza fim da tasklet.
- Por que: encerrar step corretamente.
- Sem retorno adequado: step pode nao finalizar corretamente.

## Fluxo tecnico do import
1. endpoint chama `JobLauncher`.
2. job `importClientesJob` recebe parametros.
3. step `importClientesStep` executa tasklet.
4. tasklet le CSV e salva no banco.
5. JobRepository registra resultado.

## Fluxo tecnico do export
1. endpoint chama `JobLauncher`.
2. job `exportClientesJob` inicia.
3. step `exportClientesStep` le banco.
4. tasklet escreve CSV de saida.
5. JobRepository registra resultado.

## Perguntas de autoavaliacao
1. Qual diferenca entre Job e Step?
2. Por que timestamp evita conflito de execucao?
3. Qual papel do JobRepository na auditoria?
