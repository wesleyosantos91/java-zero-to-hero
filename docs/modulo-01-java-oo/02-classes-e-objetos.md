# 02 — Classes e Objetos

## Revisão do Tópico Anterior
Você aprendeu os fundamentos: tipos primitivos, variáveis, operadores, if/for/while, arrays e métodos estáticos. Agora vamos entrar no coração do Java: a **Orientação a Objetos**.

---

## O Paradigma Orientado a Objetos

No mundo real, tudo é um **objeto**: um carro, uma pessoa, uma conta bancária. Cada objeto tem:
- **Características** (atributos): cor do carro, nome da pessoa, saldo da conta
- **Comportamentos** (métodos): o carro acelera, a pessoa fala, a conta debita

A programação orientada a objetos (POO) modela o software seguindo esse mesmo raciocínio.

### Classe vs Objeto

```
Classe = molde / forma / planta baixa
Objeto = instância concreta da classe

Classe: Carro
  ↓ new Carro()
Objetos: meuGol, minhaF1, seuHb20  (cada um é um objeto distinto)
```

---

## Criando a Primeira Classe

```java
package br.com.javazero.oo;

public class Pessoa {

    // ATRIBUTOS — características do objeto
    String nome;
    int idade;
    double altura;

    // MÉTODO — comportamento do objeto
    public void apresentar() {
        System.out.println("Olá, eu sou " + nome + ", tenho " + idade + " anos.");
    }

    public void fazerAniversario() {
        idade++;  // incrementa a idade em 1
        System.out.println("Feliz aniversário, " + nome + "! Agora tenho " + idade + " anos.");
    }
}
```

### Usando a classe Pessoa

```java
public class Main {
    public static void main(String[] args) {
        // Criando um objeto com 'new'
        Pessoa pessoa1 = new Pessoa();

        // Atribuindo valores aos atributos
        pessoa1.nome = "Ana";
        pessoa1.idade = 28;
        pessoa1.altura = 1.65;

        // Chamando métodos
        pessoa1.apresentar();      // Olá, eu sou Ana, tenho 28 anos.
        pessoa1.fazerAniversario(); // Feliz aniversário, Ana! Agora tenho 29 anos.

        // Cada objeto é INDEPENDENTE
        Pessoa pessoa2 = new Pessoa();
        pessoa2.nome = "Carlos";
        pessoa2.idade = 35;

        pessoa2.apresentar();  // Olá, eu sou Carlos, tenho 35 anos.
        // pessoa1 não foi afetado
    }
}
```

---

## Construtores

O **construtor** é um método especial que inicializa o objeto quando ele é criado com `new`.

### Construtor Padrão (sem parâmetros)
```java
public class ContaBancaria {
    String titular;
    double saldo;
    String numeroConta;

    // Construtor padrão — Java cria automaticamente se você não declarar nenhum
    public ContaBancaria() {
        // Valores padrão para atributos primitivos:
        // int/double/long = 0, boolean = false, objetos = null
    }
}
```

### Construtor Parametrizado
```java
public class ContaBancaria {
    String titular;
    double saldo;
    String numeroConta;

    // Construtor parametrizado — obriga o código a fornecer dados iniciais
    public ContaBancaria(String titular, String numeroConta) {
        this.titular = titular;           // 'this' = este objeto
        this.numeroConta = numeroConta;
        this.saldo = 0.0;                 // saldo inicial zero
    }

    public void depositar(double valor) {
        if (valor > 0) {
            saldo += valor;
            System.out.printf("Depósito de R$%.2f. Novo saldo: R$%.2f%n", valor, saldo);
        }
    }

    public void sacar(double valor) {
        if (valor > 0 && valor <= saldo) {
            saldo -= valor;
            System.out.printf("Saque de R$%.2f. Novo saldo: R$%.2f%n", valor, saldo);
        } else {
            System.out.println("Saldo insuficiente ou valor inválido.");
        }
    }

    public void exibirExtrato() {
        System.out.println("=== Conta: " + numeroConta + " ===");
        System.out.println("Titular: " + titular);
        System.out.printf("Saldo: R$%.2f%n", saldo);
    }
}
```

