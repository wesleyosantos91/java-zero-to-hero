# 05 — Exercícios e Revisão

## Consolidando o Módulo 4

Você concluiu os fundamentos teóricos de REST:
- **HTTP**: métodos, status codes, headers, curl
- **REST**: 6 restrições, RMM, design de URIs, idempotência
- **JSON**: tipos, path/query/body params, DTOs, paginação, erros
- **Boas Práticas**: JWT, CORS, rate limiting, Swagger

---

## 20 Exercícios Graduais

### Bloco 1 — HTTP e Status Codes (1–5)

**Exercício 1:** Qual o status code correto para cada situação?

| Situação | Status |
|----------|--------|
| Criar cliente com sucesso | **201 Created** |
| Deletar cliente com sucesso | **204 No Content** |
| Buscar cliente inexistente | **404 Not Found** |
| Tentar criar cliente sem autenticar | **401 Unauthorized** |
| Tentar deletar sem ser admin | **403 Forbidden** |
| Email já cadastrado | **409 Conflict** |
| CPF com formato inválido | **400 Bad Request** |
| Erro inesperado no servidor | **500 Internal Server Error** |

**Exercício 2:** Usando `curl`, faça as seguintes requisições e identifique: método, URL, status code da resposta, Content-Type da resposta.

```bash
# API pública de teste
curl -v https://jsonplaceholder.typicode.com/users/1
curl -v https://jsonplaceholder.typicode.com/users/9999
curl -v -X POST https://jsonplaceholder.typicode.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Ana","email":"ana@test.com"}'
```

**Exercício 3:** Qual a diferença prática entre estes dois endpoints?
```
PUT  /clientes/42   → corpo: {"nome":"Ana","email":"a@b.com","cpf":"111","telefone":null}
PATCH /clientes/42  → corpo: {"telefone": "(11) 99999-0000"}
```

**Resposta:** PUT substitui o recurso completo (todos os campos devem ser enviados); PATCH atualiza apenas os campos enviados. Com PUT, se você omitir `telefone`, ele vira null. Com PATCH, apenas o `telefone` é atualizado.

**Exercício 4:** Por que GET é seguro e idempotente, mas POST não é nem seguro nem idempotente? Cite um cenário onde POST não idempotente causa problema real.

**Resposta modelo:** GET apenas lê — nunca modifica dados. POST cria recursos: chamar `POST /pedidos` duas vezes pode criar dois pedidos duplicados. Problema real: usuário clica "Confirmar Compra" duas vezes rapidamente → dois pedidos criados. Solução: Idempotency-Key no header.

**Exercício 5:** Analise a resposta HTTP abaixo e identifique todos os problemas:
```
HTTP/1.1 200 OK
{"erro": "Usuário não autenticado. Faça login para continuar."}
```

**Resposta:** Status 200 deveria ser 401 Unauthorized. O corpo da resposta indica erro, mas o status diz sucesso — inconsistência que quebra clientes que verificam status codes.

---

### Bloco 2 — Design de URIs e REST (6–10)

**Exercício 6:** Redesenhe estas URIs mal projetadas:

| URI Ruim | URI Correta |
|---------|------------|
| `GET /buscarTodosOsPedidos` | `GET /pedidos` |
| `POST /criarNovoCliente` | `POST /clientes` |
| `GET /cliente?id=42` | `GET /clientes/42` |
| `DELETE /deletarPedido/7` | `DELETE /pedidos/7` |
| `GET /getPedidosDoCliente/42` | `GET /clientes/42/pedidos` |
| `POST /pedidos/7/adicionarItem` | `POST /pedidos/7/itens` |

**Exercício 7:** Projete os endpoints REST completos para um sistema de blog com posts e comentários.

**Resposta:**
```
GET    /posts                     → listar posts (paginado)
GET    /posts/{id}                → buscar post
POST   /posts                     → criar post
PUT    /posts/{id}                → atualizar post
DELETE /posts/{id}                → deletar post

GET    /posts/{id}/comentarios    → listar comentários do post
POST   /posts/{id}/comentarios    → adicionar comentário
DELETE /posts/{postId}/comentarios/{comentarioId} → deletar comentário

POST   /posts/{id}/publicar       → publicar post
POST   /posts/{id}/arquivar       → arquivar post
```

