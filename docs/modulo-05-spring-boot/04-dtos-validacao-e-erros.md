# 04 — DTOs, Validação e Tratamento de Erros

## Revisão do Tópico Anterior
Entidade JPA, Spring Data JPA, JpaRepository, Query Methods, Service com @Transactional, DTOs básicos. Agora validação robusta e tratamento de erros profissional.

---

## Bean Validation — Validando Entrada

Adicione `spring-boot-starter-validation` ao `pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

### Anotações de Validação

```java
public record ClienteRequest(

    @NotBlank(message = "Nome é obrigatório")
    @Size(min = 2, max = 150, message = "Nome deve ter entre 2 e 150 caracteres")
    String nome,

    @NotBlank(message = "Email é obrigatório")
    @Email(message = "Email deve ser um endereço válido")
    @Size(max = 200)
    String email,

    @Pattern(regexp = "\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}",
             message = "CPF deve estar no formato 000.000.000-00")
    String cpf,

    @Size(max = 20)
    String telefone,

    @Size(max = 100)
    String cidade,

    @Size(min = 2, max = 2, message = "Estado deve ser a sigla de 2 letras (ex: SP)")
    String estado
) {}
```

### Principais anotações disponíveis

| Anotação | Valida |
|----------|--------|
| `@NotNull` | Campo não pode ser null |
| `@NotBlank` | String não pode ser null, vazia ou só espaços |
| `@NotEmpty` | Collection/String não pode ser null ou vazia |
| `@Size(min,max)` | Tamanho de String ou Collection |
| `@Min(value)` | Valor mínimo numérico |
| `@Max(value)` | Valor máximo numérico |
| `@Positive` | Número positivo (> 0) |
| `@PositiveOrZero` | Número ≥ 0 |
| `@Email` | Formato de email |
| `@Pattern(regexp)` | Regex customizado |
| `@Past` | Data no passado |
| `@Future` | Data no futuro |
| `@DecimalMin` / `@DecimalMax` | Decimal mínimo/máximo |

### Ativar validação no Controller

```java
@PostMapping
public ResponseEntity<ClienteResponse> criar(
        @RequestBody @Valid ClienteRequest request) {  // @Valid dispara a validação
    return ResponseEntity.created(...).body(service.criar(request));
}

@PutMapping("/{id}")
public ResponseEntity<ClienteResponse> atualizar(
        @PathVariable Long id,
        @RequestBody @Valid ClienteRequest request) {
    return ResponseEntity.ok(service.atualizar(id, request));
}
```

Quando @Valid falha, Spring lança `MethodArgumentNotValidException` → você trata no `@ControllerAdvice`.

---

## Validação Customizada

```java
// Anotação customizada para CPF
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = CpfValidator.class)
public @interface Cpf {
    String message() default "CPF inválido";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

// Implementação do validador
public class CpfValidator implements ConstraintValidator<Cpf, String> {
    @Override
    public boolean isValid(String cpf, ConstraintValidatorContext context) {
        if (cpf == null || cpf.isBlank()) return true;  // null = OK (use @NotBlank separado)
        String digitos = cpf.replaceAll("[^0-9]", "");
        return digitos.length() == 11 && !digitos.matches("(\\d)\\1{10}");
        // Verificação completa de dígito verificador omitica por brevidade
    }
}

// Uso:
public record ClienteRequest(
    @NotBlank String nome,
    @NotBlank @Email String email,
    @Cpf String cpf  // usa validador customizado
) {}
```

---

## GlobalExceptionHandler — @ControllerAdvice

Centraliza o tratamento de exceções em um único lugar:

```java
package br.com.javazero.clientesapi.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // Validação falhou (@Valid)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErroResponse> handleValidation(
            MethodArgumentNotValidException ex, WebRequest request) {

        List<ErroCampo> erros = ex.getBindingResult().getFieldErrors().stream()
                .map(e -> new ErroCampo(e.getField(), e.getDefaultMessage()))
                .collect(Collectors.toList());

        return ResponseEntity.badRequest().body(ErroResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(400)
                .error("Dados inválidos")
                .message("Um ou mais campos estão incorretos")
                .path(request.getDescription(false).replace("uri=", ""))
                .erros(erros)
                .build());
    }

    // Recurso não encontrado
    @ExceptionHandler(ClienteNotFoundException.class)
    public ResponseEntity<ErroResponse> handleNotFound(
            ClienteNotFoundException ex, WebRequest request) {

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ErroResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(404)
                .error("Não encontrado")
                .message(ex.getMessage())
                .path(request.getDescription(false).replace("uri=", ""))
                .build());
    }

    // Conflito (email/cpf duplicado)
    @ExceptionHandler({EmailJaCadastradoException.class, CpfJaCadastradoException.class})
    public ResponseEntity<ErroResponse> handleConflict(
            RuntimeException ex, WebRequest request) {

        return ResponseEntity.status(HttpStatus.CONFLICT).body(ErroResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(409)
                .error("Conflito")
                .message(ex.getMessage())
                .path(request.getDescription(false).replace("uri=", ""))
                .build());
    }

    // Argumento inválido
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErroResponse> handleIllegalArgument(
            IllegalArgumentException ex, WebRequest request) {

        return ResponseEntity.badRequest().body(ErroResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(400)
                .error("Requisição inválida")
                .message(ex.getMessage())
                .path(request.getDescription(false).replace("uri=", ""))
                .build());
    }

    // Qualquer outro erro não tratado
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErroResponse> handleGeneric(
            Exception ex, WebRequest request) {

        // Log completo internamente (para rastreabilidade)
        // mas resposta sem detalhes (segurança)
        return ResponseEntity.internalServerError().body(ErroResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(500)
                .error("Erro interno")
                .message("Ocorreu um erro interno. Por favor, tente novamente.")
                .path(request.getDescription(false).replace("uri=", ""))
                .build());
    }
}
```

### Estrutura de Erro

```java
// ErroResponse.java
public record ErroResponse(
    LocalDateTime timestamp,
    int status,
    String error,
    String message,
    String path,
    List<ErroCampo> erros   // pode ser null para erros não de validação
) {
    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private LocalDateTime timestamp;
        private int status;
        private String error;
        private String message;
        private String path;
        private List<ErroCampo> erros;

        public Builder timestamp(LocalDateTime t) { this.timestamp = t; return this; }
        public Builder status(int s) { this.status = s; return this; }
        public Builder error(String e) { this.error = e; return this; }
        public Builder message(String m) { this.message = m; return this; }
        public Builder path(String p) { this.path = p; return this; }
        public Builder erros(List<ErroCampo> e) { this.erros = e; return this; }
        public ErroResponse build() {
            return new ErroResponse(timestamp, status, error, message, path, erros);
        }
    }
}

