# 05 — CRUD Completo: Projeto Final

## Objetivo

Juntar todos os conceitos do Módulo 5 num projeto completo, funcional e pronto para demonstrar: Controller → Service → Repository → Oracle.

---

## pom.xml Completo

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.3</version>
    </parent>

    <groupId>br.com.javazero</groupId>
    <artifactId>clientes-api</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>com.oracle.database.jdbc</groupId>
            <artifactId>ojdbc11</artifactId>
            <version>23.3.0.23.09</version>
        </dependency>
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>2.3.0</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## application.yml Completo

```yaml
server:
  port: 8080

spring:
  application:
    name: clientes-api

  datasource:
    url: jdbc:oracle:thin:@localhost:1521/FREEPDB1
    username: system
    password: oracle
    driver-class-name: oracle.jdbc.OracleDriver

  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.OracleDialect
        format_sql: true

  jackson:
    serialization:
      write-dates-as-timestamps: false
    date-format: yyyy-MM-dd

springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html

logging:
  level:
    br.com.javazero: DEBUG
    org.springframework.web: INFO
    org.hibernate.SQL: OFF
```

---

## Código Completo

### ClientesApiApplication.java

```java
package br.com.javazero.clientesapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ClientesApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(ClientesApiApplication.class, args);
    }
}
```

### Cliente.java (Entity)

```java
package br.com.javazero.clientesapi.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "clientes")
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_clientes")
    @SequenceGenerator(name = "seq_clientes", sequenceName = "seq_clientes", allocationSize = 1)
    @Column(name = "cliente_id")
    private Long id;

    @Column(nullable = false)
    private String nome;

    @Column(nullable = false, unique = true)
    private String email;

    private String telefone;

    @Column(unique = true)
    private String cpf;

    private String cidade;
    private String estado;

    @Column(nullable = false)
    private Boolean ativo = true;

    @Column(name = "data_cadastro")
    private LocalDate dataCadastro;

    @PrePersist
    void prePersist() {
        dataCadastro = LocalDate.now();
    }

    // Getters e Setters (omitidos por brevidade — gerar via IDE)
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getTelefone() { return telefone; }
    public void setTelefone(String telefone) { this.telefone = telefone; }
    public String getCpf() { return cpf; }
    public void setCpf(String cpf) { this.cpf = cpf; }
    public String getCidade() { return cidade; }
    public void setCidade(String cidade) { this.cidade = cidade; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public Boolean getAtivo() { return ativo; }
    public void setAtivo(Boolean ativo) { this.ativo = ativo; }
    public LocalDate getDataCadastro() { return dataCadastro; }
    public void setDataCadastro(LocalDate d) { this.dataCadastro = d; }
}
```

### ClienteRequest.java e ClienteResponse.java

```java
// dto/ClienteRequest.java
package br.com.javazero.clientesapi.dto;

import jakarta.validation.constraints.*;

public record ClienteRequest(
    @NotBlank(message = "Nome é obrigatório")
    @Size(max = 150)
    String nome,

    @NotBlank(message = "Email é obrigatório")
    @Email(message = "Email inválido")
    String email,

    @Pattern(regexp = "\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}",
             message = "CPF deve ter formato 000.000.000-00")
    String cpf,

    String telefone,
    String cidade,

    @Size(min = 2, max = 2, message = "Estado deve ter 2 caracteres")
    String estado
) {}

// dto/ClienteResponse.java
package br.com.javazero.clientesapi.dto;

import br.com.javazero.clientesapi.entity.Cliente;
import java.time.LocalDate;

public record ClienteResponse(
    Long id,
    String nome,
    String email,
    String telefone,
    String cpf,
    String cidade,
    String estado,
    Boolean ativo,
    LocalDate dataCadastro
) {
    public static ClienteResponse de(Cliente c) {
        return new ClienteResponse(
            c.getId(), c.getNome(), c.getEmail(), c.getTelefone(),
            c.getCpf(), c.getCidade(), c.getEstado(), c.getAtivo(),
            c.getDataCadastro()
        );
    }
}
```

