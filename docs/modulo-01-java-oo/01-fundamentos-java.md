# 01 — Fundamentos da Linguagem Java

## O que é Java?

Java é uma linguagem de programação criada pela Sun Microsystems em 1995 (hoje mantida pela Oracle). Seu lema histórico é **"Write Once, Run Anywhere"** — escreva uma vez, rode em qualquer lugar.

### Por que Java é tão usado na indústria?
- **Mercado**: bancos, governo, grandes empresas usam Java extensivamente
- **Ecossistema**: Spring Boot, Spring Batch, Hibernate, Maven — ferramentas maduras
- **Comunidade**: enorme base de profissionais e recursos
- **Estabilidade**: Java 17 (LTS) e Java 21 (LTS) são versões estáveis e suportadas por anos

---

## JVM, JDK e JRE — Qual a diferença?

```
┌────────────────────────────────────────────┐
│                   JDK                      │
│  (Java Development Kit — para desenvolver) │
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │              JRE                     │  │
│  │  (Java Runtime Environment — rodar)  │  │
│  │                                      │  │
│  │  ┌────────────────────────────────┐  │  │
│  │  │           JVM                  │  │  │
│  │  │  (Java Virtual Machine)        │  │  │
│  │  └────────────────────────────────┘  │  │
│  └──────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

| Sigla | Nome | Para quê |
|-------|------|----------|
| JDK | Java Development Kit | Escrever e compilar código Java |
| JRE | Java Runtime Environment | Executar aplicações Java |
| JVM | Java Virtual Machine | Interpreta bytecode Java |

**Você precisa do JDK** para desenvolver. O JDK já inclui JRE e JVM.

### O Ciclo de Compilação e Execução

```
MeuPrograma.java  →  javac (compilador)  →  MeuPrograma.class (bytecode)
                                                      ↓
                                              JVM (qualquer SO)
                                                      ↓
                                              Execução do programa
```

O compilador `javac` transforma seu código `.java` em **bytecode** (`.class`). A JVM lê esse bytecode e executa na máquina. Por isso o programa roda em qualquer sistema operacional que tenha uma JVM instalada.

---

## Estrutura de um Programa Java

```java
// Pacote (organização do código — como pastas)
package br.com.javazero.fundamentos;

// Importações (usar código de outras classes)
import java.util.Scanner;

// Declaração da classe — nome igual ao arquivo
public class MeuPrimeiroPrograma {

    // Método main — ponto de entrada da aplicação
    public static void main(String[] args) {
        System.out.println("Olá, Mundo!");
    }
}
```

**Regras importantes:**
- O nome do arquivo `.java` deve ser **idêntico** ao nome da classe pública
- Toda execução começa pelo método `main`
- Java é case-sensitive: `Nome` ≠ `nome`

---

## Tipos Primitivos

Java tem 8 tipos primitivos (armazenam valores diretamente na memória):

| Tipo | Tamanho | Faixa | Uso Comum |
|------|---------|-------|-----------|
| `byte` | 8 bits | -128 a 127 | Economizar memória |
| `short` | 16 bits | -32.768 a 32.767 | Raramente usado |
| `int` | 32 bits | ~-2 bi a 2 bi | Números inteiros |
| `long` | 64 bits | Muito grande | IDs, timestamps |
| `float` | 32 bits | ~7 dígitos | Impreciso, evite |
| `double` | 64 bits | ~15 dígitos | Números decimais |
| `boolean` | 1 bit | true / false | Condições |
| `char` | 16 bits | Um caractere | Caractere único |

```java
public class TiposPrimitivos {
    public static void main(String[] args) {
        int idade = 25;
        long cpf = 12345678900L;      // L no final para long
        double salario = 4500.50;
        boolean ativo = true;
        char inicial = 'J';           // char usa aspas simples

        System.out.println("Idade: " + idade);
        System.out.println("CPF: " + cpf);
        System.out.println("Salário: " + salario);
        System.out.println("Ativo: " + ativo);
        System.out.println("Inicial: " + inicial);
    }
}
```

### String — Não é primitivo!
`String` é uma **classe** em Java (começa com letra maiúscula):

```java
String nome = "João Silva";
String vazio = "";            // String vazia
String nulo = null;           // referência nula (cuidado!)

// Métodos úteis de String
System.out.println(nome.length());          // 10 — comprimento
System.out.println(nome.toUpperCase());     // JOÃO SILVA
System.out.println(nome.toLowerCase());     // joão silva
System.out.println(nome.contains("João")); // true
System.out.println(nome.replace("João", "Maria")); // Maria Silva
System.out.println(nome.trim());            // remove espaços das bordas
System.out.println(nome.substring(0, 4));   // João (índice 0 a 3)
```

---

## Variáveis e Operadores

### Declaração de variáveis
```java
// tipo nomeDaVariavel = valor;
int quantidade = 10;
double preco = 29.99;
String produto = "Notebook";
boolean emEstoque = true;

