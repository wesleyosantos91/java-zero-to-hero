# 06 — Exceções

## Revisão Rápida

No capítulo anterior estudamos polimorfismo e abstração: um mesmo método pode ter comportamentos diferentes dependendo do tipo real do objeto. Aprendemos também que interfaces definem contratos e classes abstratas definem esqueletos de implementação.

Agora vamos tratar de um tema essencial para qualquer software profissional: **o que fazer quando algo dá errado**. Programas que só funcionam em condições ideais não existem no mundo real.

---

## O que são Exceções?

**Exceção** é um evento que interrompe o fluxo normal de execução de um programa quando algo inesperado acontece. O nome vem de "situação excepcional" — algo que não deveria acontecer na operação normal, mas pode.

Exemplos do mundo real:
- Você tenta abrir um arquivo que foi deletado
- Você divide um número por zero
- Você tenta acessar a posição 10 de um array com 5 elementos
- O servidor de banco de dados ficou indisponível
- O usuário digitou letras onde era esperado um número

O mecanismo de exceções permite que o programa **detecte**, **sinalize** e **trate** esses erros de forma estruturada e limpa.

---

## Sem Exceções: O que Acontecia Antes?

Antes de linguagens como Java popularizarem o sistema de exceções, o tratamento de erros era feito com **códigos de retorno**:

```c
// Estilo C — sem exceções
int lerArquivo(char* caminho) {
    FILE* f = fopen(caminho, "r");
    if (f == NULL) return -1;  // código de erro: -1 = arquivo não encontrado

    int resultado = processarArquivo(f);
    if (resultado == -2) return -2;  // código de erro: -2 = erro de leitura

    return 0;  // sucesso
}

// Quem chama precisa sempre verificar:
int status = lerArquivo("dados.txt");
if (status == -1) {
    printf("Arquivo não encontrado\n");
} else if (status == -2) {
    printf("Erro de leitura\n");
}
```

**Problemas dessa abordagem:**
1. **Fácil de ignorar:** o desenvolvedor pode simplesmente não verificar o código de retorno
2. **Conflito de significados:** -1 pode ser "erro" ou pode ser um valor válido
3. **Código misturado:** lógica de negócio e tratamento de erro ficam entrelaçados
4. **Propagação manual:** cada camada precisa checar e repassar o erro
5. **Sem contexto:** um número inteiro não carrega informações úteis sobre o erro

Com exceções em Java, erros são **objetos** que carregam contexto, têm hierarquia, e o compilador pode exigir que sejam tratados.

---

## Hierarquia de Exceções

Em Java, tudo que pode ser "jogado" (thrown) e "capturado" (caught) herda de `Throwable`:

```
java.lang.Object
└── java.lang.Throwable
    ├── java.lang.Error
    │   ├── StackOverflowError
    │   ├── OutOfMemoryError
    │   └── VirtualMachineError
    └── java.lang.Exception
        ├── IOException
        ├── SQLException
        ├── ClassNotFoundException
        └── RuntimeException
            ├── NullPointerException
            ├── ArrayIndexOutOfBoundsException
            ├── IllegalArgumentException
            ├── ClassCastException
            └── NumberFormatException
```

### Error

`Error` representa problemas **graves na JVM** que geralmente não podem ser recuperados. Você **nunca deve capturar** Errors (exceto em casos muito específicos como frameworks).

```java
// StackOverflowError — recursão infinita
public void recursaoInfinita() {
    recursaoInfinita();  // → StackOverflowError
}

// OutOfMemoryError — sem memória heap
int[] arrayGigante = new int[Integer.MAX_VALUE];  // → OutOfMemoryError
```

### Exception

`Exception` e suas subclasses representam condições que **podem ser tratadas** pelo programa.

---

## Checked vs Unchecked

Este é um dos conceitos mais importantes de exceções em Java.

### Checked Exceptions (Verificadas)

