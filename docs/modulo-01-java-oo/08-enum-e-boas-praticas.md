# 08 — Enums e Boas Práticas

## Revisão do Tópico Anterior
Você aprendeu Collections: List, Set, Map, Comparable e Comparator. Agora vamos estudar Enums e as boas práticas que tornam o código profissional.

---

## Enums — Conjuntos Finitos de Valores

Quando um campo tem apenas um conjunto fixo e conhecido de valores, use `enum` em vez de `String` ou `int`:

```java
// RUIM: String solto — qualquer valor é "válido"
String diaSemana = "SEGUNDA";
String diaSemana2 = "SEGUNDA-FEIRA";  // inconsistência
String diaSemana3 = "segunda";        // case diferente

// RUIM: constantes int — sem significado, difícil de ler
public static final int SEGUNDA = 1;
public static final int TERCA = 2;
// ...

// BOM: Enum — conjunto fechado, type-safe, legível
public enum DiaSemana {
    SEGUNDA, TERCA, QUARTA, QUINTA, SEXTA, SABADO, DOMINGO
}

DiaSemana dia = DiaSemana.SEGUNDA;
// DiaSemana dia2 = "SEGUNDA";  // ERRO DE COMPILAÇÃO — type-safe!
```

### Enum com Atributos e Métodos

```java
public enum StatusPedido {
    PENDENTE("Aguardando confirmação", false),
    CONFIRMADO("Pedido confirmado", false),
    EM_PREPARACAO("Em preparo", false),
    ENVIADO("Enviado para entrega", false),
    ENTREGUE("Entregue ao destinatário", true),
    CANCELADO("Pedido cancelado", true);

    private final String descricao;
    private final boolean finalizado;

    // Construtor do enum (sempre privado)
    StatusPedido(String descricao, boolean finalizado) {
        this.descricao = descricao;
        this.finalizado = finalizado;
    }

    public String getDescricao() { return descricao; }
    public boolean isFinalizado() { return finalizado; }

    // Método de lógica no enum
    public boolean podeCancelar() {
        return this == PENDENTE || this == CONFIRMADO;
    }

    @Override
    public String toString() {
        return descricao;
    }
}

// Uso:
StatusPedido status = StatusPedido.ENVIADO;
System.out.println(status);                  // Enviado para entrega
System.out.println(status.isFinalizado());   // false
System.out.println(status.podeCancelar());   // false

// Iterar sobre todos os valores
for (StatusPedido s : StatusPedido.values()) {
    System.out.println(s.name() + " → " + s.getDescricao());
}

// switch com enum
switch (status) {
    case PENDENTE, CONFIRMADO -> System.out.println("Pode cancelar");
    case ENVIADO, EM_PREPARACAO -> System.out.println("Em andamento");
    case ENTREGUE -> System.out.println("Concluído!");
    case CANCELADO -> System.out.println("Cancelado");
}
```

### Enum com Método Abstrato (cada valor com comportamento diferente)

```java
public enum Operacao {
    SOMA {
        @Override
        public double calcular(double a, double b) { return a + b; }
    },
    SUBTRACAO {
        @Override
        public double calcular(double a, double b) { return a - b; }
    },
    MULTIPLICACAO {
        @Override
        public double calcular(double a, double b) { return a * b; }
    },
    DIVISAO {
        @Override
        public double calcular(double a, double b) {
            if (b == 0) throw new ArithmeticException("Divisão por zero");
            return a / b;
        }
    };

    public abstract double calcular(double a, double b);
}

// Uso:
double resultado = Operacao.SOMA.calcular(10, 5);  // 15.0
System.out.println(Operacao.DIVISAO.calcular(10, 3));  // 3.333...
```

---

## Sobrecarga de Métodos

Sobrecarga (overloading) permite múltiplos métodos com o mesmo nome mas parâmetros diferentes:

```java
public class Calculadora {

    // 3 versões de somar — mesmo nome, parâmetros diferentes
    public int somar(int a, int b) {
        return a + b;
    }

    public double somar(double a, double b) {
        return a + b;
    }

    public int somar(int a, int b, int c) {
        return a + b + c;
    }

    // String.valueOf() é um exemplo clássico de sobrecarga:
    // String.valueOf(int), String.valueOf(double), String.valueOf(boolean)...
}

// O compilador escolhe o método correto pelo tipo dos argumentos
Calculadora calc = new Calculadora();
System.out.println(calc.somar(1, 2));        // int: 3
System.out.println(calc.somar(1.5, 2.5));    // double: 4.0
System.out.println(calc.somar(1, 2, 3));     // int,int,int: 6
```

---

## Composição vs Herança (Revisão Prática)

**Prefira composição sobre herança** quando a relação não é "É UM":