**Exercício 8:** Em que nível do Modelo de Maturidade de Richardson está cada API?

```
API A: usa apenas POST para tudo, todos endpoints em /api
Nível: 0 (swamp of POX)

API B: endpoints distintos por recurso, mas usa só GET e POST
Nível: 1 (recursos)

API C: verbos corretos, status codes corretos, sem HATEOAS
Nível: 2 ← a maioria das APIs do mercado

API D: verbos corretos, status codes corretos, respostas incluem _links
Nível: 3 (HATEOAS)
```

**Exercício 9:** Qual endpoint(s) a requisição `GET /clientes/42/pedidos/7/itens/3` sugere? Quais recursos hierárquicos existem?

**Resposta:** Busca o item de id=3 do pedido de id=7 do cliente de id=42. Hierarquia: Cliente → Pedido → Item do Pedido.

**Exercício 10:** Por que uma API stateless não pode usar cookies de sessão para autenticação? Qual a alternativa?

**Resposta:** Cookies de sessão exigem que o servidor guarde estado da sessão. Em cluster com múltiplos servidores, a sessão precisa ser compartilhada (Redis) ou o load balancer precisa usar sticky sessions — quebrando a escalabildiade horizontal. JWT é a alternativa: toda informação está no token; qualquer servidor pode validar sem consultar estado.

---

### Bloco 3 — JSON e Payloads (11–15)

**Exercício 11:** Corrija os erros de sintaxe JSON:

```json
// Versão com erros:
{
  'nome': 'Ana Lima',
  "email": "ana@email.com",
  "ativo": True,
  "telefones": ["(11) 99999-1111", "(21) 88888-2222",],
  "endereco": {
    "cidade": "São Paulo"
    "estado": "SP"
  }
}
```

```json
// Versão corrigida:
{
  "nome": "Ana Lima",
  "email": "ana@email.com",
  "ativo": true,
  "telefones": ["(11) 99999-1111", "(21) 88888-2222"],
  "endereco": {
    "cidade": "São Paulo",
    "estado": "SP"
  }
}
```

**Exercício 12:** Escreva o Request DTO e Response DTO para o endpoint `POST /api/v1/pedidos`.

```json
// Request DTO (o que o cliente envia):
{
  "clienteId": 42,
  "itens": [
    {"produtoId": 1, "quantidade": 2},
    {"produtoId": 5, "quantidade": 1}
  ],
  "observacao": "Entregar após 18h"
}

// Response DTO 201 Created (o que o servidor retorna):
{
  "id": 1023,
  "status": "PENDENTE",
  "dataPedido": "2026-03-22T14:30:00",
  "cliente": {"id": 42, "nome": "Ana Lima"},
  "itens": [
    {
      "produto": {"id": 1, "nome": "Notebook Dell"},
      "quantidade": 2,
      "precoUnitario": 3499.90,
      "subtotal": 6999.80
    },
    {
      "produto": {"id": 5, "nome": "Mouse Logitech"},
      "quantidade": 1,
      "precoUnitario": 399.00,
      "subtotal": 399.00
    }
  ],
  "total": 7398.80
}
```

**Exercício 13:** Escreva a query string para: listar clientes do estado SP, ativos, ordenados por nome, página 2 (índice base 0), 15 por página.

```
GET /api/v1/clientes?estado=SP&ativo=true&sort=nome,asc&page=1&size=15
```

**Exercício 14:** Por que o campo `senha` nunca deve aparecer no Response DTO, mesmo que esteja na entidade `Cliente`?

**Resposta:** Exposição de senha (mesmo criptografada) é uma vulnerabilidade de segurança. DTOs de resposta devem conter APENAS os dados que o cliente precisa. Nunca exponha hashes de senha, tokens, dados internos.

**Exercício 15:** Formate a data/hora `15 de março de 2026 às 14:30` em formato ISO 8601 para: (a) apenas data, (b) data e hora local, (c) data e hora UTC (horário de Brasília = UTC-3).

```
(a) "2026-03-15"
(b) "2026-03-15T14:30:00"
(c) "2026-03-15T17:30:00Z"  ou  "2026-03-15T14:30:00-03:00"
```

