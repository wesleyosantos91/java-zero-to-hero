# Exercícios — Módulo 04: Fundamentos REST API

Exercícios de compreensão, design e prática com curl. Não é necessário código Java neste módulo — o foco é entender os fundamentos antes de implementar com Spring Boot.

> **Convenção:** `[B]` = Básico · `[I]` = Intermediário · `[A]` = Avançado

---

## Tópico 01 — Fundamentos HTTP

**`[B]`** 1. Identifique os componentes de cada requisição abaixo: método, URL, headers e body (quando houver):

```
(a) GET /api/produtos?categoria=eletronicos HTTP/1.1
    Host: api.loja.com
    Accept: application/json

(b) POST /api/clientes HTTP/1.1
    Content-Type: application/json
    Authorization: Bearer eyJhbGc...

    {"nome":"Ana","email":"ana@email.com"}

(c) DELETE /api/pedidos/42 HTTP/1.1
    Host: api.loja.com
```

**`[B]`** 2. Para cada status HTTP, escreva um exemplo de situação real em uma API de e-commerce:
- `200 OK`
- `201 Created`
- `204 No Content`
- `400 Bad Request`
- `401 Unauthorized`
- `403 Forbidden`
- `404 Not Found`
- `409 Conflict`
- `422 Unprocessable Entity`
- `500 Internal Server Error`

**`[B]`** 3. Use `curl` para fazer requisições a uma API pública. Documente: método, URL, status de resposta e 3 campos do JSON retornado:
```bash
# API pública gratuita (não precisa de autenticação)
curl -s https://jsonplaceholder.typicode.com/users/1
curl -s https://jsonplaceholder.typicode.com/posts?userId=1
curl -s -X POST https://jsonplaceholder.typicode.com/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Teste","body":"Corpo","userId":1}'
```

**`[I]`** 4. Analise a requisição abaixo e liste **todos os problemas**:
```
POST /api/v1/Cliente/Criar HTTP/1.1
Content-Type: text/plain

nome=João&email=joao&ativo=sim
```

**`[I]`** 5. Explique a diferença prática entre `PUT` e `PATCH` para atualizar um cliente que tem os campos `nome`, `email`, `telefone` e `cidade`. Dê exemplos de body para cada um.

---

## Tópico 02 — REST e RESTful

**`[B]`** 6. Corrija as URIs mal projetadas abaixo para seguir as boas práticas REST:
```
(a) /api/GetAllProducts
(b) /api/cliente/createNewCustomer
(c) /api/v1/delete-pedido?id=5
(d) /api/user/42/get-orders
(e) /api/produtos_ativos
(f) /api/search/clientes/by/email
```

**`[B]`** 7. Para uma API de blog (posts e comentários), projete URIs seguindo REST para as operações: listar posts, criar post, buscar post por id, atualizar post, deletar post, listar comentários de um post, adicionar comentário.

**`[I]`** 8. Classifique a API abaixo nos níveis do **Richardson Maturity Model** (0, 1, 2 ou 3) e justifique:
```
# API A:
POST /servico {"acao":"buscarCliente","id":5}
POST /servico {"acao":"criarCliente","nome":"Ana"}

# API B:
GET  /clientes/5
POST /clientes
DELETE /clientes/5

# API C:
GET /clientes/5  →  Response inclui:
  "_links": {
    "self": "/clientes/5",
    "pedidos": "/clientes/5/pedidos",
    "editar": {"href":"/clientes/5","method":"PUT"}
  }
```

**`[I]`** 9. Projete o versionamento de uma API de clientes que passa da v1 (tem `nome`) para a v2 (separa em `primeiroNome` e `sobrenome`). Mostre as 3 estratégias (URL path, header, query param) e indique qual você escolheria e por quê.

**`[A]`** 10. Para cada par de operações, indique se é **idempotente** e **segura**, e justifique:
- `GET /clientes`
- `POST /clientes`
- `PUT /clientes/1` (substitui o recurso inteiro)
- `PATCH /clientes/1` (atualiza apenas o email)
- `DELETE /clientes/1`
- `DELETE /clientes/1` (executado uma segunda vez)

