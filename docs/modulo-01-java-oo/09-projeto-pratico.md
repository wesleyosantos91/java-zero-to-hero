# 09 — Projeto Prático: Sistema de Gerenciamento de Biblioteca

## Objetivo

Aplicar **todos os conceitos do Módulo 1** num projeto integrado: classes, encapsulamento, herança, polimorfismo, exceções, collections e enums. Vamos construir um sistema de biblioteca com empréstimo de livros.

---

## Requisitos do Sistema

1. Cadastrar livros (título, autor, ISBN, categoria, ano)
2. Cadastrar usuários (nome, CPF, email, tipo: ALUNO ou FUNCIONARIO)
3. Realizar empréstimo de livro para usuário (com limite de livros por tipo)
4. Devolver livro
5. Listar livros disponíveis
6. Ver histórico de empréstimos por usuário
7. Regras de negócio:
   - Aluno pode ter até 2 livros emprestados
   - Funcionário pode ter até 5 livros
   - Livro não pode ser emprestado se não estiver disponível

---

## Estrutura do Projeto

```
src/br/com/javazero/biblioteca/
├── modelo/
│   ├── Livro.java
│   ├── Usuario.java
│   ├── Aluno.java
│   ├── Funcionario.java
│   └── Emprestimo.java
├── enums/
│   ├── CategoriaLivro.java
│   ├── TipoUsuario.java
│   └── StatusEmprestimo.java
├── excecao/
│   ├── LivroIndisponivelException.java
│   └── LimitEmprestimoException.java
├── repositorio/
│   └── BibliotecaRepositorio.java
├── servico/
│   └── BibliotecaServico.java
└── Main.java
```

---

## Implementação

### Enums

```java
package br.com.javazero.biblioteca.enums;

public enum CategoriaLivro {
    TECNOLOGIA("Tecnologia e Computação"),
    CIENCIAS("Ciências Exatas e Naturais"),
    LITERATURA("Literatura e Ficção"),
    HISTORIA("História e Ciências Sociais"),
    ADMINISTRACAO("Administração e Negócios"),
    DIREITO("Direito e Legislação");

    private final String descricao;
    CategoriaLivro(String descricao) { this.descricao = descricao; }
    public String getDescricao() { return descricao; }
}
```

```java
package br.com.javazero.biblioteca.enums;

public enum TipoUsuario {
    ALUNO(2),       // máximo de 2 empréstimos simultâneos
    FUNCIONARIO(5); // máximo de 5

    private final int limiteEmprestimos;
    TipoUsuario(int limite) { this.limiteEmprestimos = limite; }
    public int getLimiteEmprestimos() { return limiteEmprestimos; }
}
```

```java
package br.com.javazero.biblioteca.enums;

public enum StatusEmprestimo {
    ATIVO, DEVOLVIDO, ATRASADO
}
```

### Exceções Customizadas

```java
package br.com.javazero.biblioteca.excecao;

public class LivroIndisponivelException extends RuntimeException {
    public LivroIndisponivelException(String isbn) {
        super("Livro não disponível para empréstimo. ISBN: " + isbn);
    }
}
```

```java
package br.com.javazero.biblioteca.excecao;

public class LimiteEmprestimoException extends RuntimeException {
    public LimiteEmprestimoException(String nome, int limite) {
        super("Usuário '" + nome + "' atingiu o limite de " + limite + " empréstimo(s)");
    }
}
```

### Modelo: Livro

