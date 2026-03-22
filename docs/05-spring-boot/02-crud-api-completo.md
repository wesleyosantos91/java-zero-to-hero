# CRUD API Completo

## Componentes essenciais
- Controllers com rotas REST.
- Services com regra de negócio.
- Repositories para persistência.
- DTOs para entrada/saída.
- Bean Validation para validação.
- Exception Handler global para respostas padronizadas.

## Exemplo de validação
```java
public record ClienteRequest(
    @NotBlank String nome,
    @Email String email
) {}
```

## Testes básicos
- Teste de controller (status/contrato).
- Teste de service (regra).
- Teste de integração simples de repositório.

## Troubleshooting
- 404 em rota: verificar `@RequestMapping`.
- 400 em validação: revisar DTO e mensagens.
- Falha Oracle: driver/url/credenciais.
