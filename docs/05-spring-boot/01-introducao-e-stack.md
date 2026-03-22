# Módulo 5 — Spring Boot para CRUD e APIs

## Revisão
Você já entende REST conceitualmente. Agora implementará com Spring Boot.

## Decisões de stack
- Java 21 LTS
- Spring Boot 3.3.x (linha estável moderna)
- Maven
- Oracle JDBC driver compatível com JDK 21

## Por que Spring Boot
- O que é: framework opinativo para aplicações Spring.
- Problema que resolve: configuração excessiva.
- Quando usar: APIs e microsserviços Java produtivos.

## Estrutura de projeto
- `controller`
- `service`
- `repository`
- `domain`
- `dto`
- `config`

## Fluxo da requisição
Cliente HTTP → Controller → Service → Repository → Banco → retorno com DTO.
