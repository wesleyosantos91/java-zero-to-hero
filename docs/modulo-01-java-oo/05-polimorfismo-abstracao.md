# 05 — Polimorfismo e Abstração

## Revisão Rápida

Nos capítulos anteriores você aprendeu que **herança** permite que uma classe filha herde os atributos e métodos de uma classe pai, evitando repetição de código. Vimos também que **sobrescrita (override)** permite que a classe filha redefina o comportamento de um método herdado.

Com isso, formamos **hierarquias de tipos**: `Animal` → `Cachorro`, `Veiculo` → `Carro`, `Conta` → `ContaCorrente`. Toda instância de `Cachorro` também é um `Animal`. Esse relacionamento "é um" (is-a) é a base do que estudaremos agora.

---

## O que é Polimorfismo?

**Polimorfismo** vem do grego: *poly* (muitos) + *morphos* (formas). Em programação orientada a objetos, significa que **um mesmo nome ou referência pode se comportar de formas diferentes dependendo do contexto ou do tipo real do objeto**.

Pense assim: você tem um controle remoto universal (a referência). Você aperta o botão "ligar" (chama o método). Se o controle estiver apontado para uma TV Samsung, ela liga de um jeito. Se estiver apontando para uma LG, liga de outro. O botão é o mesmo — o comportamento é diferente.

Java suporta dois tipos principais de polimorfismo:

1. **Polimorfismo em tempo de compilação** — sobrecarga de métodos (overloading)
2. **Polimorfismo em tempo de execução** — sobrescrita de métodos (overriding)

---

## Polimorfismo em Tempo de Compilação — Sobrecarga (Overloading)

Sobrecarga permite que você tenha **múltiplos métodos com o mesmo nome** na mesma classe, desde que tenham **assinaturas diferentes** (número ou tipo de parâmetros).

O compilador decide qual versão chamar **em tempo de compilação**, olhando para os argumentos passados.

```java
public class Calculadora {

    // Soma dois inteiros
    public int somar(int a, int b) {
        return a + b;
    }

    // Soma três inteiros
    public int somar(int a, int b, int c) {
        return a + b + c;
    }

    // Soma dois doubles
    public double somar(double a, double b) {
        return a + b;
    }

    // Soma um inteiro e um double
    public double somar(int a, double b) {
        return a + b;
    }

    public static void main(String[] args) {
        Calculadora calc = new Calculadora();

        System.out.println(calc.somar(2, 3));         // chama int, int → 5
        System.out.println(calc.somar(1, 2, 3));      // chama int, int, int → 6
        System.out.println(calc.somar(1.5, 2.5));     // chama double, double → 4.0
        System.out.println(calc.somar(2, 3.0));       // chama int, double → 5.0
    }
}
```

**Regras de sobrecarga:**
- Mesmo nome, assinatura diferente (tipo e/ou quantidade de parâmetros)
- O tipo de retorno **não** distingue métodos sobrecarregados
- O modificador de acesso **não** distingue métodos sobrecarregados

```java
// ERRO: não compila — mesma assinatura, só o retorno difere
public int calcular(int x) { return x; }
public double calcular(int x) { return x; }  // ERRO DE COMPILAÇÃO
```

---

## Polimorfismo em Tempo de Execução — Sobrescrita (Overriding)

Sobrescrita ocorre quando uma **classe filha redefine um método da classe pai**. O método chamado é determinado pelo **tipo real do objeto** em tempo de execução, não pelo tipo da referência.

```java
public class Animal {
    public void fazerSom() {
        System.out.println("O animal faz algum som");
    }
}

public class Cachorro extends Animal {
    @Override
    public void fazerSom() {
        System.out.println("Au au!");
    }
}

public class Gato extends Animal {
    @Override
    public void fazerSom() {
        System.out.println("Miau!");
    }
}

public class Demo {
    public static void main(String[] args) {
        Animal a1 = new Cachorro();
        Animal a2 = new Gato();
        Animal a3 = new Animal();

        a1.fazerSom();  // Au au!     — tipo real é Cachorro
        a2.fazerSom();  // Miau!      — tipo real é Gato
        a3.fazerSom();  // O animal faz algum som — tipo real é Animal
    }
}
```