São exceções que o **compilador obriga você a tratar**. Representam situações previsíveis e recuperáveis, externas ao controle do programa.

- Herdam de `Exception` (mas não de `RuntimeException`)
- O compilador exige `try-catch` ou `throws` na assinatura do método
- Exemplos: `IOException`, `SQLException`, `FileNotFoundException`, `ClassNotFoundException`

```java
// IOException é checked — o compilador obriga tratamento
import java.io.*;

public void lerArquivo(String caminho) throws IOException {  // ou try-catch
    FileReader fr = new FileReader(caminho);  // lança FileNotFoundException (checked)
    BufferedReader br = new BufferedReader(fr);
    String linha;
    while ((linha = br.readLine()) != null) {  // lança IOException (checked)
        System.out.println(linha);
    }
    br.close();
}
```

### Unchecked Exceptions (Não Verificadas)

São exceções que o compilador **não** obriga a tratar. Geralmente representam **erros de programação** — bugs que deveriam ser corrigidos no código, não tratados em runtime.

- Herdam de `RuntimeException`
- O compilador não exige tratamento
- Exemplos: `NullPointerException`, `ArrayIndexOutOfBoundsException`, `IllegalArgumentException`, `NumberFormatException`

```java
String s = null;
s.length();  // NullPointerException — unchecked, não exige try-catch

int[] arr = new int[3];
arr[10] = 5;  // ArrayIndexOutOfBoundsException — unchecked

int x = Integer.parseInt("abc");  // NumberFormatException — unchecked
```

### Quando usar cada tipo?

| Situação                                                  | Use         |
|-----------------------------------------------------------|-------------|
| Erro de programação (bug) que deve ser corrigido          | Unchecked   |
| Argumento inválido passado pelo chamador                  | Unchecked   |
| Recurso externo indisponível (arquivo, rede, BD)          | Checked     |
| O chamador tem condições reais de se recuperar do erro    | Checked     |
| Validação de regra de negócio (ex: saldo insuficiente)    | Unchecked (na maioria dos projetos modernos) |

---

## try-catch

O bloco `try-catch` é a estrutura fundamental para tratar exceções:

```java
try {
    // Código que pode lançar exceção
    int resultado = 10 / 0;
} catch (ArithmeticException e) {
    // Código executado SE ArithmeticException for lançada
    System.out.println("Erro: " + e.getMessage());
}

System.out.println("Programa continua após o try-catch");
```

**Ordem de execução:**
1. O bloco `try` começa a executar
2. Se uma exceção ocorrer → execução salta para o `catch` correspondente
3. Se não ocorrer exceção → o `catch` é ignorado
4. A execução continua após o bloco `try-catch`

```java
public static void dividir(int a, int b) {
    System.out.println("Antes do try");
    try {
        System.out.println("Dentro do try");
        int resultado = a / b;
        System.out.println("Resultado: " + resultado);  // não executa se b == 0
        System.out.println("Fim do try");               // não executa se b == 0
    } catch (ArithmeticException e) {
        System.out.println("Catch executou: " + e.getMessage());
    }
    System.out.println("Após o try-catch");
}

// dividir(10, 2):
// Antes do try
// Dentro do try
// Resultado: 5
// Fim do try
// Após o try-catch

// dividir(10, 0):
// Antes do try
// Dentro do try
// Catch executou: / by zero
// Após o try-catch
```

---

## Múltiplos Catch

Um bloco `try` pode ter vários `catch` para diferentes tipos de exceção. **A ordem importa:** coloque exceções mais específicas antes das mais genéricas.

```java
public void processarEntrada(String entrada) {
    try {
        int numero = Integer.parseInt(entrada);   // pode lançar NumberFormatException
        int resultado = 100 / numero;              // pode lançar ArithmeticException
        int[] arr = new int[resultado];
        arr[resultado] = 1;                        // pode lançar ArrayIndexOutOfBoundsException
    } catch (NumberFormatException e) {
        System.out.println("Entrada inválida: '" + entrada + "' não é um número");
    } catch (ArithmeticException e) {
        System.out.println("Erro de divisão: " + e.getMessage());
    } catch (ArrayIndexOutOfBoundsException e) {
        System.out.println("Índice fora dos limites: " + e.getMessage());
    } catch (Exception e) {
        // Captura genérica — pega qualquer exceção não capturada acima
        System.out.println("Erro inesperado: " + e.getMessage());
    }
}
```