---

### Bloco 4 — Boas Práticas e Segurança (16–20)

**Exercício 16:** Identifique todos os problemas nesta resposta de erro:

```json
HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "ERROR: ORA-00001: unique constraint (SYSTEM.UQ_CLIENTES_EMAIL) violated\n\tat oracle.jdbc.driver.T4CTTIoer11.processError...\n\tat br.com.empresa.ClienteService.salvar(ClienteService.java:45)"
}
```

**Resposta:**
1. Status 200 deveria ser 409 Conflict
2. Stack trace Java exposto (detalhe interno — vulnerabilidade de segurança)
3. Query Oracle exposta (detalhe de implementação)
4. Não é estrutura de erro padronizada

**Exercício 17:** O que é e para que serve o header `Retry-After` em uma resposta `429 Too Many Requests`?

**Resposta:** Indica quantos segundos o cliente deve aguardar antes de tentar novamente. Evita que o cliente entre em loop de retry imediato, causando mais carga.

**Exercício 18:** Por que `Access-Control-Allow-Origin: *` é perigoso em produção para uma API autenticada com JWT?

**Resposta:** Com `*`, qualquer site pode fazer requisições à sua API. Um site malicioso pode criar uma página que faz requisições à sua API com o token JWT do usuário (se guardado no localStorage). Especifique apenas os domínios autorizados.

**Exercício 19:** Projete o fluxo completo de autenticação JWT para login, uso da API e renovação de token.

```
1. Login:
   POST /auth/login {"email":"...","senha":"..."}
   ← 200 OK {"token": "eyJ...", "refreshToken": "eyJ...", "expiresIn": 3600}

2. Uso da API (token válido):
   GET /api/v1/clientes
   Authorization: Bearer eyJ...
   ← 200 OK [...]

3. Token expirado:
   GET /api/v1/clientes
   Authorization: Bearer eyJ... (expirado)
   ← 401 Unauthorized {"message": "Token expirado"}

4. Renovar com refresh token:
   POST /auth/refresh {"refreshToken": "eyJ..."}
   ← 200 OK {"token": "eyJ...NOVO...", "expiresIn": 3600}

5. Logout:
   POST /auth/logout (invalida refresh token no servidor)
   ← 204 No Content
```

**Exercício 20:** Dado que você está construindo uma API pública de produtos (sem autenticação), quais boas práticas de segurança ainda se aplicam?

**Resposta:**
- Rate limiting (evitar scraping e abuso)
- Paginação (evitar retornar todos os dados de uma vez)
- Validação de input (evitar SQL injection, mesmo sem auth)
- HTTPS obrigatório
- Headers de segurança: `X-Content-Type-Options`, `X-Frame-Options`
- Limitação de tamanho do request body
- Não expor detalhes internos nos erros 500

---

## Mapa Mental do Módulo 4

```
REST APIs
├── HTTP
│   ├── Métodos: GET, POST, PUT, PATCH, DELETE
│   ├── Status Codes: 2xx, 3xx, 4xx, 5xx
│   └── Headers: Content-Type, Authorization, Accept
│
├── REST
│   ├── 6 Restrições: stateless, client-server, cacheable...
│   ├── RMM: Nível 0, 1, 2, 3 (HATEOAS)
│   ├── URIs: substantivos, hierarquia, plural
│   └── Idempotência
│
├── JSON e Payloads
│   ├── Tipos: string, number, boolean, null, array, object
│   ├── Parâmetros: path, query, body, header
│   ├── DTOs: Request ≠ Response
│   ├── Paginação: page, size, sort
│   └── Erros: estrutura consistente, ISO 8601
│
└── Boas Práticas
    ├── Segurança: JWT, HTTPS, CORS explícito
    ├── Rate Limiting: 429 + Retry-After
    ├── Versionamento: /v1/, /v2/
    └── Documentação: OpenAPI/Swagger
```

---

## Parabéns! Módulo 4 Concluído

Você agora tem a base teórica para construir APIs REST profissionais.

**Próximo passo:** Módulo 5 — Spring Boot, onde você implementará tudo isso em Java!
