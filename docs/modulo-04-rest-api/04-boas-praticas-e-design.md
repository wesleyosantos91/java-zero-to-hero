# 04 — Boas Práticas e Design de APIs

## Revisão do Tópico Anterior
JSON: tipos, sintaxe, path/query/body params, Request/Response DTOs, paginação, formato de erros. Agora as boas práticas que fazem uma API profissional.

---

## 1. Segurança — Autenticação e Autorização

### Diferença Fundamental

- **Autenticação**: quem é você? (login)
- **Autorização**: o que você pode fazer? (permissões)

```
401 Unauthorized → não autenticado (não fez login)
403 Forbidden    → autenticado mas sem permissão
```

### JWT — JSON Web Token

O padrão de autenticação stateless mais usado em APIs REST:

```
┌────────────────────────────────────────────────────────┐
│                      JWT Token                          │
│                                                         │
│  eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhbmFAZW1haWwuY29t.ABC │
│  │                   │ │                              │  │
│  └── Header (base64) ┘ └── Payload (base64) ──────── ┘  │
│                                       └── Signature ──┘  │
└────────────────────────────────────────────────────────┘
```

**Header:** algoritmo de assinatura
**Payload:** dados do usuário (sub, roles, exp...)
**Signature:** garantia de integridade

```json
// Payload decodificado de um JWT
{
  "sub": "ana@email.com",
  "roles": ["ROLE_USER", "ROLE_ADMIN"],
  "iat": 1742654400,   // issued at (emitido em)
  "exp": 1742740800    // expiration (expira em — 24h depois)
}
```

**Fluxo:**
```
1. POST /auth/login {"email":"ana@email.com","senha":"123456"}
   ← 200 OK {"token": "eyJ...", "expiresIn": 86400}

2. GET /api/v1/clientes
   Authorization: Bearer eyJ...
   ← 200 OK [...clientes...]

3. Token expirado → 401 Unauthorized
   ← {"message": "Token expirado. Faça login novamente."}
```

**Nunca:**
- Guarde senha em JWT
- Use JWT sem HTTPS
- Logar o token completo

---

## 2. CORS — Cross-Origin Resource Sharing

Quando o frontend (React em localhost:3000) chama o backend (Spring Boot em localhost:8080), o browser bloqueia por segurança. CORS configura quais origens são permitidas:

```
Browser: "Ei servidor, posso fazer requisição de http://meusite.com para http://api.meusite.com?"
Servidor: "Sim, origens permitidas: http://meusite.com" → OK
Servidor: "Não, origem não configurada" → Browser bloqueia

Resposta do servidor com CORS configurado:
Access-Control-Allow-Origin: http://meusite.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
```

**No Spring Boot:**
```java
// Global: permite todas as origens (só em desenvolvimento!)
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration config = new CorsConfiguration();
    config.setAllowedOrigins(List.of("http://localhost:3000", "https://meusite.com"));
    config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE"));
    config.setAllowedHeaders(List.of("*"));
    // ...
}

// Por controller:
@CrossOrigin(origins = "http://localhost:3000")
@RestController
public class ClienteController { ... }
```

**Nunca use `*` em produção** — especifique as origens explicitamente.

---

## 3. Rate Limiting

Limite o número de requisições por cliente para proteger contra abuso:

```
# Resposta quando limite atingido:
HTTP/1.1 429 Too Many Requests
Retry-After: 60
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1742654460

{
  "status": 429,
  "message": "Limite de requisições atingido. Tente novamente em 60 segundos."
}
```

Ferramentas: Bucket4j (Java), API Gateway (AWS/Azure), Nginx.

---

## 4. Convenções de Nomenclatura

```json
// Chaves JSON: camelCase (padrão Java/JavaScript)
{
  "nomeCompleto": "Ana Lima",
  "dataNascimento": "1998-05-15",
  "enderecoEntrega": { ... }
}

// Alternativa: snake_case (comum em APIs Python/Ruby)
{
  "nome_completo": "Ana Lima",
  "data_nascimento": "1998-05-15"
}

// Escolha um e seja CONSISTENTE em toda a API
```

---

## 5. Versionamento — Revisão Prática

```bash
# v1 (atual, estável)
GET /api/v1/clientes
# Retorna: {"id": 1, "nome": "Ana", "email": "..."}

# v2 (nova versão com breaking change)
GET /api/v2/clientes
# Retorna: {"clienteId": 1, "nomeCompleto": "Ana Lima", "contato": {...}}

# Estratégia de migração:
# 1. Lançar v2 sem remover v1
# 2. Anunciar deprecação de v1 com data (ex: 6 meses)
# 3. Incluir header: Deprecation: true, Sunset: "2026-09-22"
# 4. Remover v1 após a data
```

---

## 6. Documentação com OpenAPI/Swagger

Toda API precisa de documentação. OpenAPI é o padrão:

