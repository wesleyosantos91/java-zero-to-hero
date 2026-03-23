# Exercícios — Módulo 05: Spring Boot 3

Exercícios práticos com Spring Boot 3, Spring Data JPA, Bean Validation e Springdoc. Use o Oracle XE local.

> **Convenção:** `[B]` = Básico · `[I]` = Intermediário · `[A]` = Avançado

---

## Tópico 01 — Introdução ao Spring Boot

**`[B]`** 1. Crie um projeto Spring Boot com Spring Initializr (start.spring.io). Dependências: Web, Actuator. Execute e acesse `http://localhost:8080/actuator/health`. O que o JSON retornado indica?

**`[B]`** 2. Crie um `@Component` chamado `SaudacaoService` com o método `saudar(String nome)` retornando `"Olá, {nome}! Seja bem-vindo."`. Injete-o em um segundo componente `InicializadorApp` que implementa `CommandLineRunner` e chama `saudar("Desenvolvedor")` na inicialização.

**`[B]`** 3. Adicione as seguintes propriedades ao `application.yml` e leia-as com `@Value` em um componente:
```yaml
app:
  nome: "Sistema de Clientes"
  versao: "1.0.0"
  max-registros: 1000
```

**`[I]`** 4. Configure dois profiles no `application.yml`: `dev` (H2 em memória, log SQL ativo) e `prod` (Oracle, log SQL inativo). Ative cada um com `-Dspring.profiles.active=dev` e verifique qual banco é usado.

**`[I]`** 5. Crie uma classe `@ConfigurationProperties(prefix = "app")` chamada `AppProperties` que mapeia as propriedades do exercício 3. Use validação com `@NotBlank` e `@Min(1)` nos campos.

---

## Tópico 02 — Controllers e Endpoints

**`[B]`** 6. Crie o `ProdutoController` com os endpoints abaixo. Por enquanto, retorne dados fictícios hardcoded (sem banco):
- `GET /api/v1/produtos` → lista de 3 produtos
- `GET /api/v1/produtos/{id}` → produto pelo id (ou 404 se id > 3)
- `POST /api/v1/produtos` → imprime o body no log e retorna 201

**`[B]`** 7. Adicione ao `ProdutoController`:
- `GET /api/v1/produtos?categoria={id}&ativo={true/false}` com `@RequestParam`
- `PATCH /api/v1/produtos/{id}/estoque?quantidade={n}` que retorna 204

**`[B]`** 8. Teste todos os endpoints do exercício 6 e 7 com `curl`. Verifique que os status HTTP estão corretos (200, 201, 204, 404).

**`[I]`** 9. Adicione ao `ProdutoController` um endpoint `GET /api/v1/produtos` que retorna o header `X-Total-Count` com o total de registros. O body deve ser a lista paginada.

**`[I]`** 10. Crie um `@RestController` para upload de CSV:
```java
@PostMapping(value = "/api/v1/produtos/importar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public ResponseEntity<Map<String, Integer>> importar(@RequestParam MultipartFile arquivo)
```
O método deve contar as linhas (exceto cabeçalho) e retornar `{"linhas": 42}`.

**`[A]`** 11. Implemente um `HandlerInterceptor` que registra em log: IP da requisição, método HTTP, URI e tempo de resposta (em ms). Registre no formato:
```
[GET] /api/v1/produtos — 127.0.0.1 — 45ms
```

---

## Tópico 03 — Services, Repositórios e JPA

**`[B]`** 12. Crie a entidade `Produto` mapeada para a tabela `produtos` com os campos: `id` (sequence Oracle), `nome`, `preco`, `estoque`, `ativo`, `dataCadastro` (preenchida com `@PrePersist`).

**`[B]`** 13. Crie o `ProdutoRepository extends JpaRepository<Produto, Long>` com os métodos:
- `findByAtivoTrue()`
- `findByNomeContainingIgnoreCase(String nome)`
- `findByCategoriaId(Long id)`
- `existsByNome(String nome)`

**`[B]`** 14. Crie o `ProdutoService` com `@Transactional(readOnly = true)` na classe e `@Transactional` nos métodos de escrita. Implemente: `listar()`, `buscarPorId(Long)`, `criar(ProdutoRequest)`, `atualizar(Long, ProdutoRequest)`, `desativar(Long)`.

**`[I]`** 15. Adicione ao `ProdutoRepository` uma `@Query` JPQL que busca produtos com estoque abaixo de um limite, ordenados por estoque crescente:
```java
@Query("SELECT p FROM Produto p WHERE p.estoque < :limite AND p.ativo = true ORDER BY p.estoque ASC")
List<Produto> findEstoqueCritico(@Param("limite") int limite);
```

**`[I]`** 16. Adicione paginação ao `listar()`: `Page<ProdutoResponse> listar(Pageable pageable)`. No controller, receba `@RequestParam int page = 0, @RequestParam int size = 20` e construa o `PageRequest`.

