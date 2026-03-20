# Dia 7 - 27/03/2026 (Sexta, 2h)

Tema: Spring Batch com foco em conceito profundo de anotacoes + codigo completo.

## Objetivo do dia
1. entender arquitetura de Batch (Job -> Step -> Tasklet).
2. criar jobs reais de import e export.
3. entender o motivo de cada anotacao usada no codigo.

## Conceito antes do codigo

### Job
Job e o processo batch inteiro.
Exemplo: importar clientes de arquivo para banco.

### Step
Step e uma etapa do Job.
Nosso job de import tem 1 step com 1 tasklet.

### Tasklet
Tasklet e a acao executada no step.
Aqui: ler linhas do CSV e salvar no banco.

---

## Bloco 1 - Preparar entrada e saida (00:00-00:15)

```powershell
cd C:\dev\java-zero-to-hero\workspace-aluno\sistema-clientes
New-Item -ItemType Directory -Force src\main\resources\input | Out-Null
New-Item -ItemType Directory -Force output | Out-Null
```

Criar `src/main/resources/input/clientes.csv`:
```text
nome,email
Ana Souza,ana.souza@email.com
Bruno Lima,bruno.lima@email.com
```

---

## Bloco 2 - Configurar application.yml (00:15-00:30)

```yaml
spring:
  batch:
    jdbc:
      initialize-schema: always
    job:
      enabled: false

app:
  batch:
    input-file: src/main/resources/input/clientes.csv
    output-file: output/clientes_export.csv
```

### Entenda cada item
- `initialize-schema: always`: cria tabelas internas do Batch (metadados).
- `job.enabled: false`: evita job rodar automaticamente no startup.
- `app.batch.input-file`: caminho da origem de import.
- `app.batch.output-file`: caminho do arquivo de export.

---

## Bloco 3 - Criar `BatchConfig.java` completo (00:30-01:05)

Arquivo:
`src/main/java/br/com/aluno/sistemaclientes/batch/BatchConfig.java`

```java
package br.com.aluno.sistemaclientes.batch;

import br.com.aluno.sistemaclientes.cliente.Cliente;
import br.com.aluno.sistemaclientes.cliente.ClienteRepository;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

@Configuration
@EnableBatchProcessing
public class BatchConfig {

    @Bean("importClientesJob")
    public Job importClientesJob(JobRepository repo, Step importClientesStep) {
        return new JobBuilder("importClientesJob", repo)
                .start(importClientesStep)
                .build();
    }

    @Bean("exportClientesJob")
    public Job exportClientesJob(JobRepository repo, Step exportClientesStep) {
        return new JobBuilder("exportClientesJob", repo)
                .start(exportClientesStep)
                .build();
    }

    @Bean
    public Step importClientesStep(
            JobRepository repo,
            PlatformTransactionManager tx,
            ClienteRepository clienteRepository,
            @Value("${app.batch.input-file}") String inputFile) {

        return new StepBuilder("importClientesStep", repo)
                .tasklet((contribution, chunkContext) -> {
                    List<String> linhas = Files.readAllLines(Path.of(inputFile));
                    for (int i = 1; i < linhas.size(); i++) {
                        String[] col = linhas.get(i).split(",");
                        Cliente c = new Cliente();
                        c.setNome(col[0].trim());
                        c.setEmail(col[1].trim());
                        clienteRepository.save(c);
                    }
                    return RepeatStatus.FINISHED;
                }, tx)
                .build();
    }

    @Bean
    public Step exportClientesStep(
            JobRepository repo,
            PlatformTransactionManager tx,
            ClienteRepository clienteRepository,
            @Value("${app.batch.output-file}") String outputFile) {

        return new StepBuilder("exportClientesStep", repo)
                .tasklet((contribution, chunkContext) -> {
                    List<Cliente> clientes = clienteRepository.findAll();
                    StringBuilder sb = new StringBuilder("id,nome,email\\n");
                    for (Cliente c : clientes) {
                        sb.append(c.getId()).append(",")
                          .append(c.getNome()).append(",")
                          .append(c.getEmail()).append("\\n");
                    }
                    Files.writeString(Path.of(outputFile), sb.toString());
                    return RepeatStatus.FINISHED;
                }, tx)
                .build();
    }
}
```

