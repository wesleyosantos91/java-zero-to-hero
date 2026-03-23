# 02 — REST e RESTful

## Revisão do Tópico Anterior
Protocolo HTTP: métodos (GET, POST, PUT, PATCH, DELETE), status codes, headers, curl. Agora vamos entender o que é REST.

---

## O que é REST?

**REST — Representational State Transfer** é um estilo arquitetural para sistemas distribuídos, definido por Roy Fielding em sua tese de doutorado (2000). Não é um protocolo, não é um padrão, é um conjunto de **restrições de design**.

Uma API que segue as restrições REST é chamada de **RESTful**.

---

## As 6 Restrições do REST

### 1. Interface Uniforme

Recursos são identificados por URIs e as operações são uniformes (HTTP verbs):

```
# CERTO: URI representa um recurso (substantivo)
GET    /clientes         → lista clientes
GET    /clientes/42      → busca cliente 42
POST   /clientes         → cria cliente
PUT    /clientes/42      → atualiza cliente 42
DELETE /clientes/42      → remove cliente 42

# ERRADO: URI representa ação (verbo)
GET /buscarClientes      ← verbo na URI
POST /criarCliente       ← verbo
GET /deletarCliente/42   ← GET deletando? não!
POST /getCliente/42      ← GET via POST? não!
```

### 2. Stateless (Sem Estado)

O servidor não mantém estado da sessão do cliente. Cada requisição deve conter todas as informações necessárias:

```
# ERRADO (com estado no servidor):
POST /login → servidor guarda sessão do usuário
GET /meuPerfil → servidor lembra quem está logado

# CERTO (stateless):
POST /auth/login → retorna JWT token
GET /clientes/perfil → cliente envia token no header a cada requisição
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Vantagem:** qualquer servidor do cluster pode atender qualquer requisição.

### 3. Cacheable (Cacheável)

Respostas devem indicar se podem ser cacheadas:

```http
# Resposta cacheável (listagem de categorias — muda raramente)
HTTP/1.1 200 OK
Cache-Control: max-age=3600   # válido por 1 hora
ETag: "abc123"

# Resposta não cacheável (saldo bancário — muda constantemente)
HTTP/1.1 200 OK
Cache-Control: no-cache, no-store
```

### 4. Client-Server (Cliente-Servidor)

Interface clara entre cliente e servidor. O cliente não sabe como o servidor armazena dados; o servidor não sabe como o cliente renderiza:

```
Frontend (React/Angular)    ←→    Backend (Spring Boot API)
                               ↑
                          Interface REST
                     (contrato via JSON/HTTP)
```

Isso permite evoluir frontend e backend independentemente.

### 5. Layered System (Sistema em Camadas)

O cliente não sabe se está falando diretamente com o servidor ou com um intermediário:

```
Cliente → [Load Balancer] → [API Gateway] → [Spring Boot App] → [Oracle DB]
```

### 6. Code on Demand (Opcional)

O servidor pode enviar código executável ao cliente (ex: JavaScript). Raramente usado em APIs REST puras.

---

## Modelo de Maturidade de Richardson (RMM)

Leonard Richardson criou um modelo de 4 níveis para classificar o quanto uma API é RESTful:

### Nível 0 — The Swamp of POX

Usa HTTP apenas como transporte. Tudo é POST para uma única URL:

```bash
# Tudo via POST para /api
POST /api
{"acao": "buscarClientes"}

POST /api
{"acao": "criarCliente", "nome": "Ana", "email": "ana@email.com"}

# Típico de SOAP (XML) e alguns sistemas legados
```

### Nível 1 — Recursos

URLs identificam recursos distintos, mas ainda usa POST para tudo:

```bash
POST /clientes          → criar
POST /clientes/buscar   → buscar
POST /clientes/deletar  → deletar
```

Melhorou: recursos identificados. Mas verbos HTTP ainda não usados corretamente.

### Nível 2 — Verbos HTTP

Usa os verbos HTTP corretamente. **A maioria das APIs "REST" do mercado está aqui:**

```bash
GET    /clientes        → listar
GET    /clientes/42     → buscar por ID
POST   /clientes        → criar (201 Created)
PUT    /clientes/42     → atualizar
DELETE /clientes/42     → deletar (204 No Content)
```

Status codes corretos, verbos corretos. Bom para a grande maioria dos casos.

### Nível 3 — HATEOAS

**Hypermedia As The Engine Of Application State** — a resposta inclui links para as próximas ações possíveis:

```json
HTTP/1.1 200 OK
{
  "id": 42,
  "nome": "Ana Lima",
  "email": "ana@email.com",
  "_links": {
    "self": {"href": "/api/v1/clientes/42"},
    "atualizar": {"href": "/api/v1/clientes/42", "method": "PUT"},
    "desativar": {"href": "/api/v1/clientes/42/status", "method": "PATCH"},
    "pedidos": {"href": "/api/v1/clientes/42/pedidos", "method": "GET"}
  }
}
```

O cliente navega pela API seguindo os links — não precisa "saber" as URLs de antemão. Complexo de implementar; raramente necessário em aplicações corporativas típicas.

**Prática:** a maioria das APIs do mercado opera no Nível 2. Nível 3 é utilizado em APIs altamente padronizadas (ex: GitHub, Stripe).

---

## Recursos: Design de URIs

### Boas Práticas de URI

```
# Use substantivos no plural
/clientes        ✅   /cliente       ❌
/pedidos         ✅   /pedido        ❌
/produtos        ✅   /getProdutos   ❌