```java
package br.com.javazero.biblioteca.modelo;

import br.com.javazero.biblioteca.enums.CategoriaLivro;

public class Livro {
    private final String isbn;
    private String titulo;
    private String autor;
    private int anoPublicacao;
    private CategoriaLivro categoria;
    private boolean disponivel;

    public Livro(String isbn, String titulo, String autor, int anoPublicacao, CategoriaLivro categoria) {
        if (isbn == null || isbn.isBlank()) throw new IllegalArgumentException("ISBN obrigatório");
        if (titulo == null || titulo.isBlank()) throw new IllegalArgumentException("Título obrigatório");
        this.isbn = isbn;
        this.titulo = titulo;
        this.autor = autor;
        this.anoPublicacao = anoPublicacao;
        this.categoria = categoria;
        this.disponivel = true;
    }

    public String getIsbn() { return isbn; }
    public String getTitulo() { return titulo; }
    public String getAutor() { return autor; }
    public int getAnoPublicacao() { return anoPublicacao; }
    public CategoriaLivro getCategoria() { return categoria; }
    public boolean isDisponivel() { return disponivel; }

    // Controlado pelo serviço, não por setter público
    void setDisponivel(boolean disponivel) { this.disponivel = disponivel; }

    @Override
    public String toString() {
        String status = disponivel ? "✓ Disponível" : "✗ Emprestado";
        return String.format("[%s] %-40s | %s | %s | %d",
                status, titulo, autor, categoria.getDescricao(), anoPublicacao);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof Livro)) return false;
        return isbn.equals(((Livro) obj).isbn);
    }

    @Override
    public int hashCode() { return isbn.hashCode(); }
}
```

### Modelo: Usuário (hierarquia)

```java
package br.com.javazero.biblioteca.modelo;

import br.com.javazero.biblioteca.enums.TipoUsuario;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public abstract class Usuario {
    private final String cpf;
    private String nome;
    private String email;
    private final TipoUsuario tipo;
    private final List<Emprestimo> historicoEmprestimos = new ArrayList<>();

    protected Usuario(String cpf, String nome, String email, TipoUsuario tipo) {
        if (cpf == null || cpf.isBlank()) throw new IllegalArgumentException("CPF obrigatório");
        if (nome == null || nome.isBlank()) throw new IllegalArgumentException("Nome obrigatório");
        this.cpf = cpf;
        this.nome = nome;
        this.email = email;
        this.tipo = tipo;
    }

    public String getCpf() { return cpf; }
    public String getNome() { return nome; }
    public String getEmail() { return email; }
    public TipoUsuario getTipo() { return tipo; }

    public void setNome(String nome) {
        if (nome == null || nome.isBlank()) throw new IllegalArgumentException("Nome obrigatório");
        this.nome = nome;
    }

    public void setEmail(String email) { this.email = email; }

    public int getLimiteEmprestimos() { return tipo.getLimiteEmprestimos(); }

    public long getEmprestimosAtivos() {
        return historicoEmprestimos.stream()
            .filter(e -> e.getStatus() == br.com.javazero.biblioteca.enums.StatusEmprestimo.ATIVO)
            .count();
    }

    public List<Emprestimo> getHistoricoEmprestimos() {
        return Collections.unmodifiableList(historicoEmprestimos);
    }

    // Package-private: só o serviço adiciona empréstimos
    void adicionarEmprestimo(Emprestimo emprestimo) {
        historicoEmprestimos.add(emprestimo);
    }

    @Override
    public String toString() {
        return String.format("[%s] %s (CPF: %s) — Empréstimos ativos: %d/%d",
                tipo, nome, cpf, getEmprestimosAtivos(), getLimiteEmprestimos());
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof Usuario)) return false;
        return cpf.equals(((Usuario) obj).cpf);
    }

    @Override
    public int hashCode() { return cpf.hashCode(); }
}
```

```java
package br.com.javazero.biblioteca.modelo;

import br.com.javazero.biblioteca.enums.TipoUsuario;

public class Aluno extends Usuario {
    private String matricula;
    private String curso;

    public Aluno(String cpf, String nome, String email, String matricula, String curso) {
        super(cpf, nome, email, TipoUsuario.ALUNO);
        this.matricula = matricula;
        this.curso = curso;
    }

    public String getMatricula() { return matricula; }
    public String getCurso() { return curso; }

    @Override
    public String toString() {
        return super.toString() + " | Matrícula: " + matricula + " | " + curso;
    }
}
```

```java
package br.com.javazero.biblioteca.modelo;

import br.com.javazero.biblioteca.enums.TipoUsuario;

public class Funcionario extends Usuario {
    private String departamento;
    private String cargo;

    public Funcionario(String cpf, String nome, String email, String departamento, String cargo) {
        super(cpf, nome, email, TipoUsuario.FUNCIONARIO);
        this.departamento = departamento;
        this.cargo = cargo;
    }

    public String getDepartamento() { return departamento; }
    public String getCargo() { return cargo; }

    @Override
    public String toString() {
        return super.toString() + " | " + cargo + " — " + departamento;
    }
}
```

