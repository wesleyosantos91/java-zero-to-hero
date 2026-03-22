# Módulo 4 — Fundamentos de REST API

## Revisão
Até aqui você armazenou dados e criou acesso via JDBC. Agora vai expor recursos via HTTP.

## REST
- O que é: estilo arquitetural para recursos na web.
- Por que existe: padronizar comunicação cliente-servidor.
- Problema que resolve: integração entre sistemas heterogêneos.
- Quando usar: APIs públicas/internas orientadas a recurso.
- Quando evitar: operações fortemente orientadas a comando sem modelo de recurso claro.

## Conceitos
- Recurso: entidade exposta (`/clientes`).
- URI: identificador do recurso.
- Verbo HTTP: intenção da ação.
- Status code: resultado padronizado.

## Verbos
- GET, POST, PUT, PATCH, DELETE.

## Exemplos de request/response
```http
GET /clientes/10
200 OK
{ "id": 10, "nome": "Ana" }
```

```http
POST /clientes
201 Created
Location: /clientes/11
{ "id": 11, "nome": "Rafa" }
```

## Erros comuns
- Usar verbo incorreto para operação.
- Retornar 200 para erro de validação.
- Ignorar idempotência de PUT/DELETE.

## Boas práticas
- Versionamento claro.
- Payloads consistentes.
- Mensagens de erro padronizadas.