```java
// Herança: Gerente É UM Funcionario ✅
public class Gerente extends Funcionario { ... }

// Composição: Pedido TEM UM Cliente, TEM UM endereço ✅
public class Pedido {
    private Long id;
    private Cliente cliente;         // composição
    private Endereco enderecoEntrega; // composição
    private List<ItemPedido> itens;  // composição
    private StatusPedido status;

    public Pedido(Cliente cliente, Endereco enderecoEntrega) {
        this.cliente = cliente;
        this.enderecoEntrega = enderecoEntrega;
        this.itens = new ArrayList<>();
        this.status = StatusPedido.PENDENTE;
    }

    public void adicionarItem(Produto produto, int quantidade) {
        itens.add(new ItemPedido(produto, quantidade));
    }

    public double calcularTotal() {
        return itens.stream()
            .mapToDouble(ItemPedido::calcularSubtotal)
            .sum();
    }
}
```

---

## `static` e `final`

### `static` — pertence à classe, não ao objeto

```java
public class Contador {
    private static int totalInstancias = 0;  // compartilhado por todos os objetos
    private int id;

    public Contador() {
        totalInstancias++;      // incrementa toda vez que criar um Contador
        this.id = totalInstancias;
    }

    public int getId() { return id; }
    public static int getTotalInstancias() { return totalInstancias; }
}

Contador c1 = new Contador();  // totalInstancias = 1
Contador c2 = new Contador();  // totalInstancias = 2
Contador c3 = new Contador();  // totalInstancias = 3

System.out.println(Contador.getTotalInstancias());  // 3 (chamado na classe)
System.out.println(c1.getId());  // 1
System.out.println(c2.getId());  // 2
```

### `final` — imutável / não pode ser sobrescrito

```java
// Atributo final: não pode ser alterado após inicialização
public class Configuracao {
    private final String url;           // deve ser inicializado no construtor
    private final int porta;
    public static final String VERSAO = "1.0.0";  // constante

    public Configuracao(String url, int porta) {
        this.url = url;
        this.porta = porta;
    }

    // Sem setters para url e porta — imutável
    public String getUrl() { return url; }
    public int getPorta() { return porta; }
}

// Método final: não pode ser sobrescrito
public class Base {
    public final void metodoCritico() {
        // nenhuma subclasse pode sobrescrever este método
    }
}

// Classe final: não pode ter subclasses (ex: String, Integer)
public final class Singleton {
    // ...
}
```

---

## Princípios SOLID — Introdução

SOLID é um acrônimo de 5 princípios de design orientado a objetos:

### S — Single Responsibility Principle (SRP)
Uma classe deve ter **apenas uma razão para mudar**:

```java
// VIOLAÇÃO: classe faz coisas demais
public class ClienteService {
    public void salvar(Cliente c) { /* SQL */ }
    public void validar(Cliente c) { /* regex, regras */ }
    public void enviarEmail(Cliente c) { /* SMTP */ }
    public void gerarRelatorio(Cliente c) { /* PDF */ }
    // 4 razões para mudar!
}

// CORRETO: cada classe tem uma responsabilidade
public class ClienteRepository  { public void salvar(Cliente c) { ... } }
public class ClienteValidator   { public void validar(Cliente c) { ... } }
public class EmailService       { public void enviar(String dest, String msg) { ... } }
public class RelatorioService   { public void gerar(List<Cliente> clientes) { ... } }
```

### O — Open/Closed Principle (OCP)
Aberto para **extensão**, fechado para **modificação**:

```java
// VIOLAÇÃO: adicionar novo tipo de desconto requer modificar esta classe
public double calcularDesconto(String tipo, double valor) {
    if (tipo.equals("VIP")) return valor * 0.2;
    if (tipo.equals("NORMAL")) return valor * 0.1;
    // adicionar novo tipo? Modifica aqui — risco!
    return 0;
}

// CORRETO: estratégia via interface
public interface CalculadoraDesconto {
    double calcular(double valor);
}

public class DescontoVip implements CalculadoraDesconto {
    public double calcular(double valor) { return valor * 0.2; }
}

public class DescontoNormal implements CalculadoraDesconto {
    public double calcular(double valor) { return valor * 0.1; }
}
// Adicionar novo tipo? Nova classe — sem modificar as existentes
```

### L — Liskov Substitution Principle (LSP)
Subclasses devem poder **substituir** a superclasse sem quebrar o comportamento:

```java
// VIOLAÇÃO: Quadrado extends Retangulo quebra o contrato
// (alterar largura de um Quadrado afeta também a altura)

// CORRETO: Quadrado e Retangulo devem ter hierarquia separada ou usar interface Forma
```