// ErroCampo.java
public record ErroCampo(String campo, String mensagem) {}
```

---

## Exemplos de Respostas de Erro

```bash
# POST com dados inválidos
curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome":"","email":"emailinvalido","cpf":"123"}'
```

```json
HTTP/1.1 400 Bad Request
{
  "timestamp": "2026-03-22T14:30:00",
  "status": 400,
  "error": "Dados inválidos",
  "message": "Um ou mais campos estão incorretos",
  "path": "/api/v1/clientes",
  "erros": [
    {"campo": "nome", "mensagem": "Nome é obrigatório"},
    {"campo": "email", "mensagem": "Email deve ser um endereço válido"},
    {"campo": "cpf", "mensagem": "CPF deve estar no formato 000.000.000-00"}
  ]
}
```

```json
// GET /api/v1/clientes/9999
HTTP/1.1 404 Not Found
{
  "timestamp": "2026-03-22T14:30:00",
  "status": 404,
  "error": "Não encontrado",
  "message": "Cliente não encontrado com id: 9999",
  "path": "/api/v1/clientes/9999",
  "erros": null
}
```

---

## Springdoc OpenAPI — Documentação Automática

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>
```

```java
// Anotações de documentação no controller
@RestController
@RequestMapping("/api/v1/clientes")
@Tag(name = "Clientes", description = "Gerenciamento de clientes")
public class ClienteController {

    @GetMapping
    @Operation(summary = "Lista todos os clientes ativos",
               description = "Retorna lista paginada de clientes")
    @ApiResponse(responseCode = "200", description = "Lista retornada com sucesso")
    public ResponseEntity<List<ClienteResponse>> listarTodos() { ... }

    @PostMapping
    @Operation(summary = "Cadastra novo cliente")
    @ApiResponse(responseCode = "201", description = "Cliente criado")
    @ApiResponse(responseCode = "400", description = "Dados inválidos")
    @ApiResponse(responseCode = "409", description = "Email ou CPF já cadastrado")
    public ResponseEntity<ClienteResponse> criar(
            @RequestBody @Valid ClienteRequest request) { ... }
}
```

Acesse `http://localhost:8080/swagger-ui.html` para a documentação interativa.

---

## Resumo do Tópico

| Conceito | Uso |
|----------|-----|
| `@Valid` | Ativa validação no parâmetro |
| `@NotBlank`, `@Email`, `@Pattern` | Validações nos campos do DTO |
| `MethodArgumentNotValidException` | Lançada quando @Valid falha |
| `@RestControllerAdvice` | Centraliza tratamento de exceções |
| `@ExceptionHandler` | Mapeia exceção → resposta HTTP |
| Springdoc | Gera Swagger automaticamente |

---

## Exercícios

### Básico
1. Adicione ao `ClienteRequest`: validação de `telefone` com regex `\(\d{2}\) \d{4,5}-\d{4}`
2. Tente fazer POST com todos os campos inválidos e analise a resposta de erro
3. Acesse o Swagger UI e execute um GET de listagem pela interface

### Intermediário
4. Crie um `@ExceptionHandler` para `DataIntegrityViolationException` (violação de constraint do banco) que retorne 409 com mensagem amigável
5. Adicione um campo `traceId` no `ErroResponse` gerado a partir de `UUID.randomUUID()` para rastreabilidade
6. Implemente a validação customizada `@Cpf` com verificação completa dos dígitos verificadores

### Avançado
7. Configure Jackson para serializar datas como `"2026-03-22"` (não como array `[2026,3,22]`)
8. Implemente `@ValidEstado` que aceita apenas as 27 siglas de estados brasileiros válidas
9. Adicione request logging (IP, método, URI, status, tempo) usando um `HandlerInterceptor`
