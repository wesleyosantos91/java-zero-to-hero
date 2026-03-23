# 03 — Services, Repositórios e JPA

## Revisão do Tópico Anterior
Controllers com @GetMapping/@PostMapping, ResponseEntity, @PathVariable/@RequestParam/@RequestBody. Agora a camada de negócio e acesso ao banco.

---

## Arquitetura em Camadas

```
HTTP Request
     ↓
@RestController (ClienteController)
     ↓
@Service (ClienteService)
     ↓
@Repository (ClienteRepository)
     ↓
Oracle Database
```

Cada camada tem responsabilidade única:
- **Controller**: receber e responder requisições HTTP
- **Service**: regras de negócio, validações
- **Repository**: acesso ao banco de dados

---

## Entidade JPA

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

    @Column(nullable = false, length = 150)
    private String nome;

    @Column(nullable = false, unique = true, length = 200)
    private String email;

    @Column(length = 20)
    private String telefone;

    @Column(unique = true, length = 14)
    private String cpf;

    @Column(length = 100)
    private String cidade;

    @Column(length = 2)
    private String estado;

    @Column(nullable = false)
    private Boolean ativo = true;

    @Column(name = "data_cadastro")
    private LocalDate dataCadastro;

    @PrePersist
    void prePersist() {
        this.dataCadastro = LocalDate.now();
        if (this.ativo == null) this.ativo = true;
    }

    // Getters e Setters
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
    public void setDataCadastro(LocalDate dataCadastro) { this.dataCadastro = dataCadastro; }
}
```

---

## Spring Data JPA — Repository

`JpaRepository<T, ID>` fornece CRUD completo automaticamente:

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

    // Spring Data gera a query pelo nome do método:
    List<Cliente> findByAtivoTrue();
    List<Cliente> findByEstadoAndAtivoTrue(String estado);
    Optional<Cliente> findByCpf(String cpf);
    Optional<Cliente> findByEmail(String email);
    boolean existsByEmail(String email);
    boolean existsByCpf(String cpf);
    long countByAtivoTrue();

    // Query JPQL (Java Persistence Query Language)
    @Query("SELECT c FROM Cliente c WHERE c.ativo = true AND " +
           "(:estado IS NULL OR c.estado = :estado) AND " +
           "(:nome IS NULL OR UPPER(c.nome) LIKE UPPER(CONCAT('%', :nome, '%')))")
    List<Cliente> buscarComFiltros(@Param("estado") String estado,
                                   @Param("nome") String nome);

    // Query SQL nativo (Oracle)
    @Query(value = "SELECT * FROM clientes WHERE ROWNUM <= :limite AND ativo = 1 ORDER BY nome",
           nativeQuery = true)
    List<Cliente> buscarPrimeiros(@Param("limite") int limite);

    // Paginação
    org.springframework.data.domain.Page<Cliente> findByAtivoTrue(
            org.springframework.data.domain.Pageable pageable);
}
```

### Métodos gratuitos do JpaRepository

```java
// Salvar (INSERT ou UPDATE)
repository.save(cliente);
repository.saveAll(List.of(c1, c2, c3));

// Buscar
Optional<Cliente> c = repository.findById(42L);
List<Cliente> todos = repository.findAll();
boolean existe = repository.existsById(42L);
long total = repository.count();

// Deletar
repository.deleteById(42L);
repository.delete(cliente);
repository.deleteAll();

// Ordenar
repository.findAll(Sort.by("nome").ascending());
repository.findAll(Sort.by(Sort.Direction.DESC, "dataCadastro"));

// Paginar
Page<Cliente> pagina = repository.findAll(PageRequest.of(0, 20, Sort.by("nome")));
```

---

## Service — Lógica de Negócio

```java
package br.com.javazero.clientesapi.service;

import br.com.javazero.clientesapi.dto.ClienteRequest;
import br.com.javazero.clientesapi.dto.ClienteResponse;
import br.com.javazero.clientesapi.entity.Cliente;
import br.com.javazero.clientesapi.exception.ClienteNotFoundException;
import br.com.javazero.clientesapi.repository.ClienteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional(readOnly = true)  // todas as operações são read-only por padrão
public class ClienteService {

    private final ClienteRepository repository;

    public ClienteService(ClienteRepository repository) {
        this.repository = repository;
    }

    public List<ClienteResponse> listarTodos() {
        return repository.findByAtivoTrue().stream()
                .map(ClienteResponse::de)
                .toList();
    }

    public ClienteResponse buscarPorId(Long id) {
        return repository.findById(id)
                .filter(Cliente::getAtivo)
                .map(ClienteResponse::de)
                .orElseThrow(() -> new ClienteNotFoundException(id));
    }

    public List<ClienteResponse> buscar(String estado, boolean ativo) {
        return repository.buscarComFiltros(estado, null).stream()
                .map(ClienteResponse::de)
                .toList();
    }

    @Transactional  // escrita: sobrescreve o readOnly do nível da classe
    public ClienteResponse criar(ClienteRequest request) {
        if (repository.existsByEmail(request.email())) {
            throw new EmailJaCadastradoException(request.email());
        }
        if (request.cpf() != null && repository.existsByCpf(request.cpf())) {
            throw new CpfJaCadastradoException(request.cpf());
        }

        Cliente cliente = new Cliente();
        cliente.setNome(request.nome().trim());
        cliente.setEmail(request.email().trim().toLowerCase());
        cliente.setCpf(request.cpf());
        cliente.setTelefone(request.telefone());
        cliente.setCidade(request.cidade());
        cliente.setEstado(request.estado() != null ? request.estado().toUpperCase() : null);

        return ClienteResponse.de(repository.save(cliente));
    }

    @Transactional
    public ClienteResponse atualizar(Long id, ClienteRequest request) {
        Cliente cliente = repository.findById(id)
                .filter(Cliente::getAtivo)
                .orElseThrow(() -> new ClienteNotFoundException(id));

        // Verificar email duplicado (exceto o próprio cliente)
        repository.findByEmail(request.email())
                .filter(c -> !c.getId().equals(id))
                .ifPresent(c -> { throw new EmailJaCadastradoException(request.email()); });

        cliente.setNome(request.nome().trim());
        cliente.setEmail(request.email().trim().toLowerCase());
        cliente.setTelefone(request.telefone());
        cliente.setCidade(request.cidade());
        cliente.setEstado(request.estado() != null ? request.estado().toUpperCase() : null);

        return ClienteResponse.de(repository.save(cliente));
    }

    @Transactional
    public void alterarStatus(Long id, boolean ativo) {
        Cliente cliente = repository.findById(id)
                .orElseThrow(() -> new ClienteNotFoundException(id));
        cliente.setAtivo(ativo);
        repository.save(cliente);
    }

    @Transactional
    public void deletar(Long id) {
        if (!repository.existsById(id)) {
            throw new ClienteNotFoundException(id);
        }
        // Soft delete: apenas desativa
        alterarStatus(id, false);
    }
}
```