**ERRO clássico — ordem errada:**

```java
// ERRO DE COMPILAÇÃO: catch genérico antes do específico
try {
    // ...
} catch (Exception e) {          // genérico demais — captura tudo
    System.out.println("Erro");
} catch (NumberFormatException e) { // NUNCA vai ser alcançado!
    System.out.println("Número inválido"); // ERRO DE COMPILAÇÃO
}
```

### Multi-catch (Java 7+)

Para tratar múltiplos tipos da mesma forma, use o operador `|`:

```java
try {
    // ...
} catch (NumberFormatException | ArithmeticException e) {
    System.out.println("Erro de número ou divisão: " + e.getMessage());
} catch (IOException e) {
    System.out.println("Erro de I/O: " + e.getMessage());
}
```

---

## finally

O bloco `finally` é **sempre executado**, independentemente de ocorrer ou não uma exceção. É usado principalmente para liberar recursos.

```java
Connection conexao = null;
try {
    conexao = abrirConexao();
    // operações com banco
    conexao.executarQuery("SELECT ...");
} catch (SQLException e) {
    System.out.println("Erro no banco: " + e.getMessage());
} finally {
    // SEMPRE executa — garante que a conexão seja fechada
    if (conexao != null) {
        try {
            conexao.fechar();
            System.out.println("Conexão fechada");
        } catch (SQLException e) {
            System.out.println("Erro ao fechar conexão");
        }
    }
}
```

**O finally executa até em casos de `return` ou exceção não capturada:**

```java
public int metodo() {
    try {
        return 1;    // vai retornar 1...
    } finally {
        System.out.println("finally sempre executa!");  // ...mas isso executa antes
    }
}
// Saída: "finally sempre executa!"
// Retorno: 1
```

---

## try-with-resources (Java 7+)

O `try-with-resources` é uma forma mais elegante e segura de trabalhar com recursos que precisam ser fechados. O recurso é declarado no parêntese do `try` e fechado **automaticamente** ao final do bloco.

Para funcionar, o recurso deve implementar a interface `AutoCloseable` (que tem o método `close()`).

```java
// Jeito antigo — verbose e propenso a erros
BufferedReader br = null;
try {
    br = new BufferedReader(new FileReader("arquivo.txt"));
    String linha = br.readLine();
    System.out.println(linha);
} catch (IOException e) {
    e.printStackTrace();
} finally {
    if (br != null) {
        try { br.close(); } catch (IOException e) { e.printStackTrace(); }
    }
}

// Jeito moderno com try-with-resources
try (BufferedReader br = new BufferedReader(new FileReader("arquivo.txt"))) {
    String linha = br.readLine();
    System.out.println(linha);
} catch (IOException e) {
    e.printStackTrace();
}
// br.close() é chamado automaticamente!
```

Você pode declarar múltiplos recursos:

```java
try (
    FileInputStream fis = new FileInputStream("entrada.txt");
    FileOutputStream fos = new FileOutputStream("saida.txt")
) {
    // Ambos serão fechados automaticamente
    int dado;
    while ((dado = fis.read()) != -1) {
        fos.write(dado);
    }
} catch (IOException e) {
    System.out.println("Erro de I/O: " + e.getMessage());
}
```

**Criando sua própria classe com AutoCloseable:**