Observe: `a1` é declarado como `Animal`, mas o objeto criado é `Cachorro`. Quando chamamos `fazerSom()`, Java verifica o tipo **real** do objeto (não o tipo da referência) e executa o método correto. Isso é o **dispatch dinâmico de métodos**.

---

## Referência do Tipo Pai, Objeto do Tipo Filho

Uma referência do tipo pai pode apontar para qualquer objeto de uma subclasse:

```java
Animal animal = new Cachorro();  // válido — Cachorro É UM Animal
```

Isso é chamado de **upcasting implícito**. É automático e seguro porque qualquer `Cachorro` sempre será um `Animal`.

A vantagem é que podemos escrever código que trabalha com o tipo pai e funciona para qualquer subtipo:

```java
public class Veterinario {

    // Aceita qualquer Animal (Cachorro, Gato, Passaro, etc.)
    public void examinar(Animal animal) {
        System.out.println("Examinando...");
        animal.fazerSom();
    }
}

public class Demo {
    public static void main(String[] args) {
        Veterinario vet = new Veterinario();

        vet.examinar(new Cachorro());  // funciona
        vet.examinar(new Gato());      // funciona
        vet.examinar(new Animal());    // funciona
    }
}
```

---

## Upcasting

**Upcasting** é converter um tipo filho para o tipo pai. É sempre **seguro** e acontece **automaticamente** (implicitamente) em Java.

```java
Cachorro rex = new Cachorro();

// Upcasting implícito (automático)
Animal animal = rex;

// Upcasting explícito (também válido, mas desnecessário)
Animal animal2 = (Animal) rex;
```

Quando você faz upcasting, a referência do tipo pai só enxerga os métodos definidos na classe pai (ou sobrescritos). Ela não enxerga métodos exclusivos da classe filha.

```java
public class Cachorro extends Animal {
    @Override
    public void fazerSom() {
        System.out.println("Au au!");
    }

    // Método exclusivo do Cachorro
    public void buscarBola() {
        System.out.println("Buscando a bola!");
    }
}

Animal a = new Cachorro();
a.fazerSom();      // OK — método sobrescrito, executa a versão Cachorro
a.buscarBola();    // ERRO DE COMPILAÇÃO — Animal não conhece buscarBola()
```

---

## Downcasting

**Downcasting** é o inverso: converter uma referência do tipo pai de volta para o tipo filho. Precisa ser feito **explicitamente** e pode causar erros em tempo de execução se o objeto não for realmente do tipo especificado.

```java
Animal animal = new Cachorro();  // upcasting implícito

// Downcasting explícito
Cachorro cachorro = (Cachorro) animal;
cachorro.buscarBola();  // agora funciona!
```

Mas cuidado:

```java
Animal animal = new Gato();  // o objeto real é Gato

// Tentativa de downcasting incorreta
Cachorro cachorro = (Cachorro) animal;  // ERRO EM TEMPO DE EXECUÇÃO!
// ClassCastException: Gato cannot be cast to Cachorro
```

O **ClassCastException** ocorre em tempo de execução, não em compilação. O compilador aceita o código porque não consegue saber o tipo real do objeto. Por isso, **sempre use `instanceof` antes de fazer downcasting**.

---

## instanceof

O operador `instanceof` verifica se um objeto é instância de determinada classe (ou subclasse):

```java
Animal animal = new Cachorro();

if (animal instanceof Cachorro) {
    Cachorro cachorro = (Cachorro) animal;
    cachorro.buscarBola();
}

if (animal instanceof Gato) {
    // este bloco não será executado
    Gato gato = (Gato) animal;
    gato.arranhar();
}
```

`instanceof` retorna `true` também para tipos pai:

```java
Cachorro rex = new Cachorro();

System.out.println(rex instanceof Cachorro);  // true
System.out.println(rex instanceof Animal);    // true (Cachorro É UM Animal)
System.out.println(rex instanceof Object);    // true (tudo é Object)
```

