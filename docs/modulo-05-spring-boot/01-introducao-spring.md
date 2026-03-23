# 01 — Introdução ao Spring Boot

## O que é o Spring Framework?

O Spring Framework é o ecossistema Java mais utilizado no mercado corporativo, criado em 2003. Resolve a criação e gerenciamento de objetos (IoC/DI), elimina código boilerplate e integra com banco de dados, segurança, mensageria e muito mais.

## Spring Boot: Convenção sobre Configuração

O Spring Boot (2014) adiciona auto-configuração ao Spring:
- `application.yml` em vez de XML
- Tomcat embutido (jar auto-executável)
- Spring Initializr gera projeto com dependências compatíveis

## IoC e Injeção de Dependência

```java
// Sem IoC: acoplamento forte
public class ClienteService {
    private ClienteDao dao = new ClienteDaoOracle();
}

// Com IoC: Spring gerencia e injeta
@Service
public class ClienteService {
    private final ClienteRepository repository;

    public ClienteService(ClienteRepository repository) {
        this.repository = repository;
    }
}
```

## Anotações de Componentes

| Anotação | Uso |
|----------|-----|
| `@RestController` | Controller REST (retorna JSON) |
| `@Service` | Lógica de negócio |
| `@Repository` | Acesso ao banco |
| `@Component` | Bean genérico |

## application.yml

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:oracle:thin:@localhost:1521/FREEPDB1
    username: system
    password: oracle
    driver-class-name: oracle.jdbc.OracleDriver
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.OracleDialect
```

## Ponto de Entrada

```java
@SpringBootApplication
public class ClientesApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(ClientesApiApplication.class, args);
    }
}
```

## Exercícios

1. Crie um projeto Spring Boot com Spring Initializr (Spring Web, Data JPA, Validation, DevTools)
2. Adicione endpoint `GET /health` que retorna status UP com timestamp
3. Explique IoC com suas próprias palavras