```java
public class ConexaoBancoDados implements AutoCloseable {

    private String url;

    public ConexaoBancoDados(String url) {
        this.url = url;
        System.out.println("Conexão aberta: " + url);
    }

    public void executarQuery(String sql) {
        System.out.println("Executando: " + sql);
    }

    @Override
    public void close() {
        System.out.println("Conexão fechada: " + url);
    }
}

// Uso:
try (ConexaoBancoDados conn = new ConexaoBancoDados("jdbc:mysql://localhost/db")) {
    conn.executarQuery("SELECT * FROM usuarios");
} // close() chamado automaticamente aqui
```

---

## throw — Lançar uma Exceção Manualmente

Use `throw` para lançar uma exceção explicitamente:

```java
public class ContaBancaria {

    private double saldo;

    public ContaBancaria(double saldoInicial) {
        if (saldoInicial < 0) {
            throw new IllegalArgumentException("Saldo inicial não pode ser negativo: " + saldoInicial);
        }
        this.saldo = saldoInicial;
    }

    public void sacar(double valor) {
        if (valor <= 0) {
            throw new IllegalArgumentException("Valor de saque deve ser positivo: " + valor);
        }
        if (valor > saldo) {
            throw new IllegalStateException(
                String.format("Saldo insuficiente. Saldo: R$ %.2f | Tentativa de saque: R$ %.2f", saldo, valor)
            );
        }
        saldo -= valor;
    }

    public double getSaldo() {
        return saldo;
    }
}
```

---

## throws — Declarar Exceções Checked

Quando um método pode lançar uma **checked exception** mas não a trata internamente, ele deve declarar com `throws`:

```java
import java.io.*;

public class LeitorArquivo {

    // Declara que pode lançar IOException — quem chamar este método deve tratar
    public String lerPrimeiraLinha(String caminho) throws IOException {
        try (BufferedReader br = new BufferedReader(new FileReader(caminho))) {
            return br.readLine();
        }
        // IOException não foi capturada aqui — será propagada para quem chamar
    }
}

// Quem chama deve tratar:
public class Main {
    public static void main(String[] args) {
        LeitorArquivo leitor = new LeitorArquivo();
        try {
            String linha = leitor.lerPrimeiraLinha("dados.txt");
            System.out.println(linha);
        } catch (IOException e) {
            System.out.println("Erro ao ler arquivo: " + e.getMessage());
        }
    }
}
```

Você pode declarar múltiplas exceções:

```java
public void operacaoCompleta() throws IOException, SQLException {
    // pode lançar ambas
}
```

---

## Criação de Exceções Customizadas

Quando as exceções padrão do Java não expressam bem o problema do seu domínio, crie as suas próprias.

### Quando criar?

- Quando você quer transmitir **contexto de negócio** (ex: `SaldoInsuficienteException`)
- Quando você quer diferenciar cenários de erro específicos da sua aplicação
- Quando quer adicionar dados extras ao erro (ex: código de erro, ID do recurso)

### Estendendo RuntimeException (unchecked)

```java
public class SaldoInsuficienteException extends RuntimeException {

    private final double saldoAtual;
    private final double valorSolicitado;

    // Construtor com mensagem
    public SaldoInsuficienteException(double saldoAtual, double valorSolicitado) {
        super(String.format(
            "Saldo insuficiente. Saldo atual: R$ %.2f | Valor solicitado: R$ %.2f",
            saldoAtual, valorSolicitado
        ));
        this.saldoAtual = saldoAtual;
        this.valorSolicitado = valorSolicitado;
    }

    // Construtor com mensagem e cause (exceção original)
    public SaldoInsuficienteException(double saldoAtual, double valorSolicitado, Throwable cause) {
        super(String.format(
            "Saldo insuficiente. Saldo atual: R$ %.2f | Valor solicitado: R$ %.2f",
            saldoAtual, valorSolicitado
        ), cause);
        this.saldoAtual = saldoAtual;
        this.valorSolicitado = valorSolicitado;
    }

    public double getSaldoAtual() { return saldoAtual; }
    public double getValorSolicitado() { return valorSolicitado; }
}
```

### Estendendo Exception (checked)

