# 04 — Projeto CRUD: Sistema de Clientes

## Objetivo

Construir um sistema completo de cadastro de clientes com menu interativo no terminal, aplicando todos os conceitos de JDBC: conexão com pool, PreparedStatement, transações e padrão DAO.

---

## Estrutura do Projeto

```
clientes-jdbc/
├── pom.xml
└── src/main/java/br/com/javazero/jdbc/
    ├── Main.java                          ← Menu interativo
    ├── config/
    │   └── ConexaoOracle.java             ← Pool HikariCP
    ├── model/
    │   └── Cliente.java                   ← Entidade
    ├── dao/
    │   ├── ClienteDao.java               ← Interface
    │   └── ClienteDaoOracle.java         ← Implementação
    └── service/
        └── ClienteService.java           ← Regras de negócio
```

---

## pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>br.com.javazero</groupId>
    <artifactId>clientes-jdbc</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>com.oracle.database.jdbc</groupId>
            <artifactId>ojdbc11</artifactId>
            <version>23.3.0.23.09</version>
        </dependency>
        <dependency>
            <groupId>com.zaxxer</groupId>
            <artifactId>HikariCP</artifactId>
            <version>5.1.0</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-simple</artifactId>
            <version>2.0.9</version>
        </dependency>
    </dependencies>
</project>
```

---

## Implementação Completa

### Cliente.java

```java
package br.com.javazero.jdbc.model;

import java.time.LocalDate;

public class Cliente {
    private Long id;
    private String nome;
    private String email;
    private String telefone;
    private String cpf;
    private String cidade;
    private String estado;
    private boolean ativo;
    private LocalDate dataCadastro;

    public Cliente() {}

    public Cliente(String nome, String email, String cpf) {
        this.nome = nome;
        this.email = email;
        this.cpf = cpf;
        this.ativo = true;
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
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
    public LocalDate getDataCadastro() { return dataCadastro; }
    public void setDataCadastro(LocalDate dataCadastro) { this.dataCadastro = dataCadastro; }

    @Override
    public String toString() {
        return String.format("ID: %-6d | %-30s | %-35s | %s/%s",
                id, nome, email,
                cidade != null ? cidade : "—",
                estado != null ? estado : "—");
    }
}
```

### ClienteService.java

```java
package br.com.javazero.jdbc.service;

import br.com.javazero.jdbc.dao.ClienteDao;
import br.com.javazero.jdbc.model.Cliente;

import java.util.List;
import java.util.Optional;

public class ClienteService {

    private final ClienteDao dao;

    public ClienteService(ClienteDao dao) {
        this.dao = dao;
    }

    public Cliente cadastrar(String nome, String email, String cpf,
                              String telefone, String cidade, String estado) {
        // Validações de negócio
        if (nome == null || nome.isBlank())
            throw new IllegalArgumentException("Nome é obrigatório");
        if (email == null || !email.contains("@"))
            throw new IllegalArgumentException("Email inválido");
        if (cpf == null || cpf.isBlank())
            throw new IllegalArgumentException("CPF é obrigatório");

        // Verificar duplicidade de email
        dao.buscarPorEmail(email).ifPresent(c -> {
            throw new IllegalStateException("Email já cadastrado: " + email);
        });

        Cliente c = new Cliente(nome.trim(), email.trim().toLowerCase(), cpf.trim());
        c.setTelefone(telefone != null && !telefone.isBlank() ? telefone.trim() : null);
        c.setCidade(cidade != null && !cidade.isBlank() ? cidade.trim() : null);
        c.setEstado(estado != null && !estado.isBlank() ? estado.toUpperCase().trim() : null);

        return dao.salvar(c);
    }

    public Optional<Cliente> buscarPorId(Long id) {
        return dao.buscarPorId(id);
    }

    public List<Cliente> listarTodos() {
        return dao.listarTodos();
    }

    public List<Cliente> buscarPorEstado(String estado) {
        return dao.buscarPorEstado(estado.toUpperCase());
    }

    public Cliente atualizar(Long id, String nome, String email, String telefone,
                              String cidade, String estado) {
        Cliente cliente = dao.buscarPorId(id)
                .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado: " + id));

        if (nome != null && !nome.isBlank()) cliente.setNome(nome.trim());
        if (email != null && !email.isBlank()) cliente.setEmail(email.trim());
        if (telefone != null) cliente.setTelefone(telefone.trim());
        if (cidade != null) cliente.setCidade(cidade.trim());
        if (estado != null) cliente.setEstado(estado.toUpperCase().trim());

        return dao.atualizar(cliente);
    }

