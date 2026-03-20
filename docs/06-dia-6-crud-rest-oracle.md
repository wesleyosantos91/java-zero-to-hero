# Dia 6 - 26/03/2026 (Quinta, 2h)

Tema: evoluir REST para CRUD persistido no Oracle com JPA.

## Objetivo do dia
1. trocar lista em memoria por persistencia real.
2. criar entidade e repository.
3. implementar CRUD completo com status HTTP corretos.
4. entender anotacoes de JPA e REST envolvidas.

## Conceito antes do codigo

### DTO vs Entidade
- DTO: objeto de entrada/saida da API.
- Entidade: objeto mapeado para tabela do banco.

### Por que separar?
Porque entrada da API pode mudar sem quebrar estrutura de banco.

---

## Bloco 1 - Criar entidade JPA (00:00-00:30)

Arquivo: `src/main/java/br/com/aluno/sistemaclientes/cliente/Cliente.java`

```java
package br.com.aluno.sistemaclientes.cliente;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "clientes")
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 120)
    private String nome;

    @Column(nullable = false, length = 160)
    private String email;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
```

## Conceito das anotacoes JPA
- `@Entity`: marca classe persistivel.
- `@Table`: nome da tabela alvo.
- `@Id`: chave primaria da entidade.
- `@GeneratedValue`: id gerado automaticamente pelo banco.
- `@Column`: restricoes da coluna (tamanho e obrigatoriedade).

---

## Bloco 2 - Criar repository (00:30-00:45)

Arquivo: `src/main/java/br/com/aluno/sistemaclientes/cliente/ClienteRepository.java`

```java
package br.com.aluno.sistemaclientes.cliente;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ClienteRepository extends JpaRepository<Cliente, Long> {
}
```

### Por que `JpaRepository`?
Porque ja entrega CRUD pronto e reduz codigo repetitivo.

---

## Bloco 3 - Atualizar controller para CRUD real (00:45-01:20)

Arquivo: `src/main/java/br/com/aluno/sistemaclientes/ClienteController.java`

```java
package br.com.aluno.sistemaclientes;

import br.com.aluno.sistemaclientes.cliente.Cliente;
import br.com.aluno.sistemaclientes.cliente.ClienteRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/clientes")
public class ClienteController {

    private final ClienteRepository repository;

    public ClienteController(ClienteRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public ResponseEntity<List<Cliente>> listar() {
        return ResponseEntity.ok(repository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Cliente> buscarPorId(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Cliente> criar(@Valid @RequestBody ClienteRequest request) {
        Cliente cliente = new Cliente();
        cliente.setNome(request.getNome());
        cliente.setEmail(request.getEmail());
        Cliente salvo = repository.save(cliente);
        return ResponseEntity.status(201).body(salvo);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Cliente> atualizar(@PathVariable Long id, @Valid @RequestBody ClienteRequest request) {
        return repository.findById(id)
                .map(cliente -> {
                    cliente.setNome(request.getNome());
                    cliente.setEmail(request.getEmail());
                    return ResponseEntity.ok(repository.save(cliente));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remover(@PathVariable Long id) {
        return repository.findById(id)
                .map(cliente -> {
                    repository.delete(cliente);
                    return ResponseEntity.noContent().<Void>build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
```

## Conceito das anotacoes REST usadas aqui
- `@PathVariable`: pega `id` da URL.
- `@RequestBody`: converte JSON em objeto.
- `@Valid`: valida dados de entrada.
- `ResponseEntity`: permite controle fino de status HTTP.

---

## Bloco 4 - Testes de ponta a ponta (01:20-01:55)

### 1) Criar cliente
```powershell
$novo = Invoke-RestMethod -Method Post http://localhost:8080/clientes -ContentType "application/json" -Body '{"nome":"Cliente Dia6","email":"cliente.dia6@email.com"}'
$id = $novo.id
```

### 2) Listar
```powershell
Invoke-RestMethod -Method Get http://localhost:8080/clientes
```

### 3) Buscar por id
```powershell
Invoke-RestMethod -Method Get "http://localhost:8080/clientes/$id"
```

### 4) Atualizar
```powershell
Invoke-RestMethod -Method Put "http://localhost:8080/clientes/$id" -ContentType "application/json" -Body '{"nome":"Cliente Atualizado","email":"cliente.atualizado@email.com"}'
```

### 5) Remover
```powershell
Invoke-WebRequest -Method Delete "http://localhost:8080/clientes/$id"
```

### 6) Confirmar nao encontrado
```powershell
Invoke-RestMethod -Method Get "http://localhost:8080/clientes/$id"
```

Resultado esperado no passo 6: `404`.

---

## Bloco 5 - Revisao conceitual (01:55-02:00)
Perguntas:
1. por que separar DTO de entidade?
2. por que 404 e correto quando id nao existe?
3. por que `JpaRepository` acelera desenvolvimento?

## Checklist do dia
- [ ] entidade e repository criados.
- [ ] CRUD funcional no Oracle.
- [ ] status 200/201/204/404 entendidos.
- [ ] anotacoes JPA e REST explicadas.