---

## Pattern Matching com instanceof (Java 16+)

O Java 16 introduziu **pattern matching** para `instanceof`, eliminando o cast manual:

```java
// Jeito antigo (Java < 16)
if (animal instanceof Cachorro) {
    Cachorro cachorro = (Cachorro) animal;  // cast manual redundante
    cachorro.buscarBola();
}

// Jeito moderno (Java 16+)
if (animal instanceof Cachorro cachorro) {
    cachorro.buscarBola();  // variável 'cachorro' já está disponível
}
```

A nova sintaxe `instanceof Tipo variavel` faz o teste E o cast em uma única expressão. A variável só está disponível dentro do bloco `if`.

```java
public void processar(Animal animal) {
    if (animal instanceof Cachorro c) {
        c.buscarBola();
    } else if (animal instanceof Gato g) {
        g.arranhar();
    } else {
        animal.fazerSom();
    }
}
```

---

## Classes Abstratas

### O que são?

Uma **classe abstrata** é uma classe que **não pode ser instanciada diretamente** — ela existe apenas para ser estendida por classes filhas. Ela representa um conceito abstrato, incompleto.

Pense em `Forma` (Shape): você não desenha uma "forma" genérica — você desenha um círculo, um quadrado, um triângulo. `Forma` é um conceito abstrato.

### Quando usar?

Use classe abstrata quando:
- Existe um conceito genérico que não faz sentido instanciar diretamente
- Você quer compartilhar código (métodos concretos) entre subclasses
- Você quer forçar subclasses a implementar certos métodos

### Sintaxe

```java
public abstract class Forma {

    // Atributo comum a todas as formas
    private String cor;

    // Construtor — classes abstratas podem ter construtores
    // (chamados pelos construtores das subclasses via super())
    public Forma(String cor) {
        this.cor = cor;
    }

    // Método abstrato — sem implementação, DEVE ser sobrescrito
    public abstract double calcularArea();

    // Método abstrato
    public abstract double calcularPerimetro();

    // Método concreto — tem implementação, pode ou não ser sobrescrito
    public String getCor() {
        return cor;
    }

    // Método concreto compartilhado por todas as formas
    public void exibir() {
        System.out.printf("Forma: %s | Cor: %s | Área: %.2f%n",
                getClass().getSimpleName(), cor, calcularArea());
    }
}
```

```java
public class Circulo extends Forma {

    private double raio;

    public Circulo(String cor, double raio) {
        super(cor);  // chama construtor da classe abstrata
        this.raio = raio;
    }

    @Override
    public double calcularArea() {
        return Math.PI * raio * raio;
    }

    @Override
    public double calcularPerimetro() {
        return 2 * Math.PI * raio;
    }
}
```

```java
public class Retangulo extends Forma {

    private double largura;
    private double altura;

    public Retangulo(String cor, double largura, double altura) {
        super(cor);
        this.largura = largura;
        this.altura = altura;
    }

    @Override
    public double calcularArea() {
        return largura * altura;
    }

    @Override
    public double calcularPerimetro() {
        return 2 * (largura + altura);
    }
}
```

```java
public class DemoFormas {
    public static void main(String[] args) {
        // Forma forma = new Forma("azul");  // ERRO — não pode instanciar classe abstrata

        Forma c = new Circulo("vermelho", 5.0);
        Forma r = new Retangulo("azul", 4.0, 6.0);

        c.exibir();  // Forma: Circulo | Cor: vermelho | Área: 78,54
        r.exibir();  // Forma: Retangulo | Cor: azul | Área: 24,00

        // Lista polimórfica
        List<Forma> formas = List.of(
            new Circulo("verde", 3.0),
            new Retangulo("amarelo", 2.0, 5.0),
            new Circulo("roxo", 7.0)
        );

        formas.forEach(Forma::exibir);
    }
}
```