### Modelo: Empréstimo

```java
package br.com.javazero.biblioteca.modelo;

import br.com.javazero.biblioteca.enums.StatusEmprestimo;
import java.time.LocalDate;

public class Emprestimo {
    private final Long id;
    private final Livro livro;
    private final Usuario usuario;
    private final LocalDate dataEmprestimo;
    private final LocalDate dataPrevistaDevolucao;
    private LocalDate dataDevolucao;
    private StatusEmprestimo status;

    private static long contadorId = 0;

    public Emprestimo(Livro livro, Usuario usuario, int prazoEmDias) {
        this.id = ++contadorId;
        this.livro = livro;
        this.usuario = usuario;
        this.dataEmprestimo = LocalDate.now();
        this.dataPrevistaDevolucao = LocalDate.now().plusDays(prazoEmDias);
        this.status = StatusEmprestimo.ATIVO;
    }

    public Long getId() { return id; }
    public Livro getLivro() { return livro; }
    public Usuario getUsuario() { return usuario; }
    public LocalDate getDataEmprestimo() { return dataEmprestimo; }
    public LocalDate getDataPrevistaDevolucao() { return dataPrevistaDevolucao; }
    public LocalDate getDataDevolucao() { return dataDevolucao; }
    public StatusEmprestimo getStatus() { return status; }

    public void devolver() {
        this.dataDevolucao = LocalDate.now();
        this.status = dataDevolucao.isAfter(dataPrevistaDevolucao)
                ? StatusEmprestimo.ATRASADO
                : StatusEmprestimo.DEVOLVIDO;
    }

    @Override
    public String toString() {
        String devolucao = dataDevolucao != null ? dataDevolucao.toString() : "—";
        return String.format("#%d | '%s' → %s | Emprestado: %s | Previsto: %s | Devolvido: %s | %s",
                id, livro.getTitulo(), usuario.getNome(),
                dataEmprestimo, dataPrevistaDevolucao, devolucao, status);
    }
}
```

### Serviço: BibliotecaServico