### Explicacao de anotacoes e por que existem

#### `@Configuration`
- Marca classe que define beans manualmente.
- Sem ela, metodos `@Bean` podem nao ser processados.

#### `@EnableBatchProcessing`
- Liga infraestrutura do Spring Batch.
- Sem ela, objetos essenciais de batch podem nao estar disponiveis.

#### `@Bean`
- Registra objeto no container Spring.
- Jobs e Steps precisam ser beans para serem injetados e executados.

#### `@Value("${app.batch.input-file}")`
- Injeta valor de propriedade externa no parametro.
- Evita deixar caminho hardcoded no codigo.

#### `JobRepository`
- Registra historico e status dos jobs.
- Permite saber o que rodou e quando rodou.

#### `PlatformTransactionManager`
- Garante transacao no step.
- Se der erro no meio, ajuda a manter consistencia.

#### `RepeatStatus.FINISHED`
- Informa ao Spring Batch que a tasklet terminou.

---

## Bloco 4 - Criar `BatchController.java` completo (01:05-01:25)

Arquivo:
`src/main/java/br/com/aluno/sistemaclientes/batch/BatchController.java`

```java
package br.com.aluno.sistemaclientes.batch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/batch")
public class BatchController {

    private final JobLauncher jobLauncher;
    private final Job importClientesJob;
    private final Job exportClientesJob;

    public BatchController(
            JobLauncher jobLauncher,
            @Qualifier("importClientesJob") Job importClientesJob,
            @Qualifier("exportClientesJob") Job exportClientesJob) {
        this.jobLauncher = jobLauncher;
        this.importClientesJob = importClientesJob;
        this.exportClientesJob = exportClientesJob;
    }

    @PostMapping("/import")
    public String importar() throws Exception {
        jobLauncher.run(importClientesJob,
                new JobParametersBuilder()
                        .addLong("ts", System.currentTimeMillis())
                        .toJobParameters());
        return "Job import executado";
    }

    @PostMapping("/export")
    public String exportar() throws Exception {
        jobLauncher.run(exportClientesJob,
                new JobParametersBuilder()
                        .addLong("ts", System.currentTimeMillis())
                        .toJobParameters());
        return "Job export executado";
    }
}
```

### Explicacao de anotacoes do controller

#### `@RestController`
- Expõe endpoints HTTP para disparar jobs.

#### `@RequestMapping("/batch")`
- Prefixo comum para rotas batch.

#### `@PostMapping("/import")` e `@PostMapping("/export")`
- Disparo de processo com efeito de escrita.
- POST e mais adequado que GET para acao com efeito colateral.

#### `@Qualifier(...)`
- Necessario porque existem dois beans do tipo `Job`.
- Sem qualifier, Spring pode nao saber qual injetar.

### Por que `timestamp` no JobParameters?
- O Spring Batch diferencia execucoes por parametros.
- Se repetir com mesmos parametros, pode acusar execucao duplicada.
- `ts` torna cada execucao unica.

---

## Bloco 5 - Teste ponta a ponta (01:25-01:45)

```powershell
Invoke-RestMethod -Method Post http://localhost:8080/batch/import
Invoke-RestMethod -Method Get http://localhost:8080/clientes
Invoke-RestMethod -Method Post http://localhost:8080/batch/export
Get-Content C:\dev\java-zero-to-hero\workspace-aluno\sistema-clientes\output\clientes_export.csv
```

---

## Bloco 6 - Validacao final (01:45-02:00)

```powershell
$linhasApi = (Invoke-RestMethod -Method Get http://localhost:8080/clientes).Count
$linhasArquivo = (Get-Content C:\dev\java-zero-to-hero\workspace-aluno\sistema-clientes\output\clientes_export.csv).Count - 1
$linhasApi
$linhasArquivo
```

Esperado: mesmo total.

### Checklist do dia
- [ ] `BatchConfig` criado e compreendido.
- [ ] `BatchController` criado e compreendido.
- [ ] import e export funcionando.
- [ ] aluno explica `@Bean`, `@Qualifier`, `@Value`, `JobLauncher` e `JobParameters`.