// var (Java 10+) — tipo inferido pelo compilador
var desconto = 0.15;  // inferido como double
var nomeCliente = "Ana";  // inferido como String
```

### Operadores Aritméticos
```java
int a = 10, b = 3;

System.out.println(a + b);   // 13 — adição
System.out.println(a - b);   // 7  — subtração
System.out.println(a * b);   // 30 — multiplicação
System.out.println(a / b);   // 3  — divisão inteira! (não 3.33)
System.out.println(a % b);   // 1  — resto da divisão (módulo)

// Para divisão decimal, use double:
System.out.println((double) a / b);  // 3.3333...
```

### Operadores Relacionais (retornam boolean)
```java
int x = 5, y = 10;
System.out.println(x == y);  // false — igual
System.out.println(x != y);  // true  — diferente
System.out.println(x < y);   // true  — menor que
System.out.println(x > y);   // false — maior que
System.out.println(x <= y);  // true  — menor ou igual
System.out.println(x >= y);  // false — maior ou igual
```

### Operadores Lógicos
```java
boolean a = true, b = false;
System.out.println(a && b);   // false — E (ambos devem ser true)
System.out.println(a || b);   // true  — OU (pelo menos um true)
System.out.println(!a);       // false — NÃO (inverte)
```

### Operadores de Atribuição
```java
int n = 10;
n += 5;   // n = n + 5 = 15
n -= 3;   // n = n - 3 = 12
n *= 2;   // n = n * 2 = 24
n /= 4;   // n = n / 4 = 6
n++;      // n = n + 1 = 7
n--;      // n = n - 1 = 6
```

---

## Estruturas de Controle

### if / else if / else
```java
int nota = 75;

if (nota >= 90) {
    System.out.println("Aprovado com distinção");
} else if (nota >= 70) {
    System.out.println("Aprovado");
} else if (nota >= 50) {
    System.out.println("Recuperação");
} else {
    System.out.println("Reprovado");
}

// Operador ternário (forma compacta para condições simples)
String resultado = (nota >= 70) ? "Aprovado" : "Reprovado";
System.out.println(resultado);
```

### switch (tradicional e moderno)
```java
String diaSemana = "SEGUNDA";

// switch tradicional
switch (diaSemana) {
    case "SEGUNDA":
    case "TERCA":
    case "QUARTA":
    case "QUINTA":
    case "SEXTA":
        System.out.println("Dia útil");
        break;
    case "SABADO":
    case "DOMINGO":
        System.out.println("Final de semana");
        break;
    default:
        System.out.println("Dia inválido");
}

// switch expression (Java 14+) — mais limpo
String tipo = switch (diaSemana) {
    case "SEGUNDA", "TERCA", "QUARTA", "QUINTA", "SEXTA" -> "Dia útil";
    case "SABADO", "DOMINGO" -> "Final de semana";
    default -> "Inválido";
};
System.out.println(tipo);
```

---

## Laços de Repetição

### for — quando você sabe quantas vezes
```java
// Sintaxe: for (inicialização; condição; incremento)
for (int i = 0; i < 5; i++) {
    System.out.println("Iteração: " + i);
}
// Saída: 0, 1, 2, 3, 4

// Contar de trás para frente
for (int i = 10; i > 0; i--) {
    System.out.print(i + " ");
}
// Saída: 10 9 8 7 6 5 4 3 2 1
```

### while — enquanto condição for verdadeira
```java
Scanner scanner = new Scanner(System.in);
int numero = -1;

while (numero < 0) {
    System.out.print("Digite um número positivo: ");
    numero = scanner.nextInt();
}
System.out.println("Número válido: " + numero);
```

### do-while — executa pelo menos uma vez
```java
int opcao;
do {
    System.out.println("Menu:");
    System.out.println("1 - Opção A");
    System.out.println("2 - Opção B");
    System.out.println("0 - Sair");
    System.out.print("Escolha: ");
    opcao = scanner.nextInt();
} while (opcao != 0);
```

### break e continue
```java
// break — sai do laço imediatamente
for (int i = 0; i < 10; i++) {
    if (i == 5) break;      // para no 5
    System.out.print(i + " "); // 0 1 2 3 4
}