**Pontos importantes sobre classes abstratas:**
- Declaradas com `abstract class`
- Podem ter atributos (qualquer visibilidade)
- Podem ter construtores (chamados via `super()`)
- Podem ter métodos concretos (com implementação)
- Podem ter métodos abstratos (sem implementação, apenas assinatura)
- Uma classe filha **deve** implementar todos os métodos abstratos (ou ela mesma ser abstrata)
- Não pode ser instanciada com `new`

---

## Interfaces

### O que são?

Uma **interface** é um contrato. Ela define **o que** uma classe deve ser capaz de fazer, sem dizer **como**. É como uma lista de habilidades que uma classe se compromete a ter.

Pense em uma tomada elétrica (interface `Plugavel`): qualquer aparelho que "implementa" essa interface pode ser plugado na tomada. A tomada não sabe se é um liquidificador ou um notebook — ela só sabe que o aparelho tem os pinos certos.

### Sintaxe Básica

```java
public interface Pagavel {
    void pagar(double valor);  // implicitamente public abstract
    double getSaldo();
}
```

Uma classe "assina o contrato" com `implements`:

```java
public class ContaCorrente implements Pagavel {

    private double saldo;

    public ContaCorrente(double saldoInicial) {
        this.saldo = saldoInicial;
    }

    @Override
    public void pagar(double valor) {
        if (valor > saldo) {
            throw new IllegalArgumentException("Saldo insuficiente");
        }
        saldo -= valor;
        System.out.printf("Pagamento de R$ %.2f realizado. Saldo: R$ %.2f%n", valor, saldo);
    }

    @Override
    public double getSaldo() {
        return saldo;
    }
}
```

### Métodos Default (Java 8+)

Antes do Java 8, interfaces só podiam ter métodos abstratos. O Java 8 introduziu **métodos default** — métodos com implementação padrão dentro da interface.

Isso permite adicionar novos métodos a uma interface sem quebrar as implementações existentes.

```java
public interface Pagavel {
    void pagar(double valor);
    double getSaldo();

    // Método default — tem implementação, não é obrigatório sobrescrever
    default boolean temSaldoSuficiente(double valor) {
        return getSaldo() >= valor;
    }

    // Outro método default
    default void exibirSaldo() {
        System.out.printf("Saldo atual: R$ %.2f%n", getSaldo());
    }
}
```

As classes que implementam `Pagavel` herdam `temSaldoSuficiente()` e `exibirSaldo()` automaticamente, mas podem sobrescrever se quiserem.

### Métodos Static em Interfaces

Interfaces também podem ter métodos estáticos (Java 8+):

```java
public interface Pagavel {
    void pagar(double valor);

    // Método estático — não pode ser sobrescrito, chamado pela interface
    static Pagavel criarContaZerada() {
        return new ContaCorrente(0.0);
    }

    static boolean isValorValido(double valor) {
        return valor > 0;
    }
}

// Chamada:
Pagavel conta = Pagavel.criarContaZerada();
boolean valido = Pagavel.isValorValido(100.0);
```

### Métodos Private em Interfaces (Java 9+)

O Java 9 adicionou suporte a métodos privados em interfaces, úteis para evitar duplicação de código entre métodos default:

```java
public interface Relatorio {

    void gerarRelatorio();

    default void gerarRelatorioPDF() {
        prepararDados();
        System.out.println("Gerando PDF...");
    }

    default void gerarRelatorioHTML() {
        prepararDados();
        System.out.println("Gerando HTML...");
    }

    // Método private — só acessível dentro da interface
    private void prepararDados() {
        System.out.println("Preparando dados para o relatório...");
    }
}
```

### Constantes em Interfaces

Atributos em interfaces são implicitamente `public static final`:

```java
public interface Matematica {
    double PI = 3.14159265358979;      // public static final double PI
    int MAX_ITERACOES = 1000;           // public static final int MAX_ITERACOES
}
```

### Implementação de Múltiplas Interfaces

Uma classe pode implementar **múltiplas interfaces** (algo impossível com herança de classes):

