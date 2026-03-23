# Exercícios — Módulo 01: Java e Orientação a Objetos

Exercícios organizados por tópico em três níveis. Complete o nível **Básico** antes de avançar ao próximo tópico.

> **Convenção:** `[B]` = Básico · `[I]` = Intermediário · `[A]` = Avançado

---

## Tópico 01 — Fundamentos Java

**`[B]`** 1. Declare variáveis dos 8 tipos primitivos e imprima cada uma com `System.out.println`. Inclua o tipo no texto: `"int: 42"`.

**`[B]`** 2. Escreva um programa que lê um número inteiro do console com `Scanner` e imprime se ele é par ou ímpar.

**`[B]`** 3. Escreva um método estático `calcularFatorial(int n)` que retorna o fatorial de `n`. Teste com 0, 1, 5 e 10.

**`[I]`** 4. Crie um array de 10 inteiros preenchidos com números aleatórios entre 1 e 100. Imprima o maior, o menor e a média.

**`[I]`** 5. Escreva um método `inverterArray(int[] arr)` que devolve um novo array com os elementos na ordem inversa.

**`[I]`** 6. Implemente um menu de console com `switch` que oferece as opções: 1-Soma, 2-Subtração, 3-Multiplicação, 4-Divisão, 0-Sair. Leia dois números e execute a operação escolhida.

**`[A]`** 7. Escreva um método `eHPrimo(int n)` e use-o para listar todos os números primos entre 1 e 100.

**`[A]`** 8. Implemente o algoritmo de ordenação **Bubble Sort** sem usar `Arrays.sort`. Teste com um array desordenado de 10 elementos.

---

## Tópico 02 — Classes e Objetos

**`[B]`** 9. Crie a classe `Retangulo` com atributos `largura` e `altura`. Adicione métodos `calcularArea()` e `calcularPerimetro()`. Instancie e use no `main`.

**`[B]`** 10. Crie a classe `ContaBancaria` com atributos `titular` (String) e `saldo` (double). Adicione métodos `depositar(double valor)` e `sacar(double valor)`. No `sacar`, verifique se há saldo suficiente.

**`[B]`** 11. Sobrescreva `toString()` na classe `ContaBancaria` para retornar: `"Conta[titular=João, saldo=R$500,00]"`.

**`[I]`** 12. Crie a classe `Ponto` com `x` e `y`. Adicione o método `distanciaAte(Ponto outro)` usando a fórmula euclidiana. Crie `Circulo` com `centro` (Ponto) e `raio`. Adicione `area()` e `contemPonto(Ponto p)`.

**`[I]`** 13. Implemente a classe `Pilha` (stack) usando um array interno de `Object[]`. Implemente `push(Object)`, `pop()`, `peek()` e `isEmpty()`.

**`[A]`** 14. Crie a classe `Matriz` com um array bidimensional `int[][]`. Implemente métodos para: somar duas matrizes, transpor e verificar se é quadrada.

---

## Tópico 03 — Encapsulamento

**`[B]`** 15. Crie a classe `Produto` com `nome`, `preco` e `estoque`. Todos os atributos devem ser `private`. No setter de `preco`, lance `IllegalArgumentException` se o valor for negativo. No setter de `estoque`, rejeite valores negativos.

**`[B]`** 16. Reescreva a classe `ContaBancaria` do exercício 10 usando `private` em todos os atributos e validando no `sacar` que o valor é positivo.

**`[I]`** 17. Crie o `record` `Endereco(String rua, String cidade, String estado, String cep)`. Crie também uma classe `Pessoa` (com classe tradicional) que possui um `Endereco`. Implemente `toString()` que mostra nome e endereço completo.

**`[I]`** 18. Crie a classe `Temperatura` que armazena o valor em Celsius internamente. Exponha métodos `getCelsius()`, `getFahrenheit()` e `getKelvin()`. O setter deve rejeitar valores abaixo de -273.15 (zero absoluto).

**`[A]`** 19. Implemente o padrão **Builder** para a classe `Usuario(nome, email, telefone, cidade, ativo)`. Os campos obrigatórios são `nome` e `email`; os demais são opcionais com valores padrão.

