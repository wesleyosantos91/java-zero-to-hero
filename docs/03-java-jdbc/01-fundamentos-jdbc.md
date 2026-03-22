# Módulo 3 — Java + JDBC

## Revisão
Você já sabe OO e SQL. Agora vamos conectar os dois mundos.

## JDBC
- **O que é:** API padrão Java para acesso a banco relacional.
- **Por que existe:** desacoplar aplicação dos detalhes do banco.
- **Problema que resolve:** comunicação Java↔SQL padronizada.
- **Quando usar:** integrações diretas e entendimento de baixo nível.
- **Quando evitar:** quando ORM resolve melhor produtividade em projetos grandes.
- **Como funciona:** Driver JDBC implementa protocolo; app usa `Connection`, `PreparedStatement`, `ResultSet`.

## Exemplo simples
```java
try (Connection conn = ds.getConnection();
     PreparedStatement ps = conn.prepareStatement("SELECT id, nome FROM clientes WHERE id = ?")) {
    ps.setLong(1, 1L);
    try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) System.out.println(rs.getString("nome"));
    }
}
```

## Erros comuns
- Não fechar recurso.
- SQL concatenado (risco de injection).
- Regra de negócio no DAO.

## Boas práticas
- `try-with-resources` sempre.
- `PreparedStatement` para parâmetros.
- Camadas: controller/service/repository (mesmo em console didático).