---

## DTOs

```java
// ClienteRequest.java (record — imutável)
public record ClienteRequest(
    @NotBlank(message = "Nome é obrigatório")
    @Size(max = 150)
    String nome,

    @NotBlank(message = "Email é obrigatório")
    @Email(message = "Email deve ser válido")
    String email,

    @Pattern(regexp = "\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}",
             message = "CPF deve ter formato 000.000.000-00")
    String cpf,

    String telefone,
    String cidade,

    @Size(min = 2, max = 2, message = "Estado deve ter 2 caracteres")
    String estado
) {}

// ClienteResponse.java (record)
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
    // Factory method: converte entidade → DTO
    public static ClienteResponse de(Cliente c) {
        return new ClienteResponse(
            c.getId(), c.getNome(), c.getEmail(),
            c.getTelefone(), c.getCpf(), c.getCidade(),
            c.getEstado(), c.getAtivo(), c.getDataCadastro()
        );
    }
}
```

---

## Transações com Spring

```java
// @Transactional gerencia COMMIT e ROLLBACK automaticamente

@Transactional  // por padrão: rollback em RuntimeException
public ClienteResponse criar(ClienteRequest request) {
    // Se qualquer exceção for lançada: ROLLBACK automático
    Cliente cliente = repository.save(...);
    notificacaoService.enviarBoasVindas(cliente.getEmail());  // se falhar → ROLLBACK
    return ClienteResponse.de(cliente);
}

// Propagation: controla comportamento quando já existe transação
@Transactional(propagation = Propagation.REQUIRED)  // padrão: usa ou cria
@Transactional(propagation = Propagation.REQUIRES_NEW)  // sempre nova transação
@Transactional(propagation = Propagation.NOT_SUPPORTED)  // sem transação

// Isolation: controla leitura concorrente
@Transactional(isolation = Isolation.READ_COMMITTED)  // padrão Oracle

// rollbackFor: rollback para checked exceptions também
@Transactional(rollbackFor = Exception.class)
```

---

## Exceções Customizadas

```java
// ClienteNotFoundException.java
public class ClienteNotFoundException extends RuntimeException {
    public ClienteNotFoundException(Long id) {
        super("Cliente não encontrado com id: " + id);
    }
}

// EmailJaCadastradoException.java
public class EmailJaCadastradoException extends RuntimeException {
    public EmailJaCadastradoException(String email) {
        super("Email já cadastrado: " + email);
    }
}

// CpfJaCadastradoException.java
public class CpfJaCadastradoException extends RuntimeException {
    public CpfJaCadastradoException(String cpf) {
        super("CPF já cadastrado: " + cpf);
    }
}
```

---

## Resumo do Tópico

| Conceito | Uso |
|----------|-----|
| `@Entity` | Mapeia classe para tabela |
| `@Table(name="...")` | Nome da tabela |
| `@Id` + `@GeneratedValue` | Chave primária com geração automática |
| `JpaRepository` | CRUD gratuito + query methods |
| `@Query` | JPQL ou SQL nativo customizado |
| `@Service` | Camada de negócio |
| `@Transactional` | Gerenciamento de transação |

---

## Exercícios

### Básico
1. Crie a entidade `Produto` mapeada para a tabela `produtos`
2. Crie o `ProdutoRepository` com: `findByAtivoTrue()`, `findByCategoriaId(Long id)`, `findByPrecoBetween(double min, double max)`
3. Crie o `ProdutoService` com CRUD completo

### Intermediário
4. Adicione paginação ao `listarTodos()` do ClienteService usando `Page<Cliente>` e `Pageable`
5. Implemente `buscarPorNomeParcial(String nome)` usando `@Query` com JPQL
6. Use `@Transactional(rollbackFor = Exception.class)` e simule uma falha para ver o rollback em ação

### Avançado
7. Configure `spring.jpa.show-sql=true` e analise as queries geradas pelo Spring Data para cada método do repository
8. Implemente auditing automático com `@CreatedDate`, `@LastModifiedDate` usando `@EnableJpaAuditing`
9. Otimize uma query N+1: use `@EntityGraph` ou `JOIN FETCH` para carregar entidades relacionadas em uma só query