---

## Tópico 04 — Herança

**`[B]`** 20. Crie a hierarquia: `Animal` (nome, som) → `Cachorro` e `Gato`. Sobrescreva `fazerSom()` em cada subclasse. No `main`, crie uma lista de `Animal` com instâncias mistas e chame `fazerSom()` em cada uma.

**`[B]`** 21. Crie `FormaGeometrica` (abstrata) com `calcularArea()` abstrato. Crie subclasses `Quadrado`, `Triangulo` e `Circulo`. Implemente `calcularArea()` em cada uma.

**`[I]`** 22. Crie `Veiculo(marca, modelo, ano)` com `calcularIPVA()`. Crie `Carro` (adiciona `numeroPortas`) e `Moto` (adiciona `cilindrada`). IPVA do carro = 3% do valor, da moto = 2%.

**`[I]`** 23. Sobrescreva `equals()` e `hashCode()` na classe `Produto` (exercício 15), comparando por `nome` e `preco`. Teste colocando dois produtos iguais num `HashSet` — apenas um deve ser mantido.

**`[A]`** 24. Crie uma hierarquia de `Funcionario` com salário base. Subclasses: `Gerente` (+ bônus fixo), `Vendedor` (+ comissão percentual), `Estagiario` (sem benefícios extras). Implemente `calcularSalarioTotal()` em cada uma e crie um relatório de folha de pagamento.

---

## Tópico 05 — Polimorfismo e Abstração

**`[B]`** 25. Crie a interface `Imprimivel` com o método `imprimir()`. Implemente-a em `Relatorio`, `Fatura` e `Boleto`. Crie um método `imprimirTodos(List<Imprimivel> itens)` que chama `imprimir()` em cada um.

**`[B]`** 26. Crie a interface `Calculavel` com `calcular(double a, double b)`. Crie as implementações `Somador`, `Subtrator`, `Multiplicador` e `Divisor`. Teste passando cada implementação como argumento de um método.

**`[I]`** 27. Crie a classe abstrata `Pagamento` com `processar()` abstrato e `gerarRecibo()` concreto. Subclasses: `PagamentoCartao` (valida limite), `PagamentoPix` (chave Pix), `PagamentoBoleto` (código de barras).

**`[I]`** 28. Use `instanceof` e pattern matching (Java 16+) para implementar um método `descricaoForma(FormaGeometrica f)` que retorna descrições diferentes para `Circulo`, `Quadrado` e `Triangulo`.

**`[A]`** 29. Implemente o padrão **Strategy**: crie a interface `EstrategiaDesconto` com `calcularDesconto(double preco)`. Implemente `SemDesconto`, `DescontoPercentual`, `DescontoFixo` e `DescontoProgressivo` (maior percentual para preços mais altos). Use em uma classe `Carrinho`.

---

## Tópico 06 — Exceções

**`[B]`** 30. Crie a exceção `SaldoInsuficienteException` que estende `RuntimeException`. Lance-a no `sacar()` da `ContaBancaria`. Trate-a com `try/catch` no `main` imprimindo uma mensagem amigável.

**`[B]`** 31. Escreva um método `lerArquivo(String caminho)` que lança `IOException`. No `main`, trate o caso do arquivo não existir com mensagem clara e o caso de erro de leitura com outra mensagem (multi-catch).

**`[I]`** 32. Use **try-with-resources** para criar um `Scanner` que lê um arquivo e soma todos os números inteiros (um por linha). Se uma linha não for um número, use `NumberFormatException` para ignorá-la e continuar.

**`[I]`** 33. Crie a hierarquia de exceções de domínio para um sistema bancário: `BancarioException` (base) → `ContaNotFoundException`, `SaldoInsuficienteException`, `LimiteDiarioExcedidoException`. Cada uma deve ter construtor com mensagem e causa.

**`[A]`** 34. Implemente um parser de CSV que lê linha por linha. Para cada linha inválida, acumule o erro numa lista de `ErroParsing(int linha, String motivo)` em vez de lançar exceção. Ao final, se houver erros, lance uma `ParseException` contendo toda a lista.

---

## Tópico 07 — Collections

