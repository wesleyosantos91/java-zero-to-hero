# 03 — JSON e Payload

## Revisão do Tópico Anterior
Princípios REST, Modelo de Maturidade de Richardson, design de URIs, idempotência, versionamento. Agora vamos dominar JSON — o formato de dados dominante em APIs REST.

---

## O que é JSON?

**JSON — JavaScript Object Notation** é um formato de troca de dados leve, legível por humanos e máquinas. Apesar do nome JavaScript, é independente de linguagem.

```json
{
  "nome": "Ana Lima",
  "idade": 28,
  "ativa": true,
  "saldo": 1500.50,
  "endereco": null,
  "telefones": ["(11) 99999-1111", "(11) 3333-4444"],
  "perfil": {
    "cargo": "Desenvolvedora",
    "nivel": "Pleno"
  }
}
```

---

## Tipos de Dados do JSON

| Tipo | Sintaxe | Exemplo |
|------|---------|---------|
| String | Aspas duplas | `"Ana Lima"` |
| Number | Número | `42`, `3.14`, `-100` |
| Boolean | `true` ou `false` | `true`, `false` |
| Null | `null` | `null` |
| Array | `[...]` | `["SP", "RJ", "MG"]` |
| Object | `{...}` | `{"id": 1, "nome": "Ana"}` |

### Erros Comuns de Sintaxe

```json
// INVÁLIDO — aspas simples
{ 'nome': 'Ana' }

// INVÁLIDO — vírgula no final (trailing comma)
{
  "nome": "Ana",
  "email": "ana@email.com",    ← vírgula aqui = ERRO
}

// INVÁLIDO — comentários não existem em JSON
{
  "nome": "Ana"  // este é o nome ← ERRO
}

// INVÁLIDO — chaves sem aspas
{ nome: "Ana" }

// VÁLIDO
{
  "nome": "Ana",
  "email": "ana@email.com"
}
```

---

## Tipos de Parâmetros em APIs REST

### 1. Path Parameter — Identificação de Recurso

```bash
# Template: /clientes/{id}
GET /clientes/42       → cliente com id=42
GET /clientes/999      → cliente com id=999

# Sub-recursos: /clientes/{id}/pedidos/{pedidoId}
GET /clientes/42/pedidos/7
```

**Quando usar:** identificar um recurso específico.

### 2. Query Parameter — Filtros, Paginação, Ordenação

```bash
# Filtros
GET /clientes?estado=SP&ativo=true

# Paginação (Spring Boot padrão)
GET /clientes?page=0&size=20

# Ordenação
GET /clientes?sort=nome,asc
GET /clientes?sort=dataCadastro,desc

# Combinados
GET /clientes?estado=SP&page=0&size=10&sort=nome,asc

# Busca textual
GET /produtos?q=notebook
GET /clientes?nome=Ana
```

**Quando usar:** filtros opcionais, paginação, ordenação, busca.

### 3. Request Body — Dados para Criar/Atualizar

```bash
# POST — criar cliente
POST /clientes
Content-Type: application/json

{
  "nome": "Ana Lima",
  "email": "ana@email.com",
  "cpf": "111.111.111-11",
  "telefone": "(11) 99999-1111",
  "cidade": "São Paulo",
  "estado": "SP"
}

# PUT — atualizar cliente completo
PUT /clientes/42
Content-Type: application/json

{
  "nome": "Ana Lima Atualizada",
  "email": "ana.nova@email.com",
  "cpf": "111.111.111-11",
  "telefone": "(11) 99999-0000",
  "cidade": "Campinas",
  "estado": "SP"
}

# PATCH — atualizar apenas telefone
PATCH /clientes/42
Content-Type: application/json

{
  "telefone": "(11) 99999-0001"
}
```

### 4. Headers — Metadados

```bash
# Autenticação
Authorization: Bearer eyJhbGc...

# Formato do body enviado
Content-Type: application/json

# Formato desejado na resposta
Accept: application/json

# Rastreabilidade
X-Correlation-Id: req-uuid-1234-5678

# Idempotency key (evitar duplicação em POSTs)
Idempotency-Key: client-generated-uuid
```

---

## Design de Payloads

### Request DTO (o que a API recebe)

```json
// POST /clientes — campos mínimos obrigatórios
{
  "nome": "Ana Lima",          // obrigatório
  "email": "ana@email.com",   // obrigatório, único
  "cpf": "111.111.111-11",    // obrigatório, único
  "telefone": "(11) 99999-1111",  // opcional
  "cidade": "São Paulo",           // opcional
  "estado": "SP"                   // opcional
}
```

### Response DTO (o que a API retorna)

```json
// Resposta: mais rico que o request, inclui campos gerados pelo servidor
{
  "id": 42,
  "nome": "Ana Lima",
  "email": "ana@email.com",
  "cpf": "111.111.111-11",
  "telefone": "(11) 99999-1111",
  "cidade": "São Paulo",
  "estado": "SP",
  "ativo": true,
  "dataCadastro": "2026-03-22"
}
```

**Por que ter Request e Response separados?**
- Request: valida o que o cliente pode enviar
- Response: controla o que o servidor expõe (nunca expor senha, token, dados internos)
- Evoluem independentemente