```java
public interface Nadavel {
    void nadar();
}

public interface Voavel {
    void voar();
}

public interface Corrivel {
    void correr();
}

// Pato implementa três interfaces
public class Pato implements Nadavel, Voavel, Corrivel {

    @Override
    public void nadar() {
        System.out.println("O pato está nadando");
    }

    @Override
    public void voar() {
        System.out.println("O pato está voando");
    }

    @Override
    public void correr() {
        System.out.println("O pato está correndo");
    }
}
```

---

## Exemplo Prático: Sistema de Pagamento

```java
public interface MeioPagamento {

    void processar(double valor);

    default String getDescricao() {
        return "Meio de pagamento";
    }

    static boolean isValorPositivo(double valor) {
        return valor > 0;
    }
}

public class CartaoCredito implements MeioPagamento {

    private String numero;
    private int parcelas;

    public CartaoCredito(String numero, int parcelas) {
        this.numero = numero;
        this.parcelas = parcelas;
    }

    @Override
    public void processar(double valor) {
        System.out.printf("Pagamento de R$ %.2f em %d parcela(s) no cartão %s%n",
                valor, parcelas, numero.substring(numero.length() - 4));
    }

    @Override
    public String getDescricao() {
        return "Cartão de Crédito";
    }
}

public class Boleto implements MeioPagamento {

    private String codigoBarras;

    public Boleto(String codigoBarras) {
        this.codigoBarras = codigoBarras;
    }

    @Override
    public void processar(double valor) {
        System.out.printf("Boleto gerado: R$ %.2f | Código: %s%n", valor, codigoBarras);
    }

    @Override
    public String getDescricao() {
        return "Boleto Bancário";
    }
}

public class Pix implements MeioPagamento {

    private String chavePix;

    public Pix(String chavePix) {
        this.chavePix = chavePix;
    }

    @Override
    public void processar(double valor) {
        System.out.printf("PIX de R$ %.2f enviado para %s%n", valor, chavePix);
    }

    @Override
    public String getDescricao() {
        return "PIX";
    }
}

public class Caixa {

    public void realizarPagamento(MeioPagamento meio, double valor) {
        if (!MeioPagamento.isValorPositivo(valor)) {
            throw new IllegalArgumentException("Valor deve ser positivo");
        }
        System.out.println("Processando via: " + meio.getDescricao());
        meio.processar(valor);
    }
}
```

---

## Classe Abstrata vs Interface — Tabela Comparativa

| Característica              | Classe Abstrata                         | Interface                                  |
|-----------------------------|------------------------------------------|--------------------------------------------|
| Instanciação                | Não pode ser instanciada                 | Não pode ser instanciada                   |
| Herança/Implementação       | `extends` (apenas uma)                  | `implements` (múltiplas)                   |
| Atributos                   | Qualquer tipo e visibilidade             | Apenas `public static final`               |
| Métodos abstratos           | Sim (opcionais)                          | Sim (implicitamente todos os métodos)      |
| Métodos concretos           | Sim                                      | Apenas `default` e `static` (Java 8+)     |
| Construtores                | Sim                                      | Não                                        |
| Estado (atributos de inst.) | Sim                                      | Não                                        |
| Herança múltipla            | Não                                      | Sim (implementar várias)                   |
| Modificadores de acesso     | Qualquer                                 | Métodos são `public` por padrão            |

### Quando usar cada um?

**Use classe abstrata quando:**
- Você quer compartilhar **estado** (atributos de instância) entre subclasses
- Existe uma relação "é um" forte e lógica entre pai e filhos
- As subclasses compartilham uma implementação parcial comum
- Você quer usar construtores para inicializar o estado base

**Use interface quando:**
- Você quer definir um **contrato** (capacidade) sem impor uma hierarquia
- Você precisa que uma classe "seja capaz de" múltiplas coisas
- Você está definindo uma API para outros desenvolvedores implementarem
- Você quer aproveitar polimorfismo sem relacionamento de herança

**Regra de ouro moderna:** Prefira interfaces. Use classes abstratas apenas quando precisar de estado compartilhado ou construtor.

---

## Erros Comuns

### 1. Tentar instanciar uma classe abstrata ou interface

```java
// ERRO
Forma forma = new Forma("azul");        // Forma é abstract
MeioPagamento mp = new MeioPagamento(); // MeioPagamento é interface
```

