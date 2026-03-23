# 04 — Herança

## Revisão do Tópico Anterior
Você aprendeu encapsulamento: atributos `private`, getters/setters com validação, `record`. Agora vamos estudar **herança** — reutilização de código entre classes relacionadas.

---

## O Problema que a Herança Resolve

Imagine um sistema com funcionários de diferentes tipos:

```java
// Sem herança — muito código duplicado!
public class Desenvolvedor {
    private String nome;
    private String cpf;
    private double salarioBase;
    // getters, setters, toString...

    public double calcularSalario() {
        return salarioBase * 1.2;  // 20% bônus técnico
    }
}

public class Gerente {
    private String nome;       // DUPLICADO
    private String cpf;        // DUPLICADO
    private double salarioBase; // DUPLICADO
    // mesmos getters, setters, toString... DUPLICADO

    public double calcularSalario() {
        return salarioBase * 1.5;  // 50% bônus gerencial
    }
}
```

Com herança, extraímos o que é comum para uma classe pai (superclasse):

---

## Herança com `extends`

```java
// SUPERCLASSE (pai) — contém o que é COMUM
public class Funcionario {
    private String nome;
    private String cpf;
    private double salarioBase;

    public Funcionario(String nome, String cpf, double salarioBase) {
        this.nome = nome;
        this.cpf = cpf;
        if (salarioBase < 0) throw new IllegalArgumentException("Salário não pode ser negativo");
        this.salarioBase = salarioBase;
    }

    // Getters
    public String getNome() { return nome; }
    public String getCpf() { return cpf; }
    public double getSalarioBase() { return salarioBase; }

    // Método que será SOBRESCRITO pelas subclasses
    public double calcularSalario() {
        return salarioBase;
    }

    @Override
    public String toString() {
        return String.format("%s [%s] - Salário base: R$%.2f", nome, getClass().getSimpleName(), salarioBase);
    }
}
```

```java
// SUBCLASSE (filho) — herda tudo de Funcionario e adiciona o específico
public class Desenvolvedor extends Funcionario {
    private String linguagemPrincipal;

    // super() chama o construtor da superclasse — OBRIGATÓRIO como primeira instrução
    public Desenvolvedor(String nome, String cpf, double salarioBase, String linguagem) {
        super(nome, cpf, salarioBase);
        this.linguagemPrincipal = linguagem;
    }

    public String getLinguagemPrincipal() { return linguagemPrincipal; }

    // SOBRESCREVE o método da superclasse
    @Override
    public double calcularSalario() {
        return getSalarioBase() * 1.20;  // 20% de bônus
    }

    @Override
    public String toString() {
        return super.toString() + " | Linguagem: " + linguagemPrincipal;
    }
}
```

```java
public class Gerente extends Funcionario {
    private int tamanhoEquipe;

    public Gerente(String nome, String cpf, double salarioBase, int tamanhoEquipe) {
        super(nome, cpf, salarioBase);
        this.tamanhoEquipe = tamanhoEquipe;
    }

    public int getTamanhoEquipe() { return tamanhoEquipe; }

    @Override
    public double calcularSalario() {
        return getSalarioBase() * 1.50;  // 50% de bônus
    }

    @Override
    public String toString() {
        return super.toString() + " | Equipe: " + tamanhoEquipe + " pessoas";
    }
}
```

```java
public class Estagiario extends Funcionario {
    private String cursoFaculdade;

    public Estagiario(String nome, String cpf, double bolsa, String curso) {
        super(nome, cpf, bolsa);
        this.cursoFaculdade = curso;
    }

    // Estagiário não tem bônus — herda calcularSalario() sem @Override
    // Mas pode sobrescrever se necessário

    @Override
    public String toString() {
        return super.toString() + " | Curso: " + cursoFaculdade;
    }
}
```

---

## A Palavra-chave `super`

`super` refere-se à **superclasse** e tem dois usos:

```java
// 1. Chamar construtor da superclasse (DEVE ser a primeira linha)
public Desenvolvedor(String nome, String cpf, double salario, String linguagem) {
    super(nome, cpf, salario);  // construtor de Funcionario
    this.linguagemPrincipal = linguagem;
}

// 2. Chamar método da superclasse
@Override
public String toString() {
    return super.toString() + " | Linguagem: " + linguagemPrincipal;
    //     ↑ chama Funcionario.toString()
}
```

