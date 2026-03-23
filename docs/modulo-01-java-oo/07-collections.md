# 07 — Collections Framework

## Revisão do Tópico Anterior
Você aprendeu Polimorfismo e Abstração (tópicos 05 e 06 tratam de exceções). Agora vamos estudar as **Collections** — estruturas de dados essenciais do Java.

---

## O Problema dos Arrays

Arrays são limitados:
```java
// Array: tamanho FIXO, sem métodos convenientes
String[] nomes = new String[3];
nomes[0] = "Ana";
nomes[1] = "Bruno";
// Quero adicionar mais? Precisa criar novo array maior e copiar...
// Quero remover "Ana"? Precisa deslocar todos os elementos...
// Quero verificar se "Bruno" existe? Percorrer manualmente...
```

**Collections** resolvem esses problemas com estruturas dinâmicas e métodos prontos.

---

## Hierarquia do Collections Framework

```
java.lang.Iterable
    └── java.util.Collection
            ├── List (ordenada, permite duplicatas)
            │    ├── ArrayList
            │    └── LinkedList
            ├── Set (sem duplicatas)
            │    ├── HashSet (sem ordem)
            │    ├── LinkedHashSet (ordem de inserção)
            │    └── TreeSet (ordenado naturalmente)
            └── Queue / Deque
                 └── ArrayDeque

java.util.Map (chave → valor, não herda de Collection)
    ├── HashMap (sem ordem)
    ├── LinkedHashMap (ordem de inserção)
    └── TreeMap (ordenado pela chave)
```

---

## Generics — Coleções com Tipo Seguro

Sem generics, Collections guardam `Object` e precisam de cast:
```java
List lista = new ArrayList();
lista.add("Ana");
lista.add(42);  // misturou tipos!
String nome = (String) lista.get(0);  // cast manual, pode dar ClassCastException
```

Com generics (sempre use!):
```java
List<String> nomes = new ArrayList<>();  // apenas String, compilador protege
nomes.add("Ana");
// nomes.add(42);  // ERRO DE COMPILAÇÃO
String nome = nomes.get(0);  // sem cast
```

---

## List — Coleção Ordenada

### ArrayList — uso geral (array dinâmico)

```java
import java.util.ArrayList;
import java.util.List;

List<String> frutas = new ArrayList<>();

// Adicionando
frutas.add("Maçã");
frutas.add("Banana");
frutas.add("Laranja");
frutas.add(1, "Uva");  // inserir na posição 1

System.out.println(frutas);  // [Maçã, Uva, Banana, Laranja]
System.out.println(frutas.size());      // 4
System.out.println(frutas.get(0));      // Maçã
System.out.println(frutas.contains("Banana"));  // true
System.out.println(frutas.indexOf("Banana"));   // 2 (posição)

// Removendo
frutas.remove("Banana");        // por valor
frutas.remove(0);               // por índice
System.out.println(frutas);     // [Uva, Laranja]

// Iteração
for (String fruta : frutas) {
    System.out.println(fruta);
}

// Com Lambda (Java 8+)
frutas.forEach(f -> System.out.println("Fruta: " + f));

// Verificar vazio
System.out.println(frutas.isEmpty());  // false
frutas.clear();
System.out.println(frutas.isEmpty());  // true
```

### Criando List com valores iniciais

```java
// Imutável (Java 9+)
List<String> cores = List.of("Vermelho", "Verde", "Azul");
// cores.add("Amarelo");  // UnsupportedOperationException!

// Mutável com valores iniciais
List<String> dias = new ArrayList<>(List.of("Seg", "Ter", "Qua"));
dias.add("Qui");  // OK
```

### LinkedList — bom para inserção/remoção frequente no início/fim

```java
import java.util.LinkedList;

LinkedList<String> fila = new LinkedList<>();
fila.addFirst("Primeiro");
fila.addLast("Último");
fila.addFirst("Novo Primeiro");

System.out.println(fila.getFirst());  // Novo Primeiro
System.out.println(fila.getLast());   // Último
fila.removeFirst();
System.out.println(fila);  // [Primeiro, Último]
```

---

## Set — Sem Duplicatas