# Hierarquia para sub-recursos
GET /clientes/42/pedidos             → pedidos do cliente 42
GET /clientes/42/pedidos/7           → pedido 7 do cliente 42
GET /pedidos/7/itens                 → itens do pedido 7

# Minúsculas com hífen (não underscore)
/tipos-de-pagamento  ✅
/tipos_de_pagamento  ❌
/TiposDePagamento    ❌

# Sem extensão de arquivo
/clientes            ✅
/clientes.json       ❌
/clientes.xml        ❌
# Use header Accept para negociar formato:
# Accept: application/json
# Accept: application/xml

# Ações não-CRUD: use substantivo + verbo descritivo
POST /pedidos/42/cancelar           → cancelar pedido 42
POST /clientes/42/ativar            → ativar cliente
POST /pagamentos/42/estornar        → estornar pagamento
```

### Paginação Padronizada

```bash
# Requisição paginada
GET /clientes?pagina=0&tamanho=20&ordenar=nome&direcao=asc

# Resposta com metadados de paginação
{
  "conteudo": [...],
  "paginaAtual": 0,
  "totalPaginas": 8,
  "totalElementos": 147,
  "tamanho": 20,
  "primeiro": true,
  "ultimo": false
}
```

---

## Idempotência na Prática

**Idempotente** = executar N vezes produz o mesmo efeito que executar 1 vez.

| Método | Idempotente? | Seguro? | Motivo |
|--------|:---:|:---:|--------|
| GET | ✅ | ✅ | Apenas lê, nunca modifica |
| HEAD | ✅ | ✅ | Idem, sem corpo |
| POST | ❌ | ❌ | Cada chamada pode criar novo recurso |
| PUT | ✅ | ❌ | Substituição total — mesmo resultado |
| PATCH | ⚠️ | ❌ | Depende da implementação |
| DELETE | ✅ | ❌ | Deletar já deletado = mesmo estado |

```bash
# PUT idempotente:
PUT /clientes/42 {"nome":"Ana","email":"ana@email.com"}
# Chamado 3 vezes → estado final idêntico

# POST não idempotente:
POST /clientes {"nome":"Ana","email":"ana@email.com"}
# Chamado 3 vezes → 3 clientes criados (possivelmente)
# (a menos que o servidor detecte duplicatas)
```

---

## Versionamento de API

Quando a API evolui quebrando compatibilidade, versione para não quebrar clientes existentes:

```bash
# Versionamento na URL (mais comum, mais explícito)
/api/v1/clientes
/api/v2/clientes      # nova versão com mudanças

# Versionamento no header (mais "puro" REST)
GET /api/clientes
Accept: application/vnd.meusite.v2+json

# Versionamento via query parameter (evite)
GET /api/clientes?version=2
```

**Estratégia típica:**
- `v1` continua funcionando para clientes existentes
- `v2` tem as novas features/mudanças
- Anuncie deprecação da `v1` com antecedência (ex: 6 meses)

---

## Resumo

| Conceito | Definição |
|----------|-----------|
| REST | Estilo arquitetural com 6 restrições |
| RESTful | API que segue as restrições REST |
| Stateless | Servidor não guarda estado da sessão |
| RMM Nível 2 | Verbos HTTP corretos + status codes corretos |
| HATEOAS | Respostas com links para próximas ações |
| Idempotente | Múltiplas chamadas = mesmo resultado |

---

## Exercícios

### Básico
1. Classifique estas URIs como bom ou mau design REST e explique por quê:
   - `GET /buscarProduto?id=5`
   - `POST /produtos/criar`
   - `GET /produtos/5`
   - `DELETE /produtos/deletar/5`
2. Quais dos 6 princípios REST uma API que exige cookies de sessão viola? Por quê?
3. Em que nível do RMM está uma API que usa GET e POST apenas, mas com URLs distintas por recurso?

### Intermediário
4. Projete o conjunto completo de endpoints REST para um sistema de pedidos com produtos e clientes
5. Uma API retorna `200 OK` para todos os casos, incluindo erros (`{"erro": "não encontrado"}`). Qual princípio REST isso viola?
6. Por que PATCH não é necessariamente idempotente? Dê um exemplo de PATCH não idempotente

### Avançado
7. Descreva como você implementaria paginação cursor-based em vez de offset-based e quando preferiria uma sobre a outra
8. Explique o conceito de "Content Negotiation" e como implementá-lo com Spring Boot
9. Quais são as implicações de segurança de incluir IDs sequenciais (1, 2, 3...) em URLs de uma API pública?
