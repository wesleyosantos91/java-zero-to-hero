# 03 — Encapsulamento

## Revisão do Tópico Anterior
Você criou classes com atributos públicos acessíveis diretamente: `pessoa.nome = "Ana"`. Isso tem um problema sério que vamos resolver agora.

---

## O Problema do Acesso Direto

```java
public class ContaBancaria {
    String titular;
    double saldo;

    public ContaBancaria(String titular) {
        this.titular = titular;
        this.saldo = 0;
    }
}

// Em qualquer lugar do código, QUALQUER UM pode fazer:
ContaBancaria conta = new ContaBancaria("Ana");
conta.saldo = -999999;  // PROBLEMA! Ninguém deveria poder fazer isso
conta.titular = null;   // PROBLEMA! Dado crítico alterado sem validação
```

**Encapsulamento** é o princípio de **esconder os detalhes internos** de uma classe e controlar o acesso aos seus dados através de métodos.

---

## Modificadores de Acesso

Java tem 4 modificadores de acesso:

| Modificador | Mesma Classe | Mesmo Pacote | Subclasse | Qualquer Lugar |
|------------|:---:|:---:|:---:|:---:|
| `private` | ✅ | ❌ | ❌ | ❌ |
| (padrão/sem modificador) | ✅ | ✅ | ❌ | ❌ |
| `protected` | ✅ | ✅ | ✅ | ❌ |
| `public` | ✅ | ✅ | ✅ | ✅ |

**Regra prática:**
- Atributos: sempre `private`
- Métodos de uso externo: `public`
- Métodos internos da classe: `private`
- Herança controlada: `protected`

---

## Getters e Setters

A convenção JavaBeans define como expor atributos privados de forma controlada:

```java
public class Pessoa {
    // Atributos PRIVADOS — ninguém acessa diretamente
    private String nome;
    private int idade;
    private String cpf;

    // GETTER — retorna o valor do atributo
    public String getNome() {
        return nome;
    }

    // SETTER — define o valor com validação
    public void setNome(String nome) {
        if (nome == null || nome.isBlank()) {
            throw new IllegalArgumentException("Nome não pode ser vazio");
        }
        this.nome = nome.trim();
    }

    // Getter de int
    public int getIdade() {
        return idade;
    }

    // Setter com validação de regra de negócio
    public void setIdade(int idade) {
        if (idade < 0 || idade > 150) {
            throw new IllegalArgumentException("Idade inválida: " + idade);
        }
        this.idade = idade;
    }

    // CPF: getter existe, mas sem setter (imutável após construção)
    public String getCpf() {
        return cpf;
    }

    // Construtor define o CPF (não pode mudar depois)
    public Pessoa(String nome, int idade, String cpf) {
        setNome(nome);       // reutiliza a validação do setter
        setIdade(idade);
        this.cpf = cpf;      // CPF não tem setter, só construtor
    }

    @Override
    public String toString() {
        return "Pessoa{nome='" + nome + "', idade=" + idade + ", cpf='" + cpf + "'}";
    }
}
```

### Convenção de Nomenclatura para Getters e Setters

```java
// Para atributo 'nomeDoAtributo':
// Getter: getNomeDoAtributo()
// Setter: setNomeDoAtributo(tipo valor)

// Para boolean, getter usa 'is' em vez de 'get':
private boolean ativo;
public boolean isAtivo() { return ativo; }
public void setAtivo(boolean ativo) { this.ativo = ativo; }

// Exemplos:
private String nomeCompleto;
public String getNomeCompleto() { return nomeCompleto; }
public void setNomeCompleto(String nomeCompleto) { ... }

private LocalDate dataNascimento;
public LocalDate getDataNascimento() { return dataNascimento; }
public void setDataNascimento(LocalDate dataNascimento) { ... }
```

---

## Validação nos Setters — Protegendo os Dados