```java
public class ConexaoBancoException extends Exception {

    private final String servidor;

    public ConexaoBancoException(String servidor, String mensagem) {
        super(mensagem);
        this.servidor = servidor;
    }

    public ConexaoBancoException(String servidor, String mensagem, Throwable cause) {
        super(mensagem, cause);
        this.servidor = servidor;
    }

    public String getServidor() { return servidor; }
}
```

### Usando exceções customizadas

```java
public class ContaBancaria {

    private double saldo;
    private String titular;

    public ContaBancaria(String titular, double saldo) {
        this.titular = titular;
        this.saldo = saldo;
    }

    public void sacar(double valor) {
        if (valor <= 0) {
            throw new IllegalArgumentException("Valor de saque inválido: " + valor);
        }
        if (valor > saldo) {
            throw new SaldoInsuficienteException(saldo, valor);
        }
        saldo -= valor;
        System.out.printf("Saque de R$ %.2f realizado. Novo saldo: R$ %.2f%n", valor, saldo);
    }
}

public class Main {
    public static void main(String[] args) {
        ContaBancaria conta = new ContaBancaria("João", 100.0);

        try {
            conta.sacar(150.0);
        } catch (SaldoInsuficienteException e) {
            System.out.println("Erro: " + e.getMessage());
            System.out.printf("Você tentou sacar R$ %.2f mas tem apenas R$ %.2f%n",
                    e.getValorSolicitado(), e.getSaldoAtual());
        }
    }
}
```

---

## Boas Práticas

### 1. Não capture Throwable ou Exception genérico sem necessidade

```java
// RUIM — captura até Errors da JVM
try {
    processarDados();
} catch (Throwable t) {
    // perigoso demais
}

// RUIM — captura qualquer coisa, esconde problemas
try {
    processarDados();
} catch (Exception e) {
    System.out.println("Deu errado");
}

// BOM — captura apenas o que você sabe tratar
try {
    processarDados();
} catch (IOException e) {
    log.error("Erro de I/O ao processar dados", e);
    notificarAdministrador(e);
}
```

### 2. Nunca engula exceções (catch vazio)

```java
// PÉSSIMO — o erro some silenciosamente
try {
    abrirConexao();
} catch (Exception e) {
    // nada aqui — o erro é ignorado completamente
}

// BOM — pelo menos logue o erro
try {
    abrirConexao();
} catch (SQLException e) {
    logger.error("Falha ao abrir conexão com o banco", e);
    throw new RuntimeException("Serviço indisponível", e);
}
```

### 3. Mensagens de erro claras e informativas

```java
// RUIM
throw new IllegalArgumentException("valor inválido");

// BOM
throw new IllegalArgumentException(
    "Idade inválida: " + idade + ". Deve ser entre 0 e 150."
);
```

### 4. Preserve a exceção original com cause

```java
// RUIM — perde a stack trace original
try {
    conexao.executar();
} catch (SQLException e) {
    throw new RuntimeException("Erro de banco");  // perde o e
}

// BOM — encadeia a exceção original
try {
    conexao.executar();
} catch (SQLException e) {
    throw new RuntimeException("Erro ao executar operação no banco", e);  // passa e como cause
}
```

### 5. Prefira unchecked para erros de programação

Argumentos inválidos, estados inconsistentes — use `RuntimeException` ou suas subclasses. Não force o chamador a tratar algo que poderia ser prevenido com código correto.

### 6. Use checked para erros genuinamente recuperáveis

Se o chamador tem condições reais de se recuperar (tentar novamente, usar um arquivo alternativo, notificar o usuário), use checked exception.

### 7. Não use exceções para controle de fluxo normal

```java
// PÉSSIMO — uso de exceção para lógica normal
try {
    while (true) {
        int valor = iterator.next();
        processar(valor);
    }
} catch (NoSuchElementException e) {
    // fim da iteração — isso é fluxo normal, não erro!
}

// BOM
while (iterator.hasNext()) {
    int valor = iterator.next();
    processar(valor);
}
```