### 2. Esquecer de implementar todos os métodos abstratos

```java
public class Triangulo extends Forma {
    // Implementou calcularArea() mas esqueceu calcularPerimetro()
    // ERRO DE COMPILAÇÃO: Triangulo não é abstract e não implementa calcularPerimetro()
    @Override
    public double calcularArea() { return 0; }
}
```

### 3. Downcasting sem verificar com instanceof

```java
Animal animal = new Gato();
Cachorro c = (Cachorro) animal;  // ClassCastException em tempo de execução!
```

### 4. Confundir sobrecarga com sobrescrita

```java
public class Animal {
    public void fazerSom() { System.out.println("Som genérico"); }
}

public class Cachorro extends Animal {
    // Isso NÃO é sobrescrita — é sobrecarga (parâmetro diferente)
    // O método da classe pai NÃO foi substituído
    public void fazerSom(String tipo) { System.out.println("Au " + tipo); }
}
```

### 5. Tentar acessar métodos da subclasse através de referência do tipo pai

```java
Animal animal = new Cachorro();
animal.buscarBola();  // ERRO — Animal não tem buscarBola()
// Use instanceof + cast para acessar
```

### 6. Conflito em métodos default de múltiplas interfaces

```java
interface A {
    default void saudar() { System.out.println("Olá de A"); }
}

interface B {
    default void saudar() { System.out.println("Olá de B"); }
}

// ERRO DE COMPILAÇÃO: C herda dois defaults conflitantes
// A classe DEVE sobrescrever saudar()
class C implements A, B {
    @Override
    public void saudar() {
        A.super.saudar();  // escolhe explicitamente qual usar
    }
}
```

### 7. Esquecer @Override

Sem `@Override`, um erro de digitação no nome do método cria um **novo método** em vez de sobrescrever. Com `@Override`, o compilador valida.

```java
public class Cachorro extends Animal {
    // Sem @Override: isso cria um NOVO método, não sobrescreve fazerSom()
    public void fazersom() { System.out.println("Au au!"); }

    // Com @Override: o compilador detecta que 'fazersom' não existe no pai
    @Override
    public void fazersom() { System.out.println("Au au!"); }  // ERRO DE COMPILAÇÃO
}
```

---

## Exercícios

### Nível 1 — Iniciante

**Exercício 1.1:** Crie uma hierarquia de classes com:
- Classe abstrata `Veiculo` com atributos `marca`, `modelo` e método abstrato `acelerar()`
- Classe `Carro` que estende `Veiculo` e implementa `acelerar()` imprimindo "Carro acelerando com motor"
- Classe `Bicicleta` que estende `Veiculo` e implementa `acelerar()` imprimindo "Bicicleta acelerando com pedaladas"
- `main` que cria um `List<Veiculo>` com 2 carros e 2 bicicletas e chama `acelerar()` em todos

**Exercício 1.2:** Crie uma interface `Calculavel` com o método `calcularValorTotal()`. Implemente nas classes `Produto` (preço × quantidade) e `Servico` (hora × valorHora). Crie um método que recebe `Calculavel` e imprime o valor total.

---

### Nível 2 — Intermediário

**Exercício 2.1:** Crie um sistema de notificações:
- Interface `Notificavel` com métodos `enviar(String mensagem)` e `default String getTipo()` retornando "Desconhecido"
- Classes `NotificacaoEmail`, `NotificacaoSMS`, `NotificacaoPush` implementando a interface
- Cada uma deve ter seu próprio `getTipo()` e `enviar()` com mensagens distintas
- Classe `CentralDeNotificacoes` com um `List<Notificavel>` e método `notificarTodos(String mensagem)`

**Exercício 2.2:** Implemente o exemplo de `Forma` (completo) com as classes `Circulo`, `Retangulo` e `Triangulo`. Adicione um método `static Forma maior(List<Forma> formas)` na classe `DemoFormas` que retorna a forma com maior área.

---

### Nível 3 — Avançado