### I — Interface Segregation Principle (ISP)
Clientes não devem ser forçados a depender de interfaces que não usam:

```java
// VIOLAÇÃO: interface gorda
interface Animal {
    void comer();
    void nadar();   // pássaros não nadam!
    void voar();    // peixes não voam!
    void latir();   // só cachorros latem!
}

// CORRETO: interfaces segregadas
interface Animal   { void comer(); }
interface Nadador  { void nadar(); }
interface Voador   { void voar(); }

class Pato extends Animal implements Nadador, Voador { ... }
class Cachorro extends Animal { void latir() { ... } }
```

### D — Dependency Inversion Principle (DIP)
Dependa de **abstrações**, não de implementações concretas:

```java
// VIOLAÇÃO: depende da classe concreta
public class PedidoService {
    private MySQLPedidoRepository repo = new MySQLPedidoRepository();  // acoplado!
}

// CORRETO: depende de interface (abstração)
public class PedidoService {
    private final PedidoRepository repo;  // interface

    public PedidoService(PedidoRepository repo) {  // injeção de dependência
        this.repo = repo;
    }
    // Funciona com MySQL, Oracle, em memória — sem mudar o Service
}
```

---

## Code Smells Comuns

**Code smells** são sinais de que o código pode ser melhorado:

| Code Smell | Problema | Solução |
|------------|---------|---------|
| Método gigante (> 30 linhas) | Difícil de entender e testar | Extrair métodos menores |
| Classe Deus (faz tudo) | Viola SRP | Dividir em classes menores |
| Código duplicado | Manutenção duplicada | Extrair para método ou classe |
| Nomes sem significado (`x`, `temp`, `data2`) | Código ilegível | Nomes descritivos |
| Números mágicos (`if (status == 3)`) | Sem significado | Usar constante ou enum |
| Comentário explicando código ruim | O código deveria se explicar | Melhorar o código |
| Lista de parâmetros longa (> 4) | Difícil de usar | Criar objeto de parâmetro |
| `null` como valor de retorno | Causa NullPointerException | Usar `Optional<T>` |

---

## Optional — Evitando NullPointerException

```java
import java.util.Optional;

// Método que pode não encontrar resultado
public Optional<Cliente> buscarPorCpf(String cpf) {
    // Se não encontrar, retorna Optional.empty() em vez de null
    return clientes.stream()
        .filter(c -> c.getCpf().equals(cpf))
        .findFirst();  // já retorna Optional<Cliente>
}

// Uso
Optional<Cliente> resultado = buscarPorCpf("111.111.111-11");

// Verificar e usar com segurança
if (resultado.isPresent()) {
    System.out.println(resultado.get().getNome());
}

// Forma idiomática (Java 8+)
resultado.ifPresent(c -> System.out.println(c.getNome()));

// Valor padrão se não encontrar
String nome = resultado.map(Cliente::getNome).orElse("Não encontrado");

// Lançar exceção se não encontrar
Cliente cliente = resultado.orElseThrow(() ->
    new RuntimeException("Cliente não encontrado com CPF: " + cpf));
```

---

## Resumo do Tópico

| Conceito | Definição |
|----------|-----------|
| `enum` | Conjunto finito e fixo de valores com type-safety |
| Sobrecarga | Múltiplos métodos com mesmo nome e parâmetros diferentes |
| `static` | Pertence à classe, não ao objeto |
| `final` | Imutável (atributo), não sobrescrevível (método), sem herança (classe) |
| SOLID | 5 princípios de design orientado a objetos |
| Code Smell | Sinal de que o código pode ser melhorado |
| `Optional<T>` | Alternativa segura ao `null` |

---

## Exercícios

### Básico
1. Crie um enum `Turno` com valores MANHA, TARDE, NOITE, cada um com um horário de início
2. Adicione ao enum `DiaSemana` um método `ehFimDeSemana()` que retorna true para SABADO e DOMINGO
3. Crie uma constante `static final double PI = 3.14159` numa classe `Matematica`

### Intermediário
4. Refatore o método `calcularDesconto(String tipo, double valor)` para usar enum `TipoDesconto`
5. Identifique e corrija os code smells no seguinte código:
   ```java
   public void p(int x, int y, int z, int w) {
       if (x == 1) { /* 50 linhas */ }
       else if (x == 2) { /* 50 linhas */ }
   }
   ```
6. Use `Optional<Produto>` para reimplementar um método de busca que antes retornava `null`

### Avançado
7. Implemente os 5 princípios SOLID num mini-sistema de notificações (email, SMS, push)
8. Crie um enum `HttpStatus` com código, mensagem e método `isSuccess()` para os principais códigos HTTP
9. Refatore uma classe que viola SRP separando em: validação, persistência e notificação