```java
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.TreeSet;

// HashSet: sem garantia de ordem, mais rápido
Set<String> habilidades = new HashSet<>();
habilidades.add("Java");
habilidades.add("SQL");
habilidades.add("Java");   // duplicata ignorada
habilidades.add("Python");
System.out.println(habilidades.size());  // 3 (não 4)
System.out.println(habilidades);         // ordem não garantida

// LinkedHashSet: mantém ordem de inserção
Set<String> ordenadoPorInsercao = new LinkedHashSet<>();
ordenadoPorInsercao.add("Banana");
ordenadoPorInsercao.add("Maçã");
ordenadoPorInsercao.add("Laranja");
System.out.println(ordenadoPorInsercao);  // [Banana, Maçã, Laranja]

// TreeSet: ordenação natural (alfabética para String)
Set<String> ordenadoAlfabeticamente = new TreeSet<>();
ordenadoAlfabeticamente.add("Banana");
ordenadoAlfabeticamente.add("Maçã");
ordenadoAlfabeticamente.add("Abacaxi");
System.out.println(ordenadoAlfabeticamente);  // [Abacaxi, Banana, Maçã]

// Operações de conjunto
Set<String> a = new HashSet<>(Set.of("A", "B", "C"));
Set<String> b = new HashSet<>(Set.of("B", "C", "D"));

Set<String> intersecao = new HashSet<>(a);
intersecao.retainAll(b);  // {B, C}

Set<String> uniao = new HashSet<>(a);
uniao.addAll(b);  // {A, B, C, D}

Set<String> diferenca = new HashSet<>(a);
diferenca.removeAll(b);  // {A}
```

---

## Map — Chave → Valor

```java
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;

// HashMap: sem garantia de ordem, mais rápido
Map<String, Integer> populacao = new HashMap<>();
populacao.put("São Paulo", 12_000_000);
populacao.put("Rio de Janeiro", 6_700_000);
populacao.put("Belo Horizonte", 2_500_000);
populacao.put("São Paulo", 12_500_000);  // atualiza valor existente

System.out.println(populacao.get("Rio de Janeiro"));   // 6700000
System.out.println(populacao.getOrDefault("Brasília", 0));  // 0 (não existe)
System.out.println(populacao.containsKey("Curitiba")); // false
System.out.println(populacao.size());   // 3

// Iterar sobre Map
for (Map.Entry<String, Integer> entrada : populacao.entrySet()) {
    System.out.println(entrada.getKey() + " → " + entrada.getValue());
}

// Iterar só sobre chaves
for (String cidade : populacao.keySet()) {
    System.out.println(cidade);
}

// Iterar só sobre valores
for (int pop : populacao.values()) {
    System.out.println(pop);
}

// forEach com lambda (Java 8+)
populacao.forEach((cidade, pop) ->
    System.out.printf("%s: %,d habitantes%n", cidade, pop));

// Operações úteis
populacao.remove("Belo Horizonte");
populacao.putIfAbsent("Curitiba", 1_900_000);  // só adiciona se não existir
populacao.merge("São Paulo", 100_000, Integer::sum);  // soma ao valor existente
```

---

## Ordenação — Comparable e Comparator

### Comparable — ordenação natural (dentro da classe)

```java
public class Produto implements Comparable<Produto> {
    private String nome;
    private double preco;

    public Produto(String nome, double preco) {
        this.nome = nome;
        this.preco = preco;
    }

    public String getNome() { return nome; }
    public double getPreco() { return preco; }

    // Define ordenação natural: por preço crescente
    @Override
    public int compareTo(Produto outro) {
        return Double.compare(this.preco, outro.preco);
        // Retorna: negativo = this < outro, zero = iguais, positivo = this > outro
    }

    @Override
    public String toString() {
        return String.format("%s (R$%.2f)", nome, preco);
    }
}

// Uso com TreeSet (usa Comparable automaticamente)
TreeSet<Produto> produtos = new TreeSet<>();
produtos.add(new Produto("Notebook", 3500.00));
produtos.add(new Produto("Mouse", 80.00));
produtos.add(new Produto("Teclado", 200.00));

produtos.forEach(System.out::println);
// Mouse (R$80,00)
// Teclado (R$200,00)
// Notebook (R$3.500,00)
```

### Comparator — ordenação externa (sem modificar a classe)

```java
import java.util.Comparator;
import java.util.List;

List<Produto> lista = new ArrayList<>(List.of(
    new Produto("Notebook", 3500.00),
    new Produto("Mouse", 80.00),
    new Produto("Teclado", 200.00),
    new Produto("Monitor", 1200.00)
));

// Ordenar por nome (alfabético)
lista.sort(Comparator.comparing(Produto::getNome));
lista.forEach(System.out::println);

// Ordenar por preço decrescente
lista.sort(Comparator.comparing(Produto::getPreco).reversed());
lista.forEach(System.out::println);

// Ordenar por múltiplos critérios: nome primeiro, depois preço
lista.sort(Comparator.comparing(Produto::getNome)
                     .thenComparingDouble(Produto::getPreco));
```

---

## Collections — Métodos Utilitários