**Exercício 3.1:** Implemente um mini-sistema bancário:
- Interface `Conta` com métodos `depositar(double)`, `sacar(double)`, `getSaldo()` e método default `extrato()` que imprime saldo formatado
- Classe abstrata `ContaBase` implementando `Conta` com lógica comum de depositar e validação de valores negativos
- Classes `ContaCorrente` (cobra taxa de R$ 5,00 por saque) e `ContaPoupanca` (rende 0.5% ao mês via método `renderJuros()`)
- Use `instanceof` e pattern matching para imprimir relatório diferenciado por tipo de conta

---

### Gabarito — Exercício 1.1

```java
import java.util.List;

public abstract class Veiculo {
    private String marca;
    private String modelo;

    public Veiculo(String marca, String modelo) {
        this.marca = marca;
        this.modelo = modelo;
    }

    public abstract void acelerar();

    public String getMarca() { return marca; }
    public String getModelo() { return modelo; }

    @Override
    public String toString() {
        return marca + " " + modelo;
    }
}

public class Carro extends Veiculo {
    public Carro(String marca, String modelo) {
        super(marca, modelo);
    }

    @Override
    public void acelerar() {
        System.out.println(this + ": Carro acelerando com motor");
    }
}

public class Bicicleta extends Veiculo {
    public Bicicleta(String marca, String modelo) {
        super(marca, modelo);
    }

    @Override
    public void acelerar() {
        System.out.println(this + ": Bicicleta acelerando com pedaladas");
    }
}

public class Main {
    public static void main(String[] args) {
        List<Veiculo> veiculos = List.of(
            new Carro("Toyota", "Corolla"),
            new Carro("Honda", "Civic"),
            new Bicicleta("Caloi", "Elite"),
            new Bicicleta("Specialized", "Allez")
        );

        veiculos.forEach(Veiculo::acelerar);
    }
}
```

### Gabarito — Exercício 2.1

```java
import java.util.ArrayList;
import java.util.List;

public interface Notificavel {
    void enviar(String mensagem);

    default String getTipo() {
        return "Desconhecido";
    }
}

public class NotificacaoEmail implements Notificavel {
    private String destinatario;

    public NotificacaoEmail(String destinatario) {
        this.destinatario = destinatario;
    }

    @Override
    public void enviar(String mensagem) {
        System.out.printf("[EMAIL] Para: %s | Mensagem: %s%n", destinatario, mensagem);
    }

    @Override
    public String getTipo() { return "E-mail"; }
}

public class NotificacaoSMS implements Notificavel {
    private String telefone;

    public NotificacaoSMS(String telefone) {
        this.telefone = telefone;
    }

    @Override
    public void enviar(String mensagem) {
        System.out.printf("[SMS] Para: %s | Mensagem: %s%n", telefone, mensagem);
    }

    @Override
    public String getTipo() { return "SMS"; }
}

public class NotificacaoPush implements Notificavel {
    private String deviceId;

    public NotificacaoPush(String deviceId) {
        this.deviceId = deviceId;
    }

    @Override
    public void enviar(String mensagem) {
        System.out.printf("[PUSH] Device: %s | Mensagem: %s%n", deviceId, mensagem);
    }

    @Override
    public String getTipo() { return "Push Notification"; }
}

public class CentralDeNotificacoes {
    private List<Notificavel> canais = new ArrayList<>();

    public void adicionar(Notificavel canal) {
        canais.add(canal);
    }

    public void notificarTodos(String mensagem) {
        System.out.println("=== Enviando notificações ===");
        for (Notificavel canal : canais) {
            System.out.print("Via " + canal.getTipo() + ": ");
            canal.enviar(mensagem);
        }
    }
}

public class Main {
    public static void main(String[] args) {
        CentralDeNotificacoes central = new CentralDeNotificacoes();
        central.adicionar(new NotificacaoEmail("usuario@email.com"));
        central.adicionar(new NotificacaoSMS("(11) 99999-9999"));
        central.adicionar(new NotificacaoPush("device-abc-123"));

        central.notificarTodos("Seu pedido foi aprovado!");
    }
}
```