    public void desativar(Long id) {
        dao.buscarPorId(id)
                .orElseThrow(() -> new IllegalArgumentException("Cliente não encontrado: " + id));
        dao.desativar(id);
    }

    public int contar() {
        return dao.contar();
    }
}
```

### Main.java — Menu Interativo

```java
package br.com.javazero.jdbc;

import br.com.javazero.jdbc.config.ConexaoOracle;
import br.com.javazero.jdbc.dao.ClienteDaoOracle;
import br.com.javazero.jdbc.model.Cliente;
import br.com.javazero.jdbc.service.ClienteService;

import java.util.List;
import java.util.Optional;
import java.util.Scanner;

public class Main {

    private static final Scanner scanner = new Scanner(System.in);
    private static final ClienteService service =
            new ClienteService(new ClienteDaoOracle());

    public static void main(String[] args) {
        System.out.println("╔═══════════════════════════════════╗");
        System.out.println("║   Sistema de Clientes — JDBC      ║");
        System.out.println("╚═══════════════════════════════════╝");

        int opcao = -1;
        while (opcao != 0) {
            exibirMenu();
            try {
                opcao = Integer.parseInt(scanner.nextLine().trim());
                processarOpcao(opcao);
            } catch (NumberFormatException e) {
                System.out.println("Opção inválida.");
            } catch (Exception e) {
                System.out.println("Erro: " + e.getMessage());
            }
        }

        ConexaoOracle.fechar();
        scanner.close();
        System.out.println("Sistema encerrado.");
    }

    private static void exibirMenu() {
        int total = service.contar();
        System.out.println("\n--- Menu (" + total + " clientes ativos) ---");
        System.out.println("1. Cadastrar cliente");
        System.out.println("2. Listar todos");
        System.out.println("3. Buscar por ID");
        System.out.println("4. Buscar por estado");
        System.out.println("5. Atualizar cliente");
        System.out.println("6. Desativar cliente");
        System.out.println("0. Sair");
        System.out.print("Opção: ");
    }

    private static void processarOpcao(int opcao) {
        switch (opcao) {
            case 1 -> cadastrar();
            case 2 -> listarTodos();
            case 3 -> buscarPorId();
            case 4 -> buscarPorEstado();
            case 5 -> atualizar();
            case 6 -> desativar();
            case 0 -> System.out.println("Saindo...");
            default -> System.out.println("Opção inválida.");
        }
    }

    private static void cadastrar() {
        System.out.println("\n--- Cadastrar Cliente ---");
        System.out.print("Nome: ");
        String nome = scanner.nextLine();
        System.out.print("Email: ");
        String email = scanner.nextLine();
        System.out.print("CPF (xxx.xxx.xxx-xx): ");
        String cpf = scanner.nextLine();
        System.out.print("Telefone (opcional, Enter para pular): ");
        String telefone = scanner.nextLine();
        System.out.print("Cidade (opcional): ");
        String cidade = scanner.nextLine();
        System.out.print("Estado (UF, opcional): ");
        String estado = scanner.nextLine();

        Cliente c = service.cadastrar(nome, email, cpf,
                telefone.isBlank() ? null : telefone,
                cidade.isBlank() ? null : cidade,
                estado.isBlank() ? null : estado);
        System.out.println("Cliente cadastrado com ID: " + c.getId());
    }

    private static void listarTodos() {
        System.out.println("\n--- Todos os Clientes ---");
        List<Cliente> clientes = service.listarTodos();
        if (clientes.isEmpty()) {
            System.out.println("Nenhum cliente cadastrado.");
        } else {
            clientes.forEach(System.out::println);
        }
    }

    private static void buscarPorId() {
        System.out.print("\nID do cliente: ");
        Long id = Long.parseLong(scanner.nextLine().trim());
        Optional<Cliente> resultado = service.buscarPorId(id);
        resultado.ifPresentOrElse(
                c -> System.out.println(c),
                () -> System.out.println("Cliente não encontrado.")
        );
    }

    private static void buscarPorEstado() {
        System.out.print("\nSigla do estado (ex: SP): ");
        String estado = scanner.nextLine().trim();
        List<Cliente> clientes = service.buscarPorEstado(estado);
        if (clientes.isEmpty()) {
            System.out.println("Nenhum cliente em " + estado.toUpperCase());
        } else {
            System.out.println("Clientes em " + estado.toUpperCase() + ":");
            clientes.forEach(System.out::println);
        }
    }

