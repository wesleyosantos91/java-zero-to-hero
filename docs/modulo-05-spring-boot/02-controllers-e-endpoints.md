# 02 — Controllers e Endpoints REST

## Revisão do Tópico Anterior
IoC, DI, Beans, `@SpringBootApplication`, `application.yml`. Agora criamos a camada web: controllers e endpoints.

---

## @RestController e Mapeamentos

```java
package br.com.javazero.clientesapi.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/clientes")  // prefixo de todos os endpoints
public class ClienteController {

    private final ClienteService service;

    public ClienteController(ClienteService service) {
        this.service = service;
    }

    // GET /api/v1/clientes
    @GetMapping
    public ResponseEntity<List<ClienteResponse>> listarTodos() {
        return ResponseEntity.ok(service.listarTodos());
    }

    // GET /api/v1/clientes/42
    @GetMapping("/{id}")
    public ResponseEntity<ClienteResponse> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(service.buscarPorId(id));
    }

    // GET /api/v1/clientes?estado=SP&ativo=true
    @GetMapping("/buscar")
    public ResponseEntity<List<ClienteResponse>> buscar(
            @RequestParam(required = false) String estado,
            @RequestParam(defaultValue = "true") boolean ativo) {
        return ResponseEntity.ok(service.buscar(estado, ativo));
    }

    // POST /api/v1/clientes
    @PostMapping
    public ResponseEntity<ClienteResponse> criar(
            @RequestBody @Valid ClienteRequest request) {
        ClienteResponse criado = service.criar(request);
        URI location = URI.create("/api/v1/clientes/" + criado.id());
        return ResponseEntity.created(location).body(criado);
    }

    // PUT /api/v1/clientes/42
    @PutMapping("/{id}")
    public ResponseEntity<ClienteResponse> atualizar(
            @PathVariable Long id,
            @RequestBody @Valid ClienteRequest request) {
        return ResponseEntity.ok(service.atualizar(id, request));
    }

    // PATCH /api/v1/clientes/42/status
    @PatchMapping("/{id}/status")
    public ResponseEntity<Void> alterarStatus(
            @PathVariable Long id,
            @RequestParam boolean ativo) {
        service.alterarStatus(id, ativo);
        return ResponseEntity.noContent().build();
    }

    // DELETE /api/v1/clientes/42
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deletar(id);
        return ResponseEntity.noContent().build();
    }
}
```

---

## Anotações de Mapeamento

| Anotação | Método HTTP | Uso |
|----------|-------------|-----|
| `@GetMapping` | GET | Ler/listar |
| `@PostMapping` | POST | Criar |
| `@PutMapping` | PUT | Atualizar completo |
| `@PatchMapping` | PATCH | Atualizar parcial |
| `@DeleteMapping` | DELETE | Remover |

## Parâmetros do Controller

```java
// @PathVariable: /clientes/{id}
@GetMapping("/{id}")
public ResponseEntity<ClienteResponse> buscar(@PathVariable Long id) { ... }

// @RequestParam: /clientes?estado=SP
@GetMapping
public List<ClienteResponse> listar(
        @RequestParam(required = false) String estado,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size) { ... }

// @RequestBody: JSON no corpo
@PostMapping
public ResponseEntity<ClienteResponse> criar(@RequestBody @Valid ClienteRequest req) { ... }

// @RequestHeader: header da requisição
@GetMapping("/me")
public ClienteResponse buscarPorToken(
        @RequestHeader("Authorization") String authorization) { ... }
```

## ResponseEntity — Controle Total da Resposta

```java
// 200 OK com body
return ResponseEntity.ok(objeto);

// 201 Created com Location header
return ResponseEntity.created(URI.create("/api/v1/clientes/42")).body(criado);

// 204 No Content (DELETE, PATCH de status)
return ResponseEntity.noContent().build();

// 404 Not Found com body
return ResponseEntity.notFound().build();
return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(new ErrorResponse("Cliente não encontrado"));

// Status customizado
return ResponseEntity.status(HttpStatus.CONFLICT)
        .body(new ErrorResponse("Email já cadastrado"));
```

---

## Testando com curl

```bash
# Subir a aplicação
mvn spring-boot:run

# GET - listar todos
curl -s http://localhost:8080/api/v1/clientes | python3 -m json.tool

# GET - buscar por ID
curl -s http://localhost:8080/api/v1/clientes/1 | python3 -m json.tool

# GET - com filtro
curl -s "http://localhost:8080/api/v1/clientes?estado=SP" | python3 -m json.tool

# POST - criar
curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Ana Lima",
    "email": "ana@email.com",
    "cpf": "111.111.111-11",
    "cidade": "São Paulo",
    "estado": "SP"
  }' | python3 -m json.tool

# PUT - atualizar
curl -s -X PUT http://localhost:8080/api/v1/clientes/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Ana Lima Atualizada",
    "email": "ana.nova@email.com",
    "cpf": "111.111.111-11"
  }' | python3 -m json.tool

# PATCH - alterar status
curl -s -X PATCH "http://localhost:8080/api/v1/clientes/1/status?ativo=false"

# DELETE
curl -s -X DELETE http://localhost:8080/api/v1/clientes/1
# Deve retornar 204 (sem body)
```

---

## Exercícios

### Básico
1. Crie um `ProdutoController` com endpoints GET (listar e buscar por ID) e POST
2. Use `@RequestParam` para adicionar filtro por `categoriaId` ao GET de listar produtos
3. Verifique via curl que o POST retorna 201 com header `Location`

### Intermediário
4. Adicione ao `ClienteController` um endpoint `GET /clientes/estado/{sigla}` para buscar por estado via path param
5. Implemente `PATCH /clientes/{id}` que aceita apenas os campos que o cliente quer atualizar
6. Configure o controller para aceitar tanto `application/json` quanto `application/xml` com `produces = {}`

### Avançado
7. Crie um controller para upload de arquivo CSV de clientes usando `@RequestParam MultipartFile arquivo`
8. Adicione o header `X-Total-Count` em todas as listagens com o total de registros
9. Implemente um endpoint que retorna o status 206 Partial Content para grandes datasets