```java
public class Produto {
    private String nome;
    private double preco;
    private int estoque;

    public Produto(String nome, double preco, int estoque) {
        setNome(nome);
        setPreco(preco);
        setEstoque(estoque);
    }

    public String getNome() { return nome; }
    public double getPreco() { return preco; }
    public int getEstoque() { return estoque; }

    public void setNome(String nome) {
        if (nome == null || nome.isBlank()) {
            throw new IllegalArgumentException("Nome do produto não pode ser vazio");
        }
        if (nome.length() > 100) {
            throw new IllegalArgumentException("Nome muito longo (máx 100 caracteres)");
        }
        this.nome = nome.trim();
    }

    public void setPreco(double preco) {
        if (preco < 0) {
            throw new IllegalArgumentException("Preço não pode ser negativo: " + preco);
        }
        this.preco = preco;
    }

    public void setEstoque(int estoque) {
        if (estoque < 0) {
            throw new IllegalArgumentException("Estoque não pode ser negativo: " + estoque);
        }
        this.estoque = estoque;
    }

    // Método de negócio que encapsula lógica
    public void vender(int quantidade) {
        if (quantidade <= 0) {
            throw new IllegalArgumentException("Quantidade deve ser positiva");
        }
        if (quantidade > estoque) {
            throw new IllegalStateException("Estoque insuficiente. Disponível: " + estoque);
        }
        this.estoque -= quantidade;
        System.out.printf("Venda de %d x '%s'. Estoque restante: %d%n",
                          quantidade, nome, estoque);
    }

    public void repor(int quantidade) {
        if (quantidade <= 0) {
            throw new IllegalArgumentException("Quantidade de reposição deve ser positiva");
        }
        this.estoque += quantidade;
        System.out.printf("Reposição de %d x '%s'. Novo estoque: %d%n",
                          quantidade, nome, estoque);
    }

    @Override
    public String toString() {
        return String.format("Produto{nome='%s', preco=R$%.2f, estoque=%d}",
                             nome, preco, estoque);
    }
}
```

---

## Encapsulando Lógica de Negócio

Além de proteger dados, encapsulamento também significa colocar a **lógica** dentro da classe certa:

```java
// ERRADO: lógica de negócio fora da classe
ContaBancaria conta = new ContaBancaria("Ana");
double saldo = conta.getSaldo();
if (saldo >= valor) {
    conta.setSaldo(saldo - valor);  // lógica de saque FORA da classe
}

// CERTO: lógica encapsulada na classe
public class ContaBancaria {
    private String titular;
    private double saldo;
    private List<String> extrato = new ArrayList<>();

    public ContaBancaria(String titular, double saldoInicial) {
        if (titular == null || titular.isBlank()) {
            throw new IllegalArgumentException("Titular obrigatório");
        }
        if (saldoInicial < 0) {
            throw new IllegalArgumentException("Saldo inicial não pode ser negativo");
        }
        this.titular = titular;
        this.saldo = saldoInicial;
        extrato.add("Abertura de conta: R$" + saldoInicial);
    }

    // Getter: apenas leitura
    public double getSaldo() { return saldo; }
    public String getTitular() { return titular; }

    // Não existe setSaldo() — saldo só muda via depositar/sacar

    public void depositar(double valor) {
        if (valor <= 0) throw new IllegalArgumentException("Valor deve ser positivo");
        saldo += valor;
        extrato.add(String.format("Depósito: +R$%.2f | Saldo: R$%.2f", valor, saldo));
    }

    public void sacar(double valor) {
        if (valor <= 0) throw new IllegalArgumentException("Valor deve ser positivo");
        if (valor > saldo) throw new IllegalStateException("Saldo insuficiente");
        saldo -= valor;
        extrato.add(String.format("Saque: -R$%.2f | Saldo: R$%.2f", valor, saldo));
    }

    public void imprimirExtrato() {
        System.out.println("=== Extrato: " + titular + " ===");
        extrato.forEach(System.out::println);
        System.out.printf("Saldo atual: R$%.2f%n", saldo);
    }
}
```

---

## Records — Imutabilidade Simples (Java 16+)

Para classes que são apenas **portadoras de dados** (sem lógica de negócio complexa), Java 16 introduziu `record`:

```java
// Record: o compilador gera automaticamente:
// - construtor com todos os parâmetros
// - getters (sem "get": nome() em vez de getNome())
// - equals(), hashCode() e toString()
// - Atributos são privados e FINAIS (imutáveis)

public record ClienteDTO(
    Long id,
    String nome,
    String email,
    String cpf
) { }

// Uso:
ClienteDTO dto = new ClienteDTO(1L, "Ana", "ana@email.com", "111.111.111-11");
System.out.println(dto.nome());   // Ana (getter sem "get")
System.out.println(dto.email());  // ana@email.com
System.out.println(dto);          // ClienteDTO[id=1, nome=Ana, email=ana@email.com, cpf=...]
```

### Records com validação
```java
public record Ponto(double x, double y) {
    // Compact constructor para validação
    public Ponto {
        if (Double.isNaN(x) || Double.isNaN(y)) {
            throw new IllegalArgumentException("Coordenadas não podem ser NaN");
        }
    }

    // Métodos adicionais são permitidos
    public double distanciaOrigem() {
        return Math.sqrt(x * x + y * y);
    }
}
```

### Quando usar Record vs Classe comum