### Usando com construtor parametrizado
```java
public class Main {
    public static void main(String[] args) {
        // Obrigado a passar titular e numeroConta
        ContaBancaria conta = new ContaBancaria("Ana Silva", "001-5");

        conta.depositar(1000.00);
        conta.depositar(500.00);
        conta.sacar(200.00);
        conta.exibirExtrato();
    }
}
```

### Múltiplos Construtores (Sobrecarga)
```java
public class Produto {
    String nome;
    double preco;
    int estoque;

    // Construtor mínimo
    public Produto(String nome, double preco) {
        this.nome = nome;
        this.preco = preco;
        this.estoque = 0;  // padrão
    }

    // Construtor completo
    public Produto(String nome, double preco, int estoque) {
        this.nome = nome;
        this.preco = preco;
        this.estoque = estoque;
    }

    // Construtor chamando outro construtor com this()
    public Produto(String nome) {
        this(nome, 0.0);  // chama o construtor de 2 parâmetros
    }
}
```

---

## A Palavra-chave `this`

`this` refere-se ao **objeto atual** — a instância que está executando o método:

```java
public class Funcionario {
    String nome;
    double salario;

    // Sem 'this': parâmetro 'nome' oculta o atributo 'nome'
    public void setNomeErrado(String nome) {
        nome = nome;  // ERRO LÓGICO! Atribui parâmetro a si mesmo
    }

    // Com 'this': diferencia atributo (this.nome) do parâmetro (nome)
    public void setNomeCorreto(String nome) {
        this.nome = nome;  // atributo recebe o valor do parâmetro
    }

    // 'this' também pode chamar outro método do mesmo objeto
    public void exibirInfo() {
        System.out.println("Nome: " + this.nome);
        System.out.println("Salário: " + this.salario);
        this.calcularBonus();  // chama outro método
    }

    private void calcularBonus() {
        System.out.println("Bônus: " + (salario * 0.1));
    }
}
```

---

## Referências e `null`

Em Java, variáveis de objetos são **referências** (apontam para onde o objeto está na memória), não o objeto em si.

```java
Pessoa p1 = new Pessoa();
p1.nome = "Ana";

// p2 aponta para o MESMO objeto que p1
Pessoa p2 = p1;
p2.nome = "Carlos";  // modifica o mesmo objeto!

System.out.println(p1.nome);  // Carlos (!) — mesma referência

// null = referência que não aponta para nenhum objeto
Pessoa p3 = null;
// p3.nome = "Erro!";  // NullPointerException! p3 não aponta para nenhum objeto
```

### Verificando null antes de usar
```java
public void imprimirNome(Pessoa pessoa) {
    if (pessoa != null) {
        System.out.println(pessoa.nome);
    } else {
        System.out.println("Pessoa não informada");
    }
}

// Java 8+: Objects.requireNonNull para validação explícita
import java.util.Objects;
Objects.requireNonNull(pessoa, "Pessoa não pode ser null");
```

---

## Garbage Collector

Em Java, você **não precisa** liberar memória manualmente. O Garbage Collector (GC) faz isso automaticamente:

```java
Pessoa p = new Pessoa();  // objeto criado na memória
p.nome = "Ana";

p = new Pessoa();  // p agora aponta para novo objeto
// O objeto anterior ("Ana") não tem mais referências
// O Garbage Collector vai liberar essa memória automaticamente
```

Isso evita os problemas de memory leak e dangling pointers que existem em C/C++.

---

## Sobrescrevendo `toString()`

Por padrão, `System.out.println(objeto)` imprime algo como `Pessoa@1a2b3c` (inútil). Sobrescreva `toString()` para ter uma representação legível:

```java
public class Produto {
    String nome;
    double preco;
    int estoque;

    public Produto(String nome, double preco, int estoque) {
        this.nome = nome;
        this.preco = preco;
        this.estoque = estoque;
    }

    @Override
    public String toString() {
        return "Produto{nome='" + nome + "', preco=" + preco + ", estoque=" + estoque + "}";
    }
}

// Uso:
Produto p = new Produto("Notebook", 3500.00, 10);
System.out.println(p);  // Produto{nome='Notebook', preco=3500.0, estoque=10}
```