### 8. Feche recursos no finally ou use try-with-resources

Sempre garanta que conexões, streams e outros recursos sejam fechados mesmo em caso de erro.

---

## Erros Comuns

### 1. Capturar Exception e não relançar

```java
// Ruim: o chamador não sabe que algo deu errado
public void salvar(Dados d) {
    try {
        repositorio.persistir(d);
    } catch (Exception e) {
        System.out.println("Ops");  // erro "desaparece"
    }
}
```

### 2. Swallow de exceção checked convertendo em RuntimeException sem causa

```java
// Perde a raiz do problema
try {
    arquivo.ler();
} catch (IOException e) {
    throw new RuntimeException("Falhou");  // e foi perdido!
}
```

### 3. Ordem errada em múltiplos catch

```java
// NullPointerException nunca será capturado separadamente
catch (Exception e) { ... }
catch (NullPointerException e) { ... }  // código inacessível — erro de compilação
```

### 4. Usar exceções para validações de negócio no lugar errado

Lançar exceções dentro de loops em operações de alto volume prejudica performance, pois criar uma exceção é caro (captura a stack trace).

### 5. Esquecer de fechar recursos

```java
// RUIM — se a leitura falhar, o arquivo nunca é fechado
FileReader fr = new FileReader("arquivo.txt");
String conteudo = lerConteudo(fr);
fr.close();  // não chega aqui se lerConteudo() lançar exceção
```

### 6. Criar exceções genéricas sem contexto

```java
// RUIM — o que foi inválido? Qual o valor? Qual o contexto?
throw new Exception("Erro");

// BOM
throw new IllegalArgumentException("CPF inválido: '" + cpf + "'. Formato esperado: XXX.XXX.XXX-XX");
```

### 7. Re-throw sem informação extra

```java
try {
    operacao();
} catch (IOException e) {
    throw new IOException(e);  // inútil — apenas re-empacota sem adicionar contexto
}

// Melhor: adicionar contexto
} catch (IOException e) {
    throw new IOException("Falha ao processar arquivo de configuração: " + nomeArquivo, e);
}
```

### 8. Não documentar exceções no Javadoc

```java
/**
 * Processa o pagamento.
 *
 * @param valor o valor a ser pago
 * @throws IllegalArgumentException se valor for negativo ou zero
 * @throws SaldoInsuficienteException se saldo for menor que o valor
 * @throws PagamentoRecusadoException se a operadora recusar o pagamento
 */
public void processarPagamento(double valor) { ... }
```

---

## Exercícios

### Nível 1 — Iniciante

**Exercício 1.1:** Crie um método `dividir(int a, int b)` que:
- Lança `IllegalArgumentException` se `b` for zero (não use divisão por zero — valide antes)
- Retorna o resultado da divisão como `double`
- No `main`, chame o método com diferentes valores e trate a exceção exibindo uma mensagem amigável

**Exercício 1.2:** Crie um método `lerIdade(String entrada)` que:
- Usa `Integer.parseInt(entrada)` para converter a String
- Captura `NumberFormatException` e lança uma nova `IllegalArgumentException` com mensagem: "Idade inválida: 'abc' não é um número inteiro"
- Valida que a idade está entre 0 e 150, lançando `IllegalArgumentException` se não estiver

---

### Nível 2 — Intermediário

**Exercício 2.1:** Crie uma exceção customizada `EstoqueInsuficienteException` com os campos `produtoId`, `quantidadeDisponivel` e `quantidadeSolicitada`. Crie uma classe `Estoque` com método `retirar(String produtoId, int quantidade)` que lança essa exceção quando não há estoque. No `main`, demonstre o uso com tratamento de erro.