```java
package br.com.javazero.biblioteca.servico;

import br.com.javazero.biblioteca.excecao.LimiteEmprestimoException;
import br.com.javazero.biblioteca.excecao.LivroIndisponivelException;
import br.com.javazero.biblioteca.modelo.*;
import java.util.*;

public class BibliotecaServico {
    private final Map<String, Livro> livros = new LinkedHashMap<>();
    private final Map<String, Usuario> usuarios = new LinkedHashMap<>();
    private final List<Emprestimo> emprestimos = new ArrayList<>();
    private static final int PRAZO_PADRAO_DIAS = 14;

    public void cadastrarLivro(Livro livro) {
        if (livros.containsKey(livro.getIsbn())) {
            throw new IllegalArgumentException("Livro já cadastrado: ISBN " + livro.getIsbn());
        }
        livros.put(livro.getIsbn(), livro);
        System.out.println("Livro cadastrado: " + livro.getTitulo());
    }

    public void cadastrarUsuario(Usuario usuario) {
        if (usuarios.containsKey(usuario.getCpf())) {
            throw new IllegalArgumentException("Usuário já cadastrado: CPF " + usuario.getCpf());
        }
        usuarios.put(usuario.getCpf(), usuario);
        System.out.println("Usuário cadastrado: " + usuario.getNome());
    }

    public Emprestimo realizarEmprestimo(String isbn, String cpfUsuario) {
        Livro livro = buscarLivro(isbn);
        Usuario usuario = buscarUsuario(cpfUsuario);

        if (!livro.isDisponivel()) {
            throw new LivroIndisponivelException(isbn);
        }

        if (usuario.getEmprestimosAtivos() >= usuario.getLimiteEmprestimos()) {
            throw new LimiteEmprestimoException(usuario.getNome(), usuario.getLimiteEmprestimos());
        }

        Emprestimo emprestimo = new Emprestimo(livro, usuario, PRAZO_PADRAO_DIAS);
        livro.setDisponivel(false);
        usuario.adicionarEmprestimo(emprestimo);
        emprestimos.add(emprestimo);

        System.out.printf("Empréstimo #%d realizado: '%s' → %s (devolver até %s)%n",
                emprestimo.getId(), livro.getTitulo(), usuario.getNome(),
                emprestimo.getDataPrevistaDevolucao());
        return emprestimo;
    }

    public void realizarDevolucao(Long idEmprestimo) {
        Emprestimo emprestimo = emprestimos.stream()
                .filter(e -> e.getId().equals(idEmprestimo))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("Empréstimo não encontrado: #" + idEmprestimo));

        emprestimo.devolver();
        emprestimo.getLivro().setDisponivel(true);

        System.out.printf("Devolução registrada: '%s' | Status: %s%n",
                emprestimo.getLivro().getTitulo(), emprestimo.getStatus());
    }

    public void listarLivrosDisponiveis() {
        System.out.println("\n=== Livros Disponíveis ===");
        livros.values().stream()
                .filter(Livro::isDisponivel)
                .forEach(System.out::println);
    }

    public void listarTodosOsLivros() {
        System.out.println("\n=== Catálogo Completo ===");
        livros.values().forEach(System.out::println);
    }

    public void listarHistoricoUsuario(String cpf) {
        Usuario usuario = buscarUsuario(cpf);
        System.out.println("\n=== Histórico: " + usuario.getNome() + " ===");
        usuario.getHistoricoEmprestimos().forEach(System.out::println);
        if (usuario.getHistoricoEmprestimos().isEmpty()) {
            System.out.println("Nenhum empréstimo registrado.");
        }
    }

    private Livro buscarLivro(String isbn) {
        return Optional.ofNullable(livros.get(isbn))
                .orElseThrow(() -> new NoSuchElementException("Livro não encontrado: ISBN " + isbn));
    }

    private Usuario buscarUsuario(String cpf) {
        return Optional.ofNullable(usuarios.get(cpf))
                .orElseThrow(() -> new NoSuchElementException("Usuário não encontrado: CPF " + cpf));
    }
}
```

### Main — Menu Interativo