---

## Exemplo Completo: Sistema de Biblioteca Simples

```java
package br.com.javazero.oo;

public class Livro {
    String titulo;
    String autor;
    int anoPublicacao;
    boolean disponivel;

    public Livro(String titulo, String autor, int anoPublicacao) {
        this.titulo = titulo;
        this.autor = autor;
        this.anoPublicacao = anoPublicacao;
        this.disponivel = true;  // novo livro está disponível
    }

    public void emprestar() {
        if (disponivel) {
            disponivel = false;
            System.out.println("Livro '" + titulo + "' emprestado com sucesso.");
        } else {
            System.out.println("Livro '" + titulo + "' não está disponível.");
        }
    }

    public void devolver() {
        if (!disponivel) {
            disponivel = true;
            System.out.println("Livro '" + titulo + "' devolvido. Obrigado!");
        } else {
            System.out.println("Este livro não estava emprestado.");
        }
    }

    @Override
    public String toString() {
        String status = disponivel ? "Disponível" : "Emprestado";
        return "[" + status + "] " + titulo + " — " + autor + " (" + anoPublicacao + ")";
    }
}
```

```java
public class MainBiblioteca {
    public static void main(String[] args) {
        Livro l1 = new Livro("Clean Code", "Robert C. Martin", 2008);
        Livro l2 = new Livro("Effective Java", "Joshua Bloch", 2018);
        Livro l3 = new Livro("Design Patterns", "Gang of Four", 1994);

        System.out.println("=== Catálogo ===");
        System.out.println(l1);
        System.out.println(l2);
        System.out.println(l3);

        System.out.println("\n=== Operações ===");
        l1.emprestar();
        l1.emprestar();  // tentativa de emprestar novamente
        l2.emprestar();
        l1.devolver();

        System.out.println("\n=== Catálogo Atualizado ===");
        System.out.println(l1);
        System.out.println(l2);
    }
}
```

**Saída esperada:**
```
=== Catálogo ===
[Disponível] Clean Code — Robert C. Martin (2008)
[Disponível] Effective Java — Joshua Bloch (2018)
[Disponível] Design Patterns — Gang of Four (1994)

=== Operações ===
Livro 'Clean Code' emprestado com sucesso.
Livro 'Clean Code' não está disponível.
Livro 'Effective Java' emprestado com sucesso.
Livro 'Clean Code' devolvido. Obrigado!

=== Catálogo Atualizado ===
[Disponível] Clean Code — Robert C. Martin (2008)
[Emprestado] Effective Java — Joshua Bloch (2018)
[Disponível] Design Patterns — Gang of Four (1994)
```

---

## Resumo do Tópico

| Conceito | Definição |
|----------|-----------|
| Classe | Molde que define atributos e métodos |
| Objeto | Instância concreta de uma classe |
| Construtor | Método especial que inicializa o objeto |
| `this` | Referência ao objeto atual |
| `null` | Referência que não aponta para nenhum objeto |
| `toString()` | Representação textual do objeto |
| Garbage Collector | Libera memória de objetos sem referências |

---

## Exercícios

### Básico
1. Crie a classe `Carro` com atributos `marca`, `modelo`, `ano` e método `exibirDados()`
2. Adicione à classe `Carro` um construtor que recebe marca, modelo e ano
3. Sobrescreva `toString()` na classe `Carro`

### Intermediário
4. Crie a classe `ContaCorrente` com `titular`, `numeroConta`, `saldo`. Implemente `depositar()`, `sacar()` e `extrato()`
5. Crie dois objetos `ContaCorrente` e faça transferências entre eles (dica: saque de uma, depósito na outra)
6. Adicione validação no saque: não pode sacar valor negativo nem maior que o saldo

### Avançado
7. Crie uma classe `Aluno` com `nome`, `nota1`, `nota2`, `nota3`. Implemente `calcularMedia()` e `situacao()` (Aprovado ≥ 7, Recuperação ≥ 5, Reprovado)
8. Crie um array de 5 `Aluno` e imprima o relatório da turma com média geral
9. Implemente `equals()` na classe `Aluno` que considera dois alunos iguais se tiverem o mesmo nome (case-insensitive)