### ClienteRepository.java

```java
package br.com.javazero.clientesapi.repository;

import br.com.javazero.clientesapi.entity.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Long> {
    List<Cliente> findByAtivoTrueOrderByNome();
    List<Cliente> findByEstadoAndAtivoTrue(String estado);
    Optional<Cliente> findByEmail(String email);
    boolean existsByEmail(String email);
    boolean existsByCpf(String cpf);

    @Query("SELECT c FROM Cliente c WHERE c.ativo = true " +
           "AND (:estado IS NULL OR c.estado = :estado)")
    List<Cliente> buscar(@Param("estado") String estado);
}
```

### ClienteService.java

```java
package br.com.javazero.clientesapi.service;

import br.com.javazero.clientesapi.dto.*;
import br.com.javazero.clientesapi.entity.Cliente;
import br.com.javazero.clientesapi.exception.*;
import br.com.javazero.clientesapi.repository.ClienteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class ClienteService {

    private final ClienteRepository repository;

    public ClienteService(ClienteRepository repository) {
        this.repository = repository;
    }

    public List<ClienteResponse> listarTodos() {
        return repository.findByAtivoTrueOrderByNome()
                .stream().map(ClienteResponse::de).toList();
    }

    public ClienteResponse buscarPorId(Long id) {
        return repository.findById(id)
                .filter(Cliente::getAtivo)
                .map(ClienteResponse::de)
                .orElseThrow(() -> new ClienteNotFoundException(id));
    }

    public List<ClienteResponse> buscar(String estado) {
        return repository.buscar(estado).stream().map(ClienteResponse::de).toList();
    }

    @Transactional
    public ClienteResponse criar(ClienteRequest req) {
        if (repository.existsByEmail(req.email())) {
            throw new ConflictException("Email já cadastrado: " + req.email());
        }
        if (req.cpf() != null && repository.existsByCpf(req.cpf())) {
            throw new ConflictException("CPF já cadastrado: " + req.cpf());
        }

        Cliente c = new Cliente();
        c.setNome(req.nome().trim());
        c.setEmail(req.email().trim().toLowerCase());
        c.setCpf(req.cpf());
        c.setTelefone(req.telefone());
        c.setCidade(req.cidade());
        c.setEstado(req.estado() != null ? req.estado().toUpperCase() : null);

        return ClienteResponse.de(repository.save(c));
    }

    @Transactional
    public ClienteResponse atualizar(Long id, ClienteRequest req) {
        Cliente c = repository.findById(id)
                .filter(Cliente::getAtivo)
                .orElseThrow(() -> new ClienteNotFoundException(id));

        repository.findByEmail(req.email())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> { throw new ConflictException("Email já em uso"); });

        c.setNome(req.nome().trim());
        c.setEmail(req.email().trim().toLowerCase());
        c.setTelefone(req.telefone());
        c.setCidade(req.cidade());
        c.setEstado(req.estado() != null ? req.estado().toUpperCase() : null);

        return ClienteResponse.de(repository.save(c));
    }

    @Transactional
    public void alterarStatus(Long id, boolean ativo) {
        Cliente c = repository.findById(id)
                .orElseThrow(() -> new ClienteNotFoundException(id));
        c.setAtivo(ativo);
        repository.save(c);
    }

    @Transactional
    public void deletar(Long id) {
        if (!repository.existsById(id)) throw new ClienteNotFoundException(id);
        alterarStatus(id, false);
    }
}
```

### ClienteController.java (completo)