```yaml
# openapi.yaml (gerado automaticamente pelo SpringDoc no Spring Boot)
openapi: 3.0.3
info:
  title: API de Clientes
  version: 1.0.0

paths:
  /api/v1/clientes:
    get:
      summary: Lista todos os clientes ativos
      parameters:
        - name: estado
          in: query
          schema: {type: string, example: SP}
        - name: page
          in: query
          schema: {type: integer, default: 0}
      responses:
        '200':
          description: Lista paginada de clientes
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PaginaCliente'
        '401':
          description: Não autenticado
    post:
      summary: Cadastra novo cliente
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ClienteRequest'
      responses:
        '201':
          description: Cliente criado com sucesso
        '400':
          description: Dados inválidos
        '409':
          description: Email já cadastrado
```

**No Spring Boot:**
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>
```

Acesse: `http://localhost:8080/swagger-ui.html`

---

## 7. Checklist de Design de APIs

### Antes de lançar uma API, verifique:

**URIs e Métodos**
- [ ] URIs usam substantivos no plural (`/clientes`, não `/cliente`)
- [ ] Verbos HTTP corretos (GET=ler, POST=criar, PUT=substituir, PATCH=atualizar parcial, DELETE=remover)
- [ ] Sub-recursos representam hierarquia lógica (`/clientes/42/pedidos`)
- [ ] Sem verbos nas URIs (`/buscarClientes` ❌)

**Respostas**
- [ ] Status codes corretos (201 Created no POST, 204 No Content no DELETE)
- [ ] Header `Location` no 201 Created apontando para o recurso criado
- [ ] Body do erro tem estrutura consistente
- [ ] Nenhum stack trace ou detalhe interno exposto no 500

**Dados**
- [ ] Datas em ISO 8601 (`2026-03-22`, não `22/03/2026`)
- [ ] Campos sensíveis não expostos (senha, token, dados internos)
- [ ] Paginação implementada em listagens (nunca retorne 10 mil registros de uma vez)
- [ ] Request DTO e Response DTO separados

**Segurança**
- [ ] HTTPS obrigatório em produção
- [ ] Autenticação via JWT ou OAuth2
- [ ] CORS configurado explicitamente (não `*` em produção)
- [ ] Rate limiting implementado

**Qualidade**
- [ ] API documentada com Swagger/OpenAPI
- [ ] Versionamento na URL (`/api/v1/`)
- [ ] Nomenclatura consistente (camelCase ou snake_case — escolha um)

---

## 8. Anti-Padrões Mais Comuns

```bash
# 1. Verbo na URI
POST /api/criarCliente           ❌
POST /api/v1/clientes            ✅

# 2. GET que modifica dados
GET /clientes/42/deletar         ❌
DELETE /clientes/42              ✅

# 3. Sempre retornar 200
HTTP/1.1 200 OK
{"erro": "Cliente não encontrado"} ❌
HTTP/1.1 404 Not Found           ✅

# 4. Expor detalhes internos no erro 500
{"erro": "ORA-12541: Oracle listener...java.sql.SQLException..."} ❌
{"message": "Erro interno. Por favor, tente novamente."} ✅

# 5. Retornar lista sem paginação
GET /clientes → [... 100.000 clientes ...] ❌
GET /clientes?page=0&size=20 → [20 clientes + metadados] ✅

# 6. Usar IDs sequenciais em URIs públicas
GET /clientes/1  → exposição de volume de dados ⚠️
GET /clientes/uuid-1234-5678 → UUIDs são mais seguros ✅

# 7. Inconsistência de nomenclatura
{"nome": "Ana", "data_cadastro": "...", "telefoneContato": "..."} ❌
{"nome": "Ana", "dataCadastro": "...", "telefone": "..."} ✅
```

---

## Resumo do Tópico

| Prática | Por quê |
|---------|---------|
| JWT para autenticação | Stateless, escalável |
| HTTPS sempre | Protege dados em trânsito |
| CORS explícito | Segurança do browser |
| Rate limiting | Proteção contra abuso |
| Swagger/OpenAPI | Facilita integração |
| Paginação | Performance e UX |
| ISO 8601 | Padrão universal de datas |

---

## Exercícios

### Básico
1. Por que uma API pública NUNCA deve retornar `500 Internal Server Error` com detalhes da exceção Java?
2. Qual a diferença entre CORS e CSRF? Qual deles o Spring Boot trata com `@CrossOrigin`?
3. O que acontece quando um token JWT expira? Como o cliente deve tratar isso?

### Intermediário
4. Projete a estrutura de erro padrão para uma API de pagamentos onde o cartão pode ser recusado por 5 motivos diferentes
5. Configure manualmente um projeto Spring Boot para retornar respostas em snake_case no JSON (dica: `spring.jackson.property-naming-strategy`)
6. Implemente rate limiting simples em memória no Spring Boot (1 requisição por segundo por IP)

### Avançado
7. Projete uma estratégia de versionamento para uma API que já tem 3 clientes em produção e precisa mudar o formato do campo `cpf` de `"111.111.111-11"` para `"11111111111"` (sem máscara)
8. Como implementar autenticação OAuth2 com Google no Spring Boot Security?
9. Explique o conceito de "API First Development" e como ele mudaria o processo de desenvolvimento de uma API