**`[B]`** 35. Dado um `List<String>` com nomes duplicados, use um `LinkedHashSet` para remover os duplicados mantendo a ordem de inserção. Imprima antes e depois.

**`[B]`** 36. Crie um `HashMap<String, Integer>` que conta a frequência de cada palavra em uma frase. Para a frase `"o rato roeu a roupa do rei"`, imprima cada palavra e sua contagem.

**`[I]`** 37. Crie uma `List<Produto>` (Produto tem `nome` e `preco`). Use `Collections.sort` com um `Comparator` que ordena: primeiro por preço crescente, e em caso de empate, por nome alfabético.

**`[I]`** 38. Implemente o método `agruparPorEstado(List<Cliente> clientes)` que retorna um `Map<String, List<Cliente>>` com os clientes agrupados pelo campo `estado`.

**`[A]`** 39. Implemente uma `class Cache<K, V>` usando `LinkedHashMap` com capacidade máxima. Quando atingir a capacidade, remova o elemento inserido há mais tempo (LRU simplificado — use o construtor do `LinkedHashMap` com `accessOrder=true`).

---

## Tópico 08 — Enums e Boas Práticas

**`[B]`** 40. Crie o enum `DiaSemana` com os 7 dias. Adicione o método `ehUtil()` que retorna `true` para segunda a sexta, e `ehFimDeSemana()` para sábado e domingo.

**`[B]`** 41. Crie o enum `StatusPedido` com valores `PENDENTE`, `CONFIRMADO`, `EM_ENTREGA`, `ENTREGUE`, `CANCELADO`. Adicione o atributo `descricao` (String) e o método `podeSerCancelado()` que retorna `true` apenas para `PENDENTE` e `CONFIRMADO`.

**`[I]`** 42. Refatore a classe `ContaBancaria` para seguir o princípio **SRP** (Single Responsibility). Separe a lógica de validação em `ValidadorConta`, a de formatação em `FormatadorConta` e a de persistência em `RepositorioConta` (interface).

**`[A]`** 43. Identifique e corrija os seguintes code smells no código abaixo:

```java
public class X {
    public void f(int t, String n, double v, String c, boolean a) {
        if (t == 1) {
            System.out.println("Cliente: " + n + " valor: " + v);
        } else if (t == 2) {
            System.out.println("Fornecedor: " + n);
        } else if (t == 3) {
            System.out.println("Funcionario: " + n + " cargo: " + c);
        }
    }
}
```

---

## Desafio Integrador — Sistema de Vendas

Construa um sistema de gerenciamento de vendas no console integrando todos os conceitos do módulo:

### Entidades

```
Produto (id, nome, categoria, preco, estoque)
Cliente (id, nome, email, cidade, estado)
ItemPedido (produto, quantidade, precoUnitario)
Pedido (id, cliente, itens, status, dataCriacao)
```

### Requisitos

**Nível 1 — Estrutura (Básico)**
- [ ] Todas as classes com encapsulamento completo (private + getters/setters validados)
- [ ] `StatusPedido` como enum com `podeSerCancelado()`
- [ ] `Pedido.calcularTotal()` que soma `quantidade × precoUnitario` de cada item

**Nível 2 — Comportamento (Intermediário)**
- [ ] Interface `Relatorio` com `gerar()` — implemente `RelatorioPedidos` e `RelatorioEstoque`
- [ ] Exceções customizadas: `ProdutoSemEstoqueException`, `PedidoNotFoundException`
- [ ] Ao adicionar item ao pedido, verificar e decrementar estoque
- [ ] `RepositorioPedidos` (interface) com `salvar`, `buscarPorId`, `listarPorCliente`

**Nível 3 — Coleções e Análise (Avançado)**
- [ ] Implementar `RepositorioPedidos` usando `HashMap<Integer, Pedido>`
- [ ] Método `pedidosPorStatus()` retornando `Map<StatusPedido, List<Pedido>>`
- [ ] Método `top3ClientesPorValorTotal()` usando `Comparator` em `List<Cliente>`
- [ ] Menu interativo completo no console com todas as operações

---

*Exercícios do Módulo 01 — 43 exercícios + 1 desafio integrador*