**Exercício 2.2:** Crie uma classe `ProcessadorArquivo` com o método `processar(String caminho)` que:
- Lê linha a linha de um arquivo usando `BufferedReader` (use try-with-resources)
- Retorna uma `List<String>` com todas as linhas
- Trata `FileNotFoundException` com mensagem específica: "Arquivo não encontrado: /caminho/arquivo.txt"
- Trata `IOException` com mensagem genérica de erro de leitura
- Use `finally` para imprimir "Processamento concluído" (dentro ou fora do try-with-resources)

---

### Nível 3 — Avançado

**Exercício 3.1:** Crie um sistema de pagamento com:
- Exceção checked `PagamentoException` com subcampos `codigoErro` e `mensagem`
- Exceções: `CartaoRecusadoException extends PagamentoException`, `LimiteExcedidoException extends PagamentoException`
- Interface `ProcessadorPagamento` com método `processar(double valor) throws PagamentoException`
- Implementações `ProcessadorCartao` e `ProcessadorBoleto`
- `ProcessadorCartao`: lança `CartaoRecusadoException` se valor > 5000, `LimiteExcedidoException` se > limite do cartão
- No `main`, demonstre tratamento em múltiplos catch e relançamento com cause

---

### Gabarito — Exercício 1.1

```java
public class Calculadora {

    public static double dividir(int a, int b) {
        if (b == 0) {
            throw new IllegalArgumentException("Divisor não pode ser zero");
        }
        return (double) a / b;
    }

    public static void main(String[] args) {
        int[][] pares = {{10, 2}, {7, 0}, {15, 3}, {0, 5}};

        for (int[] par : pares) {
            try {
                double resultado = dividir(par[0], par[1]);
                System.out.printf("%d / %d = %.2f%n", par[0], par[1], resultado);
            } catch (IllegalArgumentException e) {
                System.out.printf("%d / %d → Erro: %s%n", par[0], par[1], e.getMessage());
            }
        }
    }
}
```

### Gabarito — Exercício 2.1

```java
public class EstoqueInsuficienteException extends RuntimeException {

    private final String produtoId;
    private final int quantidadeDisponivel;
    private final int quantidadeSolicitada;

    public EstoqueInsuficienteException(String produtoId, int disponivel, int solicitada) {
        super(String.format(
            "Estoque insuficiente para '%s'. Disponível: %d | Solicitado: %d",
            produtoId, disponivel, solicitada
        ));
        this.produtoId = produtoId;
        this.quantidadeDisponivel = disponivel;
        this.quantidadeSolicitada = solicitada;
    }

    public String getProdutoId() { return produtoId; }
    public int getQuantidadeDisponivel() { return quantidadeDisponivel; }
    public int getQuantidadeSolicitada() { return quantidadeSolicitada; }
}

import java.util.HashMap;
import java.util.Map;

public class Estoque {

    private Map<String, Integer> produtos = new HashMap<>();

    public void adicionar(String produtoId, int quantidade) {
        produtos.merge(produtoId, quantidade, Integer::sum);
    }

    public void retirar(String produtoId, int quantidade) {
        int disponivel = produtos.getOrDefault(produtoId, 0);
        if (quantidade > disponivel) {
            throw new EstoqueInsuficienteException(produtoId, disponivel, quantidade);
        }
        produtos.put(produtoId, disponivel - quantidade);
    }

    public int getQuantidade(String produtoId) {
        return produtos.getOrDefault(produtoId, 0);
    }
}

public class Main {
    public static void main(String[] args) {
        Estoque estoque = new Estoque();
        estoque.adicionar("PROD-001", 10);
        estoque.adicionar("PROD-002", 3);

        try {
            estoque.retirar("PROD-001", 5);
            System.out.println("Retirada de 5 unidades de PROD-001 OK. Saldo: " + estoque.getQuantidade("PROD-001"));

            estoque.retirar("PROD-002", 10);  // vai lançar exceção
        } catch (EstoqueInsuficienteException e) {
            System.out.println("Erro: " + e.getMessage());
            System.out.println("Produto: " + e.getProdutoId());
        }
    }
}
```
