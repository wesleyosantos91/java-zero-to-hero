# Design de Endpoints e Contrato

## Path vs Query params
- Path: identifica recurso (`/pedidos/123`).
- Query: filtra/ordena (`/pedidos?status=PAGO`).

## JSON e validação
Defina contrato de campos obrigatórios, opcionais e formatos.

## Mini projeto conceitual
API de biblioteca:
- `GET /livros`
- `POST /livros`
- `GET /livros/{id}`
- `PATCH /livros/{id}/status`
- `DELETE /livros/{id}`

## Fechamento do módulo
- mapa mental textual: recurso → URI → verbo → status → payload.
- exercícios teóricos/práticos no arquivo `exercicios.md`.