    private static void atualizar() {
        System.out.print("\nID do cliente a atualizar: ");
        Long id = Long.parseLong(scanner.nextLine().trim());
        service.buscarPorId(id).ifPresentOrElse(c -> {
            System.out.println("Cliente atual: " + c);
            System.out.print("Novo nome (Enter para manter '" + c.getNome() + "'): ");
            String nome = scanner.nextLine();
            System.out.print("Novo email (Enter para manter): ");
            String email = scanner.nextLine();
            System.out.print("Novo telefone (Enter para manter): ");
            String telefone = scanner.nextLine();
            System.out.print("Nova cidade (Enter para manter): ");
            String cidade = scanner.nextLine();
            System.out.print("Novo estado (Enter para manter): ");
            String estado = scanner.nextLine();

            Cliente atualizado = service.atualizar(id,
                    nome.isBlank() ? null : nome,
                    email.isBlank() ? null : email,
                    telefone.isBlank() ? null : telefone,
                    cidade.isBlank() ? null : cidade,
                    estado.isBlank() ? null : estado);
            System.out.println("Atualizado: " + atualizado);
        }, () -> System.out.println("Cliente não encontrado."));
    }

    private static void desativar() {
        System.out.print("\nID do cliente a desativar: ");
        Long id = Long.parseLong(scanner.nextLine().trim());
        service.desativar(id);
        System.out.println("Cliente desativado com sucesso.");
    }
}
```

---

## Como Executar

```bash
# 1. Compilar
mvn clean compile

# 2. Executar (Oracle deve estar rodando)
mvn exec:java -Dexec.mainClass="br.com.javazero.jdbc.Main"

# 3. (Alternativa) Gerar JAR e executar
mvn package
java -jar target/clientes-jdbc-1.0.0.jar
```

---

## Testando o Sistema

Execute os seguintes testes manualmente:

1. **Cadastrar** 5 clientes com cidades e estados diferentes
2. **Listar todos** — verificar se aparecem em ordem alfabética
3. **Buscar por ID** — confirmar dados corretos
4. **Buscar por estado** — filtrar por SP, RJ, etc.
5. **Atualizar** um cliente — mudar telefone e cidade
6. **Desativar** um cliente — verificar que sumiu da listagem
7. Tentar **cadastrar email duplicado** — deve dar erro de negócio
8. Tentar **buscar ID inexistente** — deve retornar mensagem amigável

---

## Erros Comuns e Soluções

| Erro | Causa | Solução |
|------|-------|---------|
| `ORA-12541: no listener` | Oracle não está rodando | `docker-compose up -d` |
| `ORA-01017: invalid credentials` | Senha errada | Verificar `application.properties` |
| `HikariPool-1 - Connection is not available` | Pool esgotado | Aumentar `maximumPoolSize` |
| `ORA-00001: unique constraint violated` | Email/CPF duplicado | Validar antes de inserir |
| `java.sql.SQLIntegrityConstraintViolationException` | FK violada | Verificar dados referenciados |
| `NullPointerException` no ResultSet | Coluna NULL sem tratamento | Usar `rs.wasNull()` ou `getObject()` |

---

## Checklist do Projeto

- [ ] ConexaoOracle com HikariCP funciona
- [ ] Consigo inserir e recuperar um cliente
- [ ] Atualização atualiza corretamente o banco
- [ ] Desativar funciona (soft delete)
- [ ] Erros mostram mensagens amigáveis (sem stack trace exposto ao usuário)
- [ ] Try-with-resources usado em todos os lugares
- [ ] SQL Injection impossível (somente PreparedStatement)
- [ ] Sistema funciona com o menu interativo

---

## Exercícios de Extensão

### Básico
1. Adicione busca por CPF ao menu e ao DAO
2. Exiba a data de cadastro na listagem formatada como `DD/MM/YYYY`

### Intermediário
3. Adicione um relatório que mostra quantos clientes há por estado
4. Implemente busca por nome parcial (LIKE `%nome%`) no menu
5. Adicione a opção de reativar um cliente desativado

### Avançado
6. Crie um segundo DAO `PedidoDao` e integre ao sistema (listar pedidos por cliente)
7. Adicione exportação para CSV: opção no menu que gera `clientes.csv` com todos os dados
8. Implemente paginação: listar 10 clientes por vez com opções "próxima" e "anterior"