```java
import java.util.Collections;

List<Integer> numeros = new ArrayList<>(List.of(5, 3, 8, 1, 9, 2));

Collections.sort(numeros);        // [1, 2, 3, 5, 8, 9]
Collections.reverse(numeros);     // [9, 8, 5, 3, 2, 1]
Collections.shuffle(numeros);     // ordem aleatória
System.out.println(Collections.max(numeros));  // maior elemento
System.out.println(Collections.min(numeros));  // menor elemento
Collections.swap(numeros, 0, 1);  // troca posições 0 e 1
Collections.fill(numeros, 0);     // preenche tudo com 0

// Cópia imutável
List<String> imutavel = Collections.unmodifiableList(lista);
```

---

## Exemplo Completo: Gerenciamento de Alunos

```java
import java.util.*;

public class Turma {
    private String nomeTurma;
    private Map<String, List<Double>> notasPorAluno = new LinkedHashMap<>();

    public Turma(String nomeTurma) { this.nomeTurma = nomeTurma; }

    public void adicionarAluno(String nome) {
        notasPorAluno.putIfAbsent(nome, new ArrayList<>());
    }

    public void lancarNota(String aluno, double nota) {
        if (!notasPorAluno.containsKey(aluno)) {
            throw new IllegalArgumentException("Aluno não encontrado: " + aluno);
        }
        if (nota < 0 || nota > 10) {
            throw new IllegalArgumentException("Nota inválida: " + nota);
        }
        notasPorAluno.get(aluno).add(nota);
    }

    public double calcularMedia(String aluno) {
        List<Double> notas = notasPorAluno.getOrDefault(aluno, List.of());
        if (notas.isEmpty()) return 0;
        return notas.stream().mapToDouble(Double::doubleValue).average().orElse(0);
    }

    public void exibirBoletim() {
        System.out.println("=== Boletim: " + nomeTurma + " ===");
        notasPorAluno.forEach((aluno, notas) -> {
            double media = calcularMedia(aluno);
            String situacao = media >= 7.0 ? "APROVADO" : media >= 5.0 ? "RECUPERAÇÃO" : "REPROVADO";
            System.out.printf("%-20s | Média: %.1f | %s%n", aluno, media, situacao);
        });
    }

    public Set<String> alunosAprovados() {
        Set<String> aprovados = new LinkedHashSet<>();
        notasPorAluno.keySet().stream()
            .filter(aluno -> calcularMedia(aluno) >= 7.0)
            .forEach(aprovados::add);
        return aprovados;
    }
}

// Uso:
Turma turma = new Turma("Java Avançado - 2026");
turma.adicionarAluno("Ana");
turma.adicionarAluno("Bruno");
turma.adicionarAluno("Carlos");

turma.lancarNota("Ana", 8.5);
turma.lancarNota("Ana", 9.0);
turma.lancarNota("Bruno", 6.0);
turma.lancarNota("Bruno", 5.5);
turma.lancarNota("Carlos", 4.0);
turma.lancarNota("Carlos", 3.5);

turma.exibirBoletim();
System.out.println("Aprovados: " + turma.alunosAprovados());
```

---

## Quando Usar Cada Coleção

| Estrutura | Use quando |
|-----------|-----------|
| `ArrayList` | Acesso por índice frequente, poucas inserções no meio |
| `LinkedList` | Muitas inserções/remoções no início/fim |
| `HashSet` | Sem duplicatas, sem precisar de ordem |
| `LinkedHashSet` | Sem duplicatas, manter ordem de inserção |
| `TreeSet` | Sem duplicatas, ordenação automática |
| `HashMap` | Par chave-valor, sem ordem |
| `LinkedHashMap` | Par chave-valor, ordem de inserção |
| `TreeMap` | Par chave-valor, ordenado pela chave |

---

## Exercícios

### Básico
1. Crie uma `List<String>` com 5 nomes, ordene-a e imprima
2. Crie um `Set<Integer>` com números de 1 a 10 (com duplicatas na inserção) e verifique o tamanho
3. Crie um `Map<String, String>` para capitais: chave = estado, valor = capital. Itere e imprima

### Intermediário
4. Implemente um contador de palavras: dado um texto, contar quantas vezes cada palavra aparece (`Map<String, Integer>`)
5. Crie uma lista de produtos e ordene por preço, depois imprima os 3 mais baratos
6. Implemente `Comparable<Aluno>` que ordena por nota decrescente e nome crescente em caso de empate

### Avançado
7. Implemente um `RepositorioClientes` com `Map<Long, Cliente>` interno. Métodos: `salvar()`, `buscarPorId()`, `listarTodos()`, `remover()`, `buscarPorNome()`
8. Crie dois Sets de skills de desenvolvedores diferentes e calcule: interseção (skills em comum), diferença (skills exclusivas de cada um), união (todas as skills)
9. Implemente uma função que agrupa uma lista de pedidos por cliente usando `Map<String, List<Pedido>>`