---

## @Override — Sobrescrita de Métodos

`@Override` é uma anotação que informa ao compilador: "Este método substitui um método da superclasse". O compilador verifica se a assinatura está correta:

```java
// CERTO: a anotação protege contra erros de digitação
@Override
public double calcularSalario() { ... }

// ERRO: nome errado — @Override detecta o problema
@Override
public double calcularSalarios() { ... }  // Erro de compilação! Não existe esse método na superclasse
```

---

## A Classe `Object` — Mãe de Todas as Classes

Em Java, **toda** classe herda (direta ou indiretamente) de `java.lang.Object`. Métodos importantes de `Object`:

```java
// Object tem estes métodos que podemos sobrescrever:
public String toString()       // representação textual
public boolean equals(Object o) // igualdade lógica
public int hashCode()          // código hash (para HashMap, HashSet)
public Object clone()          // cópia (raro)
```

### Sobrescrevendo `equals()` e `hashCode()`

```java
public class Produto {
    private String codigo;
    private String nome;
    private double preco;

    public Produto(String codigo, String nome, double preco) {
        this.codigo = codigo;
        this.nome = nome;
        this.preco = preco;
    }

    public String getCodigo() { return codigo; }

    // equals: dois Produtos são iguais se tiverem o mesmo código
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;          // mesma referência
        if (obj == null) return false;          // null não é igual a nada
        if (!(obj instanceof Produto)) return false;  // tipo diferente
        Produto outro = (Produto) obj;
        return this.codigo.equals(outro.codigo);  // comparação pelo código
    }

    // hashCode DEVE ser consistente com equals
    // Se dois objetos são equals, devem ter o mesmo hashCode
    @Override
    public int hashCode() {
        return codigo.hashCode();
    }

    @Override
    public String toString() {
        return String.format("Produto{codigo='%s', nome='%s', preco=%.2f}", codigo, nome, preco);
    }
}

// Uso:
Produto p1 = new Produto("ABC123", "Notebook", 3500.00);
Produto p2 = new Produto("ABC123", "Notebook Dell", 3800.00);  // mesmo código
Produto p3 = new Produto("XYZ999", "Mouse", 50.00);

System.out.println(p1.equals(p2));  // true (mesmo código)
System.out.println(p1.equals(p3));  // false (códigos diferentes)
System.out.println(p1 == p2);       // false (referências diferentes)
```

---

## Herança em Múltiplos Níveis

```java
// Cadeia de herança: Animal → Mamifero → Cachorro
public class Animal {
    private String nome;
    public Animal(String nome) { this.nome = nome; }
    public String getNome() { return nome; }
    public void respirar() { System.out.println(nome + " está respirando"); }
}

public class Mamifero extends Animal {
    public Mamifero(String nome) { super(nome); }
    public void amamentar() { System.out.println(getNome() + " amamenta filhotes"); }
}

public class Cachorro extends Mamifero {
    private String raca;
    public Cachorro(String nome, String raca) {
        super(nome);
        this.raca = raca;
    }
    public void latir() { System.out.println(getNome() + " está latindo! Au au!"); }

    @Override
    public String toString() {
        return "Cachorro{nome='" + getNome() + "', raca='" + raca + "'}";
    }
}

// Cachorro herda: respirar() de Animal, amamentar() de Mamifero, e tem latir() próprio
Cachorro rex = new Cachorro("Rex", "Labrador");
rex.respirar();   // herdado de Animal
rex.amamentar(); // herdado de Mamifero
rex.latir();     // próprio
```

---

## Quando NÃO Usar Herança

Herança expressa a relação "**É UM**". Use-a apenas quando essa relação for verdadeira:

```
✅ Desenvolvedor É UM Funcionario
✅ Cachorro É UM Mamifero
✅ Gerente É UM Funcionario

❌ Carro TEM UM Motor (use COMPOSIÇÃO, não herança)
❌ Pedido TEM UM Cliente (use COMPOSIÇÃO)
❌ Stack extends ArrayList (clássico erro — Stack NÃO é uma Lista)
```

### Composição vs Herança

