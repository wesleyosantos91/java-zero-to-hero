# 01 — Fundamentos HTTP

## Por que Estudar HTTP Antes do Spring Boot?

Muitos cursos ensinam `@GetMapping` antes de explicar o que é HTTP. O resultado: desenvolvedores que escrevem APIs mas não entendem por que recebem status 403, não sabem a diferença entre GET e POST além do "um tem corpo", e não conseguem depurar problemas de rede.

Você vai entender o protocolo por baixo. Quando chegar no Spring Boot, vai saber o *porquê* de cada anotação.

---

## O que é HTTP?

**HTTP — HyperText Transfer Protocol** é o protocolo de comunicação da web. Funciona no modelo **request-response**: o cliente faz uma requisição, o servidor responde.

```
Cliente (browser, app, curl)          Servidor
         │                                 │
         │──── HTTP Request ──────────────▶│
         │                                 │ processa...
         │◀─── HTTP Response ──────────────│
         │                                 │
```

HTTP é um protocolo **stateless** — cada requisição é independente. O servidor não lembra de requisições anteriores.

---

## Anatomia de uma Requisição HTTP

```
POST /api/v1/clientes HTTP/1.1
Host: api.meusite.com.br
Content-Type: application/json
Authorization: Bearer eyJhbGc...
Accept: application/json

{
  "nome": "Ana Lima",
  "email": "ana@email.com",
  "cpf": "111.111.111-11"
}
```

### Partes da requisição:

| Parte | O que é | Exemplo |
|-------|---------|---------|
| **Método** | Ação desejada | `POST`, `GET`, `PUT`, `DELETE` |
| **URI** | Recurso alvo | `/api/v1/clientes` |
| **Versão HTTP** | Protocolo | `HTTP/1.1` |
| **Headers** | Metadados da requisição | `Content-Type: application/json` |
| **Body** | Dados enviados (opcional) | JSON, form-data |

---

## Métodos HTTP

### GET — Ler um recurso
```bash
# Listar todos os clientes
curl -X GET http://localhost:8080/api/v1/clientes

# Buscar cliente por ID (path parameter)
curl -X GET http://localhost:8080/api/v1/clientes/42

# Com filtro (query parameter)
curl -X GET "http://localhost:8080/api/v1/clientes?estado=SP&ativo=true"
```
- **Corpo:** não tem
- **Idempotente:** sim (múltiplas chamadas = mesmo resultado)
- **Seguro:** sim (não modifica dados)

### POST — Criar um recurso
```bash
curl -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Ana Lima",
    "email": "ana@email.com",
    "cpf": "111.111.111-11"
  }'
```
- **Corpo:** tem (dados do recurso a criar)
- **Idempotente:** não (cada chamada cria um novo recurso)
- **Seguro:** não

### PUT — Substituir um recurso completo
```bash
curl -X PUT http://localhost:8080/api/v1/clientes/42 \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Ana Lima Atualizada",
    "email": "ana.nova@email.com",
    "cpf": "111.111.111-11",
    "telefone": "(11) 99999-0000",
    "cidade": "São Paulo",
    "estado": "SP"
  }'
```
- **Corpo:** tem (representação completa do recurso)
- **Idempotente:** sim (múltiplas chamadas = mesmo estado final)
- **Use quando:** quer substituir o recurso por completo

### PATCH — Atualizar parcialmente
```bash
# Atualiza APENAS o telefone
curl -X PATCH http://localhost:8080/api/v1/clientes/42 \
  -H "Content-Type: application/json" \
  -d '{"telefone": "(11) 99999-0001"}'
```
- **Corpo:** tem (apenas os campos a alterar)
- **Idempotente:** geralmente sim
- **Use quando:** quer atualizar campos específicos

### DELETE — Remover um recurso
```bash
curl -X DELETE http://localhost:8080/api/v1/clientes/42
```
- **Corpo:** não tem
- **Idempotente:** sim (deletar o que não existe = OK)
- **Seguro:** não

### HEAD — Igual ao GET, mas sem corpo na resposta
```bash
# Verificar se o recurso existe (sem baixar os dados)
curl -X HEAD http://localhost:8080/api/v1/clientes/42
```

---

## Anatomia de uma Resposta HTTP

```
HTTP/1.1 201 Created
Content-Type: application/json
Location: /api/v1/clientes/42
X-Request-Id: uuid-1234-5678

{
  "id": 42,
  "nome": "Ana Lima",
  "email": "ana@email.com",
  "dataCadastro": "2026-03-22T10:30:00"
}
```

### Partes da resposta:

| Parte | O que é | Exemplo |
|-------|---------|---------|
| **Status Code** | Resultado da operação | `201 Created` |
| **Headers** | Metadados da resposta | `Content-Type`, `Location` |
| **Body** | Dados retornados | JSON com o recurso criado |

---