```java
package br.com.javazero.clientesapi.controller;

import br.com.javazero.clientesapi.dto.*;
import br.com.javazero.clientesapi.service.ClienteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/v1/clientes")
@Tag(name = "Clientes", description = "API de gerenciamento de clientes")
public class ClienteController {

    private final ClienteService service;

    public ClienteController(ClienteService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Lista todos os clientes ativos")
    public ResponseEntity<List<ClienteResponse>> listarTodos(
            @RequestParam(required = false) String estado) {
        if (estado != null) return ResponseEntity.ok(service.buscar(estado));
        return ResponseEntity.ok(service.listarTodos());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Busca cliente por ID")
    public ResponseEntity<ClienteResponse> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(service.buscarPorId(id));
    }

    @PostMapping
    @Operation(summary = "Cadastra novo cliente")
    public ResponseEntity<ClienteResponse> criar(@RequestBody @Valid ClienteRequest req) {
        ClienteResponse criado = service.criar(req);
        return ResponseEntity
                .created(URI.create("/api/v1/clientes/" + criado.id()))
                .body(criado);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualiza cliente")
    public ResponseEntity<ClienteResponse> atualizar(
            @PathVariable Long id,
            @RequestBody @Valid ClienteRequest req) {
        return ResponseEntity.ok(service.atualizar(id, req));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Ativa ou desativa cliente")
    public ResponseEntity<Void> alterarStatus(
            @PathVariable Long id,
            @RequestParam boolean ativo) {
        service.alterarStatus(id, ativo);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Remove cliente (soft delete)")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        service.deletar(id);
        return ResponseEntity.noContent().build();
    }
}
```

---

## Roteiro Completo de Testes com curl

```bash
# 1. Subir Oracle (Docker)
cd docker/ && docker-compose -f docker-compose.oracle.yml up -d

# 2. Subir a API
mvn spring-boot:run

# 3. Verificar saúde
curl -s http://localhost:8080/actuator/health | python3 -m json.tool

# 4. Cadastrar clientes
curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome":"Ana Lima","email":"ana@email.com","cpf":"111.111.111-11","cidade":"São Paulo","estado":"SP"}' \
  | python3 -m json.tool

curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome":"Bruno Costa","email":"bruno@email.com","cpf":"222.222.222-22","cidade":"Rio de Janeiro","estado":"RJ"}' \
  | python3 -m json.tool

# 5. Tentar email duplicado (deve dar 409)
curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{"nome":"Outro","email":"ana@email.com","cpf":"999.999.999-99"}' \
  | python3 -m json.tool

# 6. Listar todos
curl -s http://localhost:8080/api/v1/clientes | python3 -m json.tool

# 7. Buscar por ID
curl -s http://localhost:8080/api/v1/clientes/1 | python3 -m json.tool

# 8. ID inexistente (deve dar 404)
curl -s http://localhost:8080/api/v1/clientes/9999 | python3 -m json.tool

# 9. Atualizar
curl -s -X PUT http://localhost:8080/api/v1/clientes/1 \
  -H "Content-Type: application/json" \
  -d '{"nome":"Ana Lima Atualizada","email":"ana.nova@email.com","cpf":"111.111.111-11","telefone":"(11) 99999-0000","cidade":"Campinas","estado":"SP"}' \
  | python3 -m json.tool

# 10. Desativar
curl -s -X PATCH "http://localhost:8080/api/v1/clientes/1/status?ativo=false"
# Deve retornar 204

# 11. Verificar que desativado não aparece na listagem
curl -s http://localhost:8080/api/v1/clientes | python3 -m json.tool

# 12. Deletar
curl -s -X DELETE http://localhost:8080/api/v1/clientes/2
# Deve retornar 204

# 13. Swagger UI
echo "Acesse: http://localhost:8080/swagger-ui.html"
```

---

## Checklist do Módulo 5

- [ ] Spring Boot 3 rodando na porta 8080
- [ ] Oracle conectado e `ddl-auto: validate` funcionando
- [ ] `GET /api/v1/clientes` retorna lista
- [ ] `POST /api/v1/clientes` retorna 201 com `Location` header
- [ ] Validação retorna 400 com campo por campo
- [ ] Email duplicado retorna 409
- [ ] ID inexistente retorna 404
- [ ] `DELETE` retorna 204
- [ ] Swagger UI acessível em `/swagger-ui.html`
- [ ] Nenhum stack trace exposto em erros 500

**Próximo passo: Módulo 6 — Spring Batch!**