---

## Formato de Datas e Horas em JSON

**Sempre use ISO 8601** — o padrão universal:

```json
{
  "data": "2026-03-22",                    // date only
  "hora": "14:30:00",                      // time only
  "dataHora": "2026-03-22T14:30:00",       // local datetime
  "dataHoraUtc": "2026-03-22T17:30:00Z",   // UTC (Z = UTC)
  "dataHoraBr": "2026-03-22T14:30:00-03:00" // com timezone brasileiro
}
```

**Evite:**
- `"data": "22/03/2026"` — formato brasileiro, ambíguo
- `"timestamp": 1742654400000` — epoch milliseconds, ilegível para humanos
- `"data": "March 22, 2026"` — formato americano por extenso

---

## Formato de Erros Padronizado

Nunca retorne erros sem estrutura. Use um formato consistente:

```json
// 400 Bad Request — erro de validação
{
  "timestamp": "2026-03-22T14:30:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Dados de entrada inválidos",
  "path": "/api/v1/clientes",
  "detalhes": [
    {"campo": "nome", "mensagem": "Nome é obrigatório"},
    {"campo": "email", "mensagem": "Email deve ser válido"},
    {"campo": "cpf", "mensagem": "CPF deve ter formato 000.000.000-00"}
  ]
}

// 404 Not Found
{
  "timestamp": "2026-03-22T14:30:00Z",
  "status": 404,
  "error": "Not Found",
  "message": "Cliente não encontrado com id: 999",
  "path": "/api/v1/clientes/999"
}

// 409 Conflict — email já cadastrado
{
  "timestamp": "2026-03-22T14:30:00Z",
  "status": 409,
  "error": "Conflict",
  "message": "Email já cadastrado: ana@email.com",
  "path": "/api/v1/clientes"
}

// 500 Internal Server Error — nunca exponha detalhes internos!
{
  "timestamp": "2026-03-22T14:30:00Z",
  "status": 500,
  "error": "Internal Server Error",
  "message": "Ocorreu um erro interno. Por favor, tente novamente.",
  "path": "/api/v1/clientes"
  // NÃO inclua: stack trace, query SQL, nome da classe Java
}
```

---

## Paginação de Respostas

```json
// GET /clientes?page=0&size=20&sort=nome,asc
// 200 OK
{
  "content": [
    {"id": 1, "nome": "Ana Lima", "email": "ana@email.com"},
    {"id": 2, "nome": "Bruno Costa", "email": "bruno@email.com"}
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20,
    "sort": {"property": "nome", "direction": "ASC"}
  },
  "totalElements": 147,
  "totalPages": 8,
  "numberOfElements": 20,
  "first": true,
  "last": false
}
```

> O Spring Data JPA retorna este formato automaticamente quando você retorna `Page<T>`.

---

## Exemplos de Payloads do Projeto E-commerce

### Criar Pedido — Request
```json
POST /api/v1/pedidos
{
  "clienteId": 42,
  "enderecoEntrega": {
    "rua": "Av. Paulista",
    "numero": "1578",
    "complemento": "Apto 101",
    "cidade": "São Paulo",
    "estado": "SP",
    "cep": "01310-200"
  },
  "itens": [
    {"produtoId": 1, "quantidade": 2},
    {"produtoId": 5, "quantidade": 1}
  ],
  "observacao": "Não bater campainha"
}
```

### Criar Pedido — Response (201 Created)
```json
{
  "id": 1023,
  "status": "PENDENTE",
  "cliente": {
    "id": 42,
    "nome": "Ana Lima"
  },
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
  "subtotal": 7398.80,
  "frete": 0.00,
  "total": 7398.80,
  "dataPedido": "2026-03-22T14:30:00"
}
```

---

## Resumo do Tópico

| Conceito | Uso |
|----------|-----|
| Path param | `/clientes/42` — identificar recurso |
| Query param | `?estado=SP&page=0` — filtros e paginação |
| Request body | Dados para criar/atualizar (POST, PUT, PATCH) |
| Header | Metadados: auth, content-type |
| ISO 8601 | Formato padrão de datas: `2026-03-22` |
| Request DTO | O que a API aceita |
| Response DTO | O que a API retorna |

---

## Exercícios

### Básico
1. Corrija o JSON inválido: `{'nome': 'Ana', "email": "ana@email.com",}`
2. Escreva o payload JSON para criar um produto com nome, preço, estoque e categoriaId
3. Qual o tipo JSON para: número inteiro, booleano, lista de strings, objeto aninhado?

### Intermediário
4. Projete o Request e Response DTO para o endpoint `POST /api/v1/pedidos`
5. Por que é importante separar Request DTO de Response DTO? Dê exemplos de campos que aparecem só na resposta
6. Escreva o payload de erro para um 422 de CPF inválido e email duplicado ao mesmo tempo

### Avançado
7. Como implementar "partial update" (PATCH) de forma correta? Como distinguir "campo não enviado" de "campo enviado como null"?
8. Projete um formato de resposta paginado para uma API de produtos com filtros por categoria, faixa de preço e disponibilidade
9. O que é "Idempotency-Key" e como usá-lo para garantir que um POST não crie recursos duplicados em caso de retry?