```java
// ERRADO: herança onde deveria ser composição
public class Carro extends Motor {  // Carro NÃO é um Motor!
    private String modelo;
}

// CERTO: composição — Carro TEM UM Motor
public class Motor {
    private int cilindradas;
    private String combustivel;
    // ...
}

public class Carro {
    private String modelo;
    private Motor motor;  // composição: Carro contém um Motor

    public Carro(String modelo, Motor motor) {
        this.modelo = modelo;
        this.motor = motor;
    }

    public void ligar() {
        motor.iniciar();  // delega para o Motor
    }
}
```

---

## Exemplo Completo: Sistema de Funcionários

```java
public class Main {
    public static void main(String[] args) {
        Funcionario[] equipe = {
            new Desenvolvedor("Ana Lima", "111.111.111-11", 8000.00, "Java"),
            new Desenvolvedor("Bruno Costa", "222.222.222-22", 7500.00, "Python"),
            new Gerente("Carlos Souza", "333.333.333-33", 12000.00, 8),
            new Gerente("Diana Ferreira", "444.444.444-44", 15000.00, 12),
            new Estagiario("Eduardo Alves", "555.555.555-55", 1500.00, "Ciência da Computação")
        };

        System.out.println("=== Folha de Pagamento ===");
        double totalFolha = 0;
        for (Funcionario f : equipe) {
            double salario = f.calcularSalario();
            totalFolha += salario;
            System.out.printf("%-30s → R$%,.2f%n", f.getNome(), salario);
        }
        System.out.printf("%nTotal da folha: R$%,.2f%n", totalFolha);

        System.out.println("\n=== Detalhes ===");
        for (Funcionario f : equipe) {
            System.out.println(f);
        }
    }
}
```

**Saída esperada:**
```
=== Folha de Pagamento ===
Ana Lima                       → R$9.600,00
Bruno Costa                    → R$9.000,00
Carlos Souza                   → R$18.000,00
Diana Ferreira                 → R$22.500,00
Eduardo Alves                  → R$1.500,00

Total da folha: R$60.600,00

=== Detalhes ===
Ana Lima [Desenvolvedor] - Salário base: R$8.000,00 | Linguagem: Java
Bruno Costa [Desenvolvedor] - Salário base: R$7.500,00 | Linguagem: Python
Carlos Souza [Gerente] - Salário base: R$12.000,00 | Equipe: 8 pessoas
Diana Ferreira [Gerente] - Salário base: R$15.000,00 | Equipe: 12 pessoas
Eduardo Alves [Estagiario] - Salário base: R$1.500,00 | Curso: Ciência da Computação
```

---

## Resumo do Tópico

| Conceito | Definição |
|----------|-----------|
| `extends` | Declara herança de uma superclasse |
| `super(...)` | Chama construtor da superclasse |
| `super.metodo()` | Chama método da superclasse |
| `@Override` | Indica sobrescrita de método |
| `Object` | Superclasse implícita de todas as classes |
| `equals()` | Igualdade lógica (conteúdo) |
| `==` | Igualdade de referência (endereço) |

---

## Exercícios

### Básico
1. Crie a hierarquia `Veiculo → Carro` e `Veiculo → Moto`. Veiculo tem `marca`, `modelo`, `velocidadeMaxima`. Cada subclasse adiciona um atributo específico.
2. Adicione um método `descricao()` em Veiculo e sobrescreva-o em Carro e Moto
3. Crie 3 veículos (2 carros e 1 moto) e exiba todos chamando `descricao()`

### Intermediário
4. Crie a hierarquia `Conta → ContaCorrente` e `Conta → ContaPoupanca`. Conta tem saldo e titular. ContaCorrente tem limite de cheque especial. ContaPoupanca tem taxa de rendimento mensal.
5. Implemente `calcularSaldo()` diferente em cada subclasse
6. Sobrescreva `equals()` e `hashCode()` em Conta usando o número da conta

### Avançado
7. Identifique o problema na herança `Stack extends ArrayList` e explique por que composição seria melhor
8. Implemente `equals()` completo para `Funcionario` usando CPF como identificador único
9. Crie uma hierarquia de 3 níveis (`Forma → FormaFechada → Retangulo`) e calcule área e perímetro de cada forma