// continue — pula para a próxima iteração
for (int i = 0; i < 10; i++) {
    if (i % 2 == 0) continue;  // pula pares
    System.out.print(i + " ");  // 1 3 5 7 9
}
```

---

## Arrays

Arrays armazenam múltiplos valores do mesmo tipo em sequência:

```java
// Declaração e inicialização
int[] numeros = new int[5];       // array de 5 inteiros (todos 0)
numeros[0] = 10;                  // índice começa em 0
numeros[1] = 20;
numeros[4] = 50;                  // último elemento (índice 4)

// Declaração com valores
String[] nomes = {"Ana", "Bruno", "Carlos", "Diana"};

// Percorrer com for
for (int i = 0; i < nomes.length; i++) {
    System.out.println(i + ": " + nomes[i]);
}

// Percorrer com for-each (mais simples quando não precisa do índice)
for (String nome : nomes) {
    System.out.println(nome);
}

// Tamanho do array
System.out.println("Total: " + nomes.length);  // 4

// Erro comum: ArrayIndexOutOfBoundsException
// nomes[4] = "Erro!";  // índice 4 não existe em array de 4 elementos!
```

---

## Métodos Estáticos

Métodos permitem reutilizar código. Métodos `static` pertencem à classe, não a objetos:

```java
public class CalculadoraSimples {

    // Método que retorna a soma de dois números
    public static int somar(int a, int b) {
        return a + b;
    }

    // Método que não retorna nada (void)
    public static void exibirMensagem(String mensagem) {
        System.out.println(">>> " + mensagem);
    }

    // Método com múltiplos parâmetros
    public static double calcularMedia(double nota1, double nota2, double nota3) {
        return (nota1 + nota2 + nota3) / 3.0;
    }

    public static void main(String[] args) {
        int resultado = somar(5, 3);
        System.out.println("Soma: " + resultado);  // 8

        exibirMensagem("Olá!");  // >>> Olá!

        double media = calcularMedia(8.5, 7.0, 9.0);
        System.out.println("Média: " + media);  // 8.166...
    }
}
```

### Convenções de Nomenclatura

```java
// Classes: PascalCase (primeira letra maiúscula)
public class ClienteBancario { }

// Métodos e variáveis: camelCase (primeira palavra minúscula)
public void calcularSaldo() { }
int valorTotal = 0;

// Constantes: UPPER_SNAKE_CASE
public static final double TAXA_JUROS = 0.015;

// Pacotes: tudo minúsculo
package br.com.javazero.fundamentos;
```

---

## Entrada de Dados com Scanner

```java
import java.util.Scanner;

public class EntradaDados {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Seu nome: ");
        String nome = scanner.nextLine();  // lê texto

        System.out.print("Sua idade: ");
        int idade = scanner.nextInt();  // lê inteiro

        System.out.print("Seu salário: ");
        double salario = scanner.nextDouble();  // lê decimal

        System.out.println("\n--- Dados cadastrados ---");
        System.out.println("Nome: " + nome);
        System.out.println("Idade: " + idade);
        System.out.printf("Salário: R$ %.2f%n", salario);  // formata 2 casas decimais

        scanner.close();  // boa prática: fechar o scanner
    }
}
```

---

## Resumo do Tópico

| Conceito | O que é | Exemplo |
|----------|---------|---------|
| JVM | Executa bytecode | `java MeuPrograma` |
| JDK | Kit de desenvolvimento | `javac MeuPrograma.java` |
| Tipo primitivo | Valor direto na memória | `int`, `double`, `boolean` |
| String | Classe para texto | `String nome = "Ana"` |
| Array | Coleção de mesmo tipo | `int[] nums = {1, 2, 3}` |
| Método estático | Função da classe | `Math.abs(-5)` |

---

## Exercícios

### Básico
1. Escreva um programa que leia o nome e idade do usuário e imprima uma saudação
2. Crie um array com os nomes dos meses e imprima cada um com seu número (1 - Janeiro, etc.)
3. Escreva um método `ehPar(int n)` que retorna `true` se n for par

### Intermediário
4. Crie uma calculadora que leia dois números e uma operação (+, -, *, /) e imprima o resultado
5. Escreva um programa que imprima a tabuada de um número lido pelo usuário
6. Crie um programa que leia 5 notas, calcule a média e diga se o aluno foi aprovado (≥7)

### Avançado
7. Implemente o método `inverterArray(int[] arr)` que retorna o array invertido
8. Crie um programa que leia números até o usuário digitar -1 e imprima o maior, menor e média
9. Escreva o jogo "adivinhe o número": gere número aleatório 1-100 com `Math.random()` e dê dicas "maior" ou "menor" até o usuário acertar
