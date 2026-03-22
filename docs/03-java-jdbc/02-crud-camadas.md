# CRUD JDBC Completo em Camadas

## Arquitetura didática
- `domain`: entidades
- `repository`: acesso ao banco
- `service`: regras de negócio
- `app`: fluxo de entrada/saída

## Operações
- Create: inserir com validação.
- Read: buscar por id/listar.
- Update: atualizar campos permitidos.
- Delete: exclusão segura.

## Segurança básica
- Parâmetros sempre bindados.
- Nunca montar SQL com entrada do usuário.

## Fechamento
- Resumo executivo: JDBC ensina fundamentos essenciais de persistência.
- Exercícios: corrigir código com leak, refatorar DAO gigante, criar paginação simples.
