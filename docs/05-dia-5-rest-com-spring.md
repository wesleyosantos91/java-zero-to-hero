# Dia 5 - 25/03/2026 (Quarta, 2h)

Tema: criar projeto Spring Boot do zero e entender REST no nivel de conceito + pratica.

## Objetivo do dia
1. criar projeto Spring Boot sem base pronta.
2. subir API localmente.
3. implementar `GET /clientes` e `POST /clientes`.
4. entender cada anotacao REST usada e o motivo de existir.

## O que e REST (conceito antes do codigo)
REST e um estilo para construir APIs com foco em recursos (ex.: clientes).
Voce conversa com esses recursos por HTTP:
- `GET` para ler.
- `POST` para criar.
- `PUT` para atualizar.
- `DELETE` para remover.

A API sempre responde duas coisas:
1. status HTTP (200, 201, 400...).
2. corpo (dados JSON ou mensagem de erro).

---

## Bloco 1 - Criar projeto do zero (00:00-00:30)

### Passo 1 - Pasta de trabalho
```powershell
New-Item -ItemType Directory -Force C:\dev\java-zero-to-hero\workspace-aluno | Out-Null
cd C:\dev\java-zero-to-hero\workspace-aluno
```

### Passo 2 - Gerar no Spring Initializr
Abrir [https://start.spring.io](https://start.spring.io)

Preencher:
- Project: Maven
- Language: Java
- Spring Boot: 3.2.x
- Group: br.com.aluno
- Artifact: sistema-clientes
- Name: sistema-clientes
- Packaging: Jar
- Java: 21

Dependencias:
- Spring Web
- Validation
- Spring Data JPA
- Spring Batch
- Oracle Driver

### Passo 3 - Extrair
Extrair zip para:
`C:\dev\java-zero-to-hero\workspace-aluno\sistema-clientes`

---

## Bloco 2 - application.yml (00:30-00:45)

Editar `src/main/resources/application.yml`:
```yaml
spring:
  datasource:
    url: jdbc:oracle:thin:@localhost:1521/FREEPDB1
    username: app_user
    password: app_password
    driver-class-name: oracle.jdbc.OracleDriver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
server:
  port: 8080
```

### Por que isso existe?
- `datasource`: diz como conectar no banco.
- `ddl-auto: update`: cria/ajusta tabelas automaticamente com base nas entidades.
- `show-sql: true`: mostra SQL no log para enxergar o que a aplicacao esta fazendo.

---

## Bloco 3 - Health endpoint (00:45-01:00)

Criar `HealthController.java`:
```java
package br.com.aluno.sistemaclientes;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/health")
    public String health() {
        return "API no ar";
    }
}
```

Rodar:
```powershell
cd C:\dev\java-zero-to-hero\workspace-aluno\sistema-clientes
mvn spring-boot:run
```

Testar:
```powershell
Invoke-RestMethod -Method Get http://localhost:8080/health
```

---

## Bloco 4 - ClienteRequest e ClienteController (01:00-01:40)

Criar `ClienteRequest.java`:
```java
package br.com.aluno.sistemaclientes;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class ClienteRequest {
    @NotBlank
    private String nome;

    @NotBlank
    @Email
    private String email;

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
```

Criar `ClienteController.java`:
```java
package br.com.aluno.sistemaclientes;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/clientes")
public class ClienteController {

    private final List<Map<String, String>> clientes = new ArrayList<>();

    @GetMapping
    public List<Map<String, String>> listar() {
        return clientes;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Map<String, String> criar(@Valid @RequestBody ClienteRequest req) {
        Map<String, String> novo = Map.of("nome", req.getNome(), "email", req.getEmail());
        clientes.add(novo);
        return novo;
    }
}
```

---

## Mapa de anotacoes REST (conceito + por que usar)

### `@RestController`
- O que faz: marca classe como controller REST.
- Por que usar: sem isso Spring nao expoe metodos como endpoints HTTP.
- Sem ela: `GET /clientes` retorna 404 porque endpoint nao foi registrado.

### `@RequestMapping("/clientes")`
- O que faz: define prefixo de rota da classe.
- Por que usar: evita repetir `"/clientes"` em todos os metodos.
- Sem ela: rotas ficariam soltas e mais sujeitas a erro.

### `@GetMapping`
- O que faz: mapeia metodo HTTP GET.
- Por que usar: separa claramente operacao de leitura.
- Sem ela: metodo nao responde a GET.

### `@PostMapping`
- O que faz: mapeia metodo HTTP POST.
- Por que usar: semantica correta para criacao.
- Sem ela: endpoint nao responde para criar recurso.

### `@RequestBody`
- O que faz: converte JSON recebido em objeto Java.
- Por que usar: evita parsing manual de texto JSON.
- Sem ela: Spring nao sabe que o body deve virar `ClienteRequest`.

### `@Valid`
- O que faz: ativa validacao das regras do DTO.
- Por que usar: impede salvar dado invalido.
- Sem ela: `@NotBlank` e `@Email` seriam ignorados.

### `@NotBlank`
- O que faz: campo nao pode ser vazio ou so espaco.
- Por que usar: protege regra minima do dominio.

### `@Email`
- O que faz: valida formato de email.
- Por que usar: evita email sem formato valido.

### `@ResponseStatus(HttpStatus.CREATED)`
- O que faz: retorna 201 no POST.
- Por que usar: 201 comunica "criado com sucesso".
- Sem ela: poderia voltar 200, que e menos semantico para criacao.

---

## Bloco 5 - Testes guiados (01:40-02:00)

```powershell
Invoke-RestMethod -Method Get http://localhost:8080/clientes
Invoke-RestMethod -Method Post http://localhost:8080/clientes -ContentType "application/json" -Body '{"nome":"Aluno Dia5","email":"aluno.dia5@email.com"}'
Invoke-RestMethod -Method Get http://localhost:8080/clientes
```

Teste erro de validacao:
```powershell
Invoke-RestMethod -Method Post http://localhost:8080/clientes -ContentType "application/json" -Body '{"email":"sem.nome@email.com"}'
```

## Checklist do dia
- [ ] projeto criado do zero.
- [ ] endpoints de health e clientes funcionando.
- [ ] entendeu o papel de cada anotacao REST.
- [ ] conseguiu explicar por que `@Valid` e importante.