```java
package br.com.javazero.biblioteca;

import br.com.javazero.biblioteca.enums.CategoriaLivro;
import br.com.javazero.biblioteca.modelo.*;
import br.com.javazero.biblioteca.servico.BibliotecaServico;
import java.util.Scanner;

public class Main {

    private static final BibliotecaServico servico = new BibliotecaServico();
    private static final Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) {
        carregarDadosIniciais();

        int opcao = -1;
        while (opcao != 0) {
            exibirMenu();
            try {
                opcao = Integer.parseInt(scanner.nextLine().trim());
                processarOpcao(opcao);
            } catch (NumberFormatException e) {
                System.out.println("Opção inválida. Digite um número.");
            } catch (Exception e) {
                System.out.println("Erro: " + e.getMessage());
            }
        }
        System.out.println("Até logo!");
        scanner.close();
    }

    private static void exibirMenu() {
        System.out.println("\n╔══════════════════════════════╗");
        System.out.println("║   BIBLIOTECA JAVA ZERO       ║");
        System.out.println("╠══════════════════════════════╣");
        System.out.println("║ 1. Listar livros disponíveis ║");
        System.out.println("║ 2. Listar catálogo completo  ║");
        System.out.println("║ 3. Realizar empréstimo       ║");
        System.out.println("║ 4. Realizar devolução        ║");
        System.out.println("║ 5. Histórico de usuário      ║");
        System.out.println("║ 0. Sair                      ║");
        System.out.println("╚══════════════════════════════╝");
        System.out.print("Opção: ");
    }

    private static void processarOpcao(int opcao) {
        switch (opcao) {
            case 1 -> servico.listarLivrosDisponiveis();
            case 2 -> servico.listarTodosOsLivros();
            case 3 -> realizarEmprestimo();
            case 4 -> realizarDevolucao();
            case 5 -> verHistorico();
            case 0 -> { /* sair */ }
            default -> System.out.println("Opção inválida");
        }
    }

    private static void realizarEmprestimo() {
        System.out.print("ISBN do livro: ");
        String isbn = scanner.nextLine().trim();
        System.out.print("CPF do usuário: ");
        String cpf = scanner.nextLine().trim();
        servico.realizarEmprestimo(isbn, cpf);
    }

    private static void realizarDevolucao() {
        System.out.print("Número do empréstimo: ");
        Long id = Long.parseLong(scanner.nextLine().trim());
        servico.realizarDevolucao(id);
    }

    private static void verHistorico() {
        System.out.print("CPF do usuário: ");
        String cpf = scanner.nextLine().trim();
        servico.listarHistoricoUsuario(cpf);
    }

    private static void carregarDadosIniciais() {
        // Livros
        servico.cadastrarLivro(new Livro("978-0-13-110362-7", "Clean Code", "Robert C. Martin", 2008, CategoriaLivro.TECNOLOGIA));
        servico.cadastrarLivro(new Livro("978-0-13-468599-1", "Effective Java", "Joshua Bloch", 2018, CategoriaLivro.TECNOLOGIA));
        servico.cadastrarLivro(new Livro("978-0-20-163361-0", "Design Patterns", "Gang of Four", 1994, CategoriaLivro.TECNOLOGIA));
        servico.cadastrarLivro(new Livro("978-0-59-651774-8", "Head First Java", "Kathy Sierra", 2022, CategoriaLivro.TECNOLOGIA));
        servico.cadastrarLivro(new Livro("978-0-13-235088-4", "The Pragmatic Programmer", "David Thomas", 2019, CategoriaLivro.TECNOLOGIA));

        // Usuários
        servico.cadastrarUsuario(new Aluno("111.111.111-11", "Ana Lima", "ana@email.com", "2024001", "Ciência da Computação"));
        servico.cadastrarUsuario(new Aluno("222.222.222-22", "Bruno Costa", "bruno@email.com", "2024002", "Sistemas de Informação"));
        servico.cadastrarUsuario(new Funcionario("333.333.333-33", "Carlos Souza", "carlos@email.com", "TI", "Analista de Sistemas"));
    }
}
```

---

## Como Executar

```bash
# 1. Compile todos os arquivos
find src -name "*.java" | xargs javac -d out

# 2. Execute
java -cp out br.com.javazero.biblioteca.Main
```

---

## Testes Manuais Sugeridos

1. Liste os livros disponíveis (devem aparecer todos os 5)
2. Faça empréstimo de "Clean Code" para Ana (CPF: 111.111.111-11)
3. Tente emprestar "Clean Code" novamente → deve dar erro de disponibilidade
4. Faça 2 empréstimos para Ana → tente um terceiro → deve dar erro de limite
5. Faça devolução do empréstimo #1
6. Liste os livros disponíveis (Clean Code deve aparecer novamente)
7. Veja o histórico de Ana (deve mostrar os empréstimos)

---

## Checklist do Projeto

- [ ] Usei `private` em todos os atributos (encapsulamento)
- [ ] Usei herança onde faz sentido (`Aluno extends Usuario`)
- [ ] Usei polimorfismo (tratei `Aluno` e `Funcionario` como `Usuario`)
- [ ] Usei exceções customizadas para situações de negócio
- [ ] Usei `Optional` para evitar null
- [ ] Usei Collections adequadas (Map para índice por chave, List para histórico)
- [ ] Usei enums para valores fixos (CategoriaLivro, TipoUsuario, StatusEmprestimo)
- [ ] Sobrescrevi `toString()`, `equals()` e `hashCode()` onde necessário
- [ ] O código compila e executa sem erros

---

## Parabéns! Módulo 1 Concluído

Você dominou os fundamentos da programação orientada a objetos em Java:

✅ Fundamentos (tipos, operadores, controle de fluxo)
✅ Classes, objetos e construtores
✅ Encapsulamento e modificadores de acesso
✅ Herança e sobrescrita de métodos
✅ Polimorfismo e abstração
✅ Exceções checked e unchecked
✅ Collections Framework (List, Set, Map)
✅ Enums e boas práticas

**Próximo passo: Módulo 02 — Banco de Dados Relacional e SQL**