| Situação | Use |
|---------|-----|
| DTO de entrada/saída de API | Record |
| Objeto de valor imutável | Record |
| Entidade com estado mutável | Classe |
| Objeto com lógica de negócio | Classe |
| Objeto que precisa de herança | Classe |

---

## Exemplo Completo: Conta Bancária Encapsulada

```java
package br.com.javazero.oo;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ContaBancaria {
    private final String numeroConta;   // final = imutável após construção
    private String titular;
    private double saldo;
    private boolean ativa;
    private final List<String> historico = new ArrayList<>();

    public ContaBancaria(String numeroConta, String titular, double saldoInicial) {
        if (numeroConta == null || numeroConta.isBlank())
            throw new IllegalArgumentException("Número da conta obrigatório");
        if (saldoInicial < 0)
            throw new IllegalArgumentException("Saldo inicial não pode ser negativo");

        this.numeroConta = numeroConta;
        this.ativa = true;
        setTitular(titular);
        this.saldo = saldoInicial;
        registrar("Conta aberta com saldo R$" + saldoInicial);
    }

    // Getters
    public String getNumeroConta() { return numeroConta; }
    public String getTitular() { return titular; }
    public double getSaldo() { return saldo; }
    public boolean isAtiva() { return ativa; }
    public List<String> getHistorico() {
        return Collections.unmodifiableList(historico);  // imutável externamente
    }

    // Setter com validação
    public void setTitular(String titular) {
        if (titular == null || titular.isBlank())
            throw new IllegalArgumentException("Titular obrigatório");
        this.titular = titular.trim();
    }

    // Sem setter para saldo, numeroConta e ativa — controlados por métodos de negócio
    public void depositar(double valor) {
        validarAtiva();
        if (valor <= 0) throw new IllegalArgumentException("Valor de depósito deve ser positivo");
        saldo += valor;
        registrar(String.format("Depósito: +%.2f | Saldo: %.2f", valor, saldo));
    }

    public void sacar(double valor) {
        validarAtiva();
        if (valor <= 0) throw new IllegalArgumentException("Valor de saque deve ser positivo");
        if (valor > saldo) throw new IllegalStateException("Saldo insuficiente");
        saldo -= valor;
        registrar(String.format("Saque: -%.2f | Saldo: %.2f", valor, saldo));
    }

    public void transferirPara(ContaBancaria destino, double valor) {
        this.sacar(valor);
        destino.depositar(valor);
        registrar("Transferência para " + destino.getNumeroConta());
    }

    public void encerrar() {
        validarAtiva();
        if (saldo > 0) throw new IllegalStateException("Saque o saldo antes de encerrar");
        ativa = false;
        registrar("Conta encerrada");
    }

    // Método privado — detalhe interno
    private void validarAtiva() {
        if (!ativa) throw new IllegalStateException("Conta encerrada");
    }

    private void registrar(String operacao) {
        historico.add("[" + java.time.LocalDateTime.now().toString().substring(0, 19) + "] " + operacao);
    }

    @Override
    public String toString() {
        return String.format("Conta{numero='%s', titular='%s', saldo=R$%.2f, ativa=%s}",
                numeroConta, titular, saldo, ativa);
    }
}
```

---

## Resumo do Tópico

| Conceito | Definição |
|----------|-----------|
| Encapsulamento | Esconder dados internos, expor apenas o necessário |
| `private` | Acesso somente dentro da própria classe |
| Getter | Método que retorna um atributo privado |
| Setter | Método que define um atributo com validação |
| `final` | Atributo imutável após inicialização |
| `record` | Classe imutável de dados gerada automaticamente |

---

## Exercícios

### Básico
1. Pegue a classe `Carro` do exercício anterior e torne todos os atributos `private`. Crie getters e setters
2. Adicione validação no setter de `ano`: deve estar entre 1886 e o ano atual
3. Crie um `record` `PessoaDTO(Long id, String nome, String email)` e use-o

### Intermediário
4. Na classe `ContaCorrente`, remova todos os setters de `saldo`. O saldo só deve mudar via `depositar()` e `sacar()`
5. Adicione ao setter de `email` na classe `Pessoa` uma validação que exige o `@` no email
6. Crie um método `encerrarConta()` que só funciona se o saldo for zero

### Avançado
7. Implemente a classe `Estoque` com produtos internos em `List<Produto>` privada. Exponha apenas `adicionar()`, `remover()`, `buscarPorNome()` e `quantidadeTotal()`
8. Crie um `record` imutável `Endereco(String rua, String numero, String cidade, String cep)` com validação de CEP (8 dígitos)
9. Explique por que retornar `Collections.unmodifiableList(lista)` em vez de `lista` diretamente protege o encapsulamento