## Status Codes — Os Mais Importantes

### 2xx — Sucesso
| Código | Nome | Quando usar |
|--------|------|------------|
| `200` | OK | GET retornou dados, PUT/PATCH com sucesso |
| `201` | Created | POST criou um recurso |
| `204` | No Content | DELETE bem-sucedido (sem corpo) |

### 3xx — Redirecionamento
| Código | Nome | Quando usar |
|--------|------|------------|
| `301` | Moved Permanently | URL mudou definitivamente |
| `302` | Found | Redirecionamento temporário |
| `304` | Not Modified | Cache válido |

### 4xx — Erro do Cliente
| Código | Nome | Quando usar |
|--------|------|------------|
| `400` | Bad Request | Dados inválidos no body/params |
| `401` | Unauthorized | Não autenticado (sem token) |
| `403` | Forbidden | Autenticado mas sem permissão |
| `404` | Not Found | Recurso não existe |
| `405` | Method Not Allowed | Método não suportado no endpoint |
| `409` | Conflict | Conflito (ex: email já cadastrado) |
| `422` | Unprocessable Entity | Dados sintaticamente OK mas semanticamente inválidos |
| `429` | Too Many Requests | Rate limit atingido |

### 5xx — Erro do Servidor
| Código | Nome | Quando usar |
|--------|------|------------|
| `500` | Internal Server Error | Erro inesperado no servidor |
| `502` | Bad Gateway | Servidor intermediário com erro |
| `503` | Service Unavailable | Servidor fora do ar temporariamente |
| `504` | Gateway Timeout | Timeout do servidor intermediário |

---

## Headers Importantes

### Headers de Requisição
```http
Content-Type: application/json     # formato do corpo que estou enviando
Accept: application/json           # formato que quero receber
Authorization: Bearer <token>      # autenticação JWT
X-Request-Id: uuid-1234            # ID único da requisição (rastreabilidade)
If-None-Match: "etag-value"        # cache condicional
```

### Headers de Resposta
```http
Content-Type: application/json     # formato do corpo que estou retornando
Location: /api/v1/clientes/42      # URL do recurso criado (201 Created)
X-Total-Count: 150                 # total de registros (paginação)
Cache-Control: no-cache            # instruções de cache
Retry-After: 60                    # após rate limit: aguarde 60 segundos
```

---

## Usando curl para Testar APIs

`curl` é a ferramenta de linha de comando para fazer requisições HTTP. Todo desenvolvedor de API precisa saber usá-la:

```bash
# GET simples
curl http://localhost:8080/api/v1/clientes

# GET com header e formatação do JSON
curl -s http://localhost:8080/api/v1/clientes | python3 -m json.tool

# POST com JSON
curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome":"Ana","email":"ana@test.com","cpf":"111.111.111-11"}' \
  | python3 -m json.tool

# Mostrar headers da resposta
curl -I http://localhost:8080/api/v1/clientes

# Mostrar headers E body
curl -v http://localhost:8080/api/v1/clientes

# PUT
curl -s -X PUT http://localhost:8080/api/v1/clientes/1 \
  -H "Content-Type: application/json" \
  -d '{"nome":"Ana Lima","email":"ana@email.com","cpf":"111.111.111-11"}'

# PATCH
curl -s -X PATCH http://localhost:8080/api/v1/clientes/1 \
  -H "Content-Type: application/json" \
  -d '{"telefone":"(11) 99999-0000"}'

# DELETE
curl -s -X DELETE http://localhost:8080/api/v1/clientes/1
# Deve retornar 204 (sem body)

# Com autenticação Bearer
curl -s -H "Authorization: Bearer meutoken" http://localhost:8080/api/v1/clientes

# Salvar resposta em arquivo
curl -s http://localhost:8080/api/v1/clientes -o clientes.json
```

---

## Exercícios

### Básico
1. Use `curl -v` em qualquer URL pública (ex: `https://httpbin.org/get`) e identifique: método, URL, headers enviados, status code, headers recebidos, body
2. Qual status code você esperaria para cada situação: (a) buscar cliente que não existe, (b) criar cliente com email inválido, (c) deletar cliente com sucesso, (d) não enviar token de autenticação?
3. Explique com suas palavras a diferença entre PUT e PATCH

### Intermediário
4. Qual a diferença entre `401 Unauthorized` e `403 Forbidden`? Dê um exemplo de cada
5. Por que `GET` é considerado "seguro" e "idempotente" mas `POST` não é?
6. Por que o servidor inclui o header `Location` na resposta `201 Created`?

### Avançado
7. O que significa HTTP ser "stateless"? Como aplicações mantêm sessão do usuário se o protocolo não tem estado?
8. Explique o mecanismo de cache HTTP: o que são ETags, Cache-Control e `304 Not Modified`?
9. Por que nunca devemos logar o header `Authorization` completo nos logs do servidor?