**`[A]`** 17. Ative `spring.jpa.show-sql=true` e analise as queries geradas para:
- `findByAtivoTrue()` — qual SQL é gerado?
- `findByCategoriaId(id)` sem `@EntityGraph` — quantas queries são executadas? (N+1?)
- `findByCategoriaId(id)` com `@EntityGraph(attributePaths = "categoria")` — agora quantas?

Documente o resultado.

---

## Tópico 04 — DTOs, Validação e Erros

**`[B]`** 18. Crie os records `ProdutoRequest` e `ProdutoResponse`. No `ProdutoRequest`, adicione:
- `@NotBlank` no `nome`
- `@Positive` no `preco`
- `@PositiveOrZero` no `estoque`
- `@NotNull` no `categoriaId`

**`[B]`** 19. Adicione `@Valid` no controller e teste com curl enviando dados inválidos. Verifique a resposta de erro padrão do Spring. Ela é clara o suficiente para o consumidor da API?

**`[B]`** 20. Crie o `GlobalExceptionHandler` com `@RestControllerAdvice` tratando:
- `MethodArgumentNotValidException` → 400 com lista de erros por campo
- `ProdutoNotFoundException` → 404
- `Exception` → 500 sem detalhes internos

**`[I]`** 21. Crie a validação customizada `@PrecoValido` que verifica que o preço tem no máximo 2 casas decimais e é maior que zero. Aplique-a ao campo `preco` do `ProdutoRequest`.

**`[I]`** 22. Adicione ao `ErroResponse` um campo `traceId` gerado com `UUID.randomUUID()` em cada erro. Isso permite ao suporte rastrear logs de uma requisição específica.

**`[A]`** 23. Configure o Jackson para que datas (`LocalDate`, `LocalDateTime`) sejam serializadas como string ISO (`"2026-03-23"`) e não como array `[2026, 3, 23]`. Adicione a dependência `jackson-datatype-jsr310` e configure via `application.yml`:
```yaml
spring:
  jackson:
    serialization:
      write-dates-as-timestamps: false
```
Verifique a diferença no response.

---

## Tópico 05 — Projeto Completo

**`[B]`** 24. Execute o projeto completo de clientes (`05-crud-completo.md`) e teste todos os endpoints com curl:
```bash
# Criar, buscar, atualizar, alterar status e deletar
# Testar validações enviando dados inválidos
# Testar 404 com ID inexistente
# Testar 409 com email duplicado
```

**`[I]`** 25. Adicione ao `ClienteController` o endpoint `GET /api/v1/clientes/estado/{sigla}` que retorna apenas clientes de um determinado estado. Se a sigla tiver mais de 2 caracteres, retorne 400.

**`[I]`** 26. Adicione busca por nome parcial: `GET /api/v1/clientes?nome={termo}` deve retornar clientes cujo nome contenha o termo (case-insensitive).

**`[A]`** 27. Configure o **Springdoc OpenAPI** com:
- Título, versão e descrição da API
- Agrupamento de endpoints por tag (`@Tag`)
- Exemplos de request/response em cada endpoint com `@Schema(example = ...)`
- Acesse `http://localhost:8080/swagger-ui.html` e execute uma operação pela interface

---

## Desafio Integrador — API REST de Produtos e Categorias

Construa uma API REST completa com relacionamento entre entidades:

### Entidades

```
Categoria (id, nome, descricao, ativo)
Produto (id, nome, descricao, preco, estoque, categoria, ativo, dataCadastro)
```

### Endpoints Obrigatórios

| Método | URI | Descrição |
|--------|-----|-----------|
| GET | `/api/v1/categorias` | Lista todas as categorias ativas |
| POST | `/api/v1/categorias` | Cria categoria |
| GET | `/api/v1/categorias/{id}/produtos` | Lista produtos de uma categoria |
| GET | `/api/v1/produtos` | Lista com filtros: `?nome=&categoriaId=&page=&size=` |
| POST | `/api/v1/produtos` | Cria produto |
| PUT | `/api/v1/produtos/{id}` | Atualiza produto |
| PATCH | `/api/v1/produtos/{id}/estoque` | Ajusta estoque (+ ou -) |
| DELETE | `/api/v1/produtos/{id}` | Soft delete |

### Requisitos por Nível

**`[B]`** — CRUD básico de Categoria e Produto funcionando com validação

**`[I]`** — Relacionamento `@ManyToOne` entre Produto e Categoria, paginação, filtros combinados

**`[A]`** — Endpoint de relatório `GET /api/v1/produtos/estoque-critico?limite=5` retornando produtos com estoque abaixo do limite, com documentação Swagger completa

---

*Exercícios do Módulo 05 — 27 exercícios + desafio integrador*