---

## Tópico 03 — JSON e Payload

**`[B]`** 11. Identifique os erros de sintaxe no JSON abaixo:
```json
{
  nome: "João",
  "email": 'joao@email.com',
  "ativo": verdadeiro,
  "telefones": ["(11) 99999-1111", "(11) 8888-2222",],
  "endereco": {
    "cidade": "São Paulo"
    "estado": "SP"
  }
}
```

**`[B]`** 12. Projete os DTOs de **Request** e **Response** para uma API de produtos. O Request recebe `nome`, `preco`, `categoriaId` e `estoque`. O Response retorna esses campos mais `produtoId`, `dataCadastro` e o nome da categoria (não apenas o id).

**`[I]`** 13. Projete a resposta paginada para `GET /api/v1/clientes?page=2&size=10&sort=nome`:
```json
{
  // Inclua: dados, paginação (página atual, total de páginas,
  // total de registros, tamanho), links HATEOAS básicos
}
```

**`[I]`** 14. Projete o formato padrão de **resposta de erro** que sua API usará. Deve incluir campos suficientes para: identificar o tipo de erro, localizar o problema (campo específico em erros de validação), rastrear a requisição e exibir mensagem amigável ao usuário final.

**`[A]`** 15. Analise as duas abordagens de resposta para erros de validação. Qual prefere e por quê?

```json
// Abordagem A: um erro por vez
{"error": "O campo 'email' é obrigatório"}

// Abordagem B: todos os erros juntos
{
  "status": 400,
  "erros": [
    {"campo": "email", "mensagem": "Email é obrigatório"},
    {"campo": "cpf", "mensagem": "CPF inválido"}
  ]
}
```

---

## Tópico 04 — Boas Práticas e Design

**`[B]`** 16. Para cada header abaixo, explique seu propósito e dê um valor de exemplo:
- `Content-Type`
- `Accept`
- `Authorization`
- `Cache-Control`
- `X-Request-ID`
- `X-RateLimit-Remaining`

**`[I]`** 17. Projete o fluxo de autenticação JWT para sua API de clientes:
1. Quais endpoints são públicos (sem token)?
2. Quais requerem autenticação?
3. Como o token deve ser enviado em cada requisição?
4. O que o servidor valida ao receber um token?

**`[I]`** 18. Configure CORS na sua API para que:
- O frontend em `http://localhost:3000` possa acessar durante desenvolvimento
- Em produção, apenas `https://app.minhaempresa.com.br` tenha acesso
- Os métodos `GET`, `POST`, `PUT`, `DELETE` e `PATCH` sejam permitidos
- O header `Authorization` possa ser enviado

**`[A]`** 19. Avalie a API abaixo e liste todos os problemas de design, segurança e boas práticas. Para cada problema, proponha a solução correta:

```
GET  /api/pegarTodosOsClientes?incluirSenha=true
POST /api/clientes/novo-cliente-no-sistema
PUT  /api/updateCliente/42
GET  /api/clientes/busca?sql=SELECT * FROM clientes
DELETE /api/removerTudo
```

---

## Desafio Integrador — Design Completo de API

Projete a documentação completa (sem implementar) de uma API REST para um sistema de agendamento médico:

**Entidades:** Médico, Paciente, Consulta, Especialidade

### Entregáveis

**`[B]`** — Tabela de endpoints com: método, URI, descrição, status de sucesso, status de erro possíveis

**`[I]`** — Para 3 endpoints escolhidos: exemplo completo de Request (headers + body) e Response (headers + body)

**`[I]`** — Formato padrão de erro com exemplos para: 400 (validação), 404 (não encontrado), 409 (conflito de horário), 500 (erro interno)

**`[A]`** — Escreva o arquivo `openapi.yaml` (OpenAPI 3.0) com pelo menos 5 endpoints documentados, incluindo schemas de request/response, exemplos e descrição de cada campo

---

*Exercícios do Módulo 04 — 19 exercícios + desafio integrador*
