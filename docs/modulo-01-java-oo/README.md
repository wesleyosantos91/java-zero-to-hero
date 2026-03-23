# Módulo 01 — Java e Orientação a Objetos

## Visão Geral

Bem-vindo ao primeiro módulo da trilha **Java Zero to Hero**! Este módulo é a base de toda a sua jornada como desenvolvedor Java. Aqui você aprenderá desde o que é Java e como ele funciona até os pilares da Programação Orientada a Objetos (POO), tratamento de exceções, coleções e boas práticas de modelagem.

Não tenha pressa. Este módulo é denso, mas cada conceito está explicado de forma progressiva e com exemplos práticos. Se você nunca programou antes, você está no lugar certo.

---

## Ementa Completa

### 1. Fundamentos da Linguagem Java
- Histórico e propósito do Java
- JVM, JDK e JRE: diferenças e funcionamento
- Ciclo de compilação e execução (bytecode)
- Estrutura de um programa Java
- Tipos primitivos e String
- Variáveis, operadores e expressões
- Estruturas de controle (if, switch)
- Laços de repetição (for, while, do-while, for-each)
- Arrays unidimensionais
- Métodos estáticos
- Convenções de nomenclatura

### 2. Classes e Objetos
- O paradigma orientado a objetos
- Classes como moldes e objetos como instâncias
- Atributos e métodos
- Construtores padrão e parametrizados
- Palavra-chave `this`
- Criação de objetos com `new`
- Referências e `null`
- Garbage Collector
- Sobrescrita de `toString()`

### 3. Encapsulamento
- Conceito e motivação
- Modificadores de acesso
- Getters e setters
- Validação nos setters
- JavaBeans Convention
- Records (Java 16+)

### 4. Herança
- Reutilização de código com `extends`
- Hierarquia de classes
- Palavra-chave `super`
- Sobrescrita de métodos (`@Override`)
- A classe `Object`
- `equals()`, `hashCode()` e `toString()`
- Quando NÃO usar herança

### 5. Polimorfismo e Abstração
- Polimorfismo em tempo de compilação e execução
- Upcasting e downcasting
- Operador `instanceof`
- Classes abstratas
- Interfaces
- `default` e `static` methods em interfaces (Java 8+)
- Classe abstrata vs Interface

### 6. Exceções
- O que são exceções e sua hierarquia
- Checked vs Unchecked
- `try`, `catch`, `finally`, `throw`, `throws`
- Multi-catch e try-with-resources
- Exceções customizadas
- Boas práticas

### 7. Collections Framework
- Limitações dos arrays
- Hierarquia do Collections Framework
- List: `ArrayList` e `LinkedList`
- Set: `HashSet`, `LinkedHashSet`, `TreeSet`
- Map: `HashMap`, `LinkedHashMap`, `TreeMap`
- Generics
- Iteração sobre coleções
- `Comparable` e `Comparator`

### 8. Enums e Boas Práticas
- Enumerações com atributos e métodos
- Sobrecarga de métodos
- Composição vs Herança
- `static` e `final`
- Princípios SOLID (introdução)
- Code smells comuns

### 9. Projeto Prático
- Sistema de Gerenciamento de Biblioteca
- Modelagem OO completa
- Implementação passo a passo
- Classes, enums e exceções customizadas
- Menu interativo no console

---

## Objetivos de Aprendizado

Ao concluir este módulo, você será capaz de:

1. **Explicar** o que é Java, como ele funciona e por que é amplamente usado na indústria
2. **Escrever** programas Java simples e estruturados com lógica de controle e repetição
3. **Criar** classes bem modeladas com atributos, métodos e construtores apropriados
4. **Aplicar** os quatro pilares da POO: encapsulamento, herança, polimorfismo e abstração
5. **Tratar** exceções de forma correta e criar suas próprias exceções customizadas
6. **Utilizar** as principais estruturas de dados da Collections Framework
7. **Modelar** sistemas simples usando boas práticas de design orientado a objetos
8. **Identificar** e corrigir erros comuns de iniciantes em Java

---

## Pré-Requisitos

Este módulo foi projetado para **iniciantes absolutos**, mas é esperado que você:

- Saiba usar um computador básico (instalar programas, navegar em pastas)
- Tenha o **JDK 17** ou superior instalado (veja o guia de setup no módulo 00)
- Tenha uma IDE configurada (recomendamos **IntelliJ IDEA Community Edition** ou **VS Code com extensão Java**)
- Esteja disposto a praticar — programação se aprende fazendo!

Se você ainda não fez o setup, volte ao módulo `00-como-usar-este-material.md` antes de continuar.

---

## Estrutura do Módulo

```
docs/modulo-01-java-oo/
├── README.md                    ← Você está aqui
├── 01-fundamentos-java.md       ← Comece aqui!
├── 02-classes-e-objetos.md
├── 03-encapsulamento.md
├── 04-heranca.md
├── 05-polimorfismo-abstracao.md
├── 06-excecoes.md
├── 07-collections.md
├── 08-enum-e-boas-praticas.md
├── 09-projeto-pratico.md        ← Projeto integrador
└── exercicios.md                ← 43 exercícios + desafio integrador
```

---

## Ordem de Estudo Recomendada

Siga a ordem dos arquivos numerados. Cada tópico constrói sobre o anterior:

```
Fundamentos Java
      ↓
Classes e Objetos
      ↓
Encapsulamento
      ↓
Herança
      ↓
Polimorfismo e Abstração
      ↓
Exceções
      ↓
Collections
      ↓
Enums e Boas Práticas
      ↓
Projeto Prático (integração de tudo)
```

**Tempo estimado:** 3 a 6 semanas, estudando de 1 a 2 horas por dia.

---

## Como Estudar Este Módulo

### Método Recomendado

1. **Leia** o conteúdo teórico com atenção
2. **Copie** os exemplos de código na sua IDE (não copie e cole — digitar ajuda a memorizar)
3. **Execute** o código e observe o resultado
4. **Modifique** o código para experimentar variações
5. **Faça** os exercícios de cada nível antes de avançar
6. **Revise** o conteúdo anterior se algo não fizer sentido

### Dicas de Aprendizado

- **Não decore, entenda.** Se você entender o *por quê*, vai lembrar o *como* naturalmente.
- **Erros são seus aliados.** Quando seu código não compilar ou dar erro em tempo de execução, leia a mensagem de erro com calma — ela está te dizendo exatamente o que está errado.
- **Pesquise.** Buscar no Google, Stack Overflow e documentação oficial faz parte do trabalho de um desenvolvedor.
- **Pratique diariamente.** 30 minutos todo dia supera 4 horas uma vez por semana.

---

## Checklist de Conclusão do Módulo

Use este checklist para acompanhar seu progresso. Marque cada item quando sentir confiança no tópico:

### Fundamentos Java
- [ ] Sei explicar o que são JVM, JDK e JRE
- [ ] Consigo criar e executar um programa Java simples
- [ ] Conheço todos os tipos primitivos e sei quando usar cada um
- [ ] Sei usar operadores aritméticos, relacionais e lógicos
- [ ] Consigo escrever estruturas if/else, switch
- [ ] Consigo escrever laços for, while, do-while e for-each
- [ ] Sei criar e percorrer arrays básicos
- [ ] Sei criar métodos estáticos simples

### Classes e Objetos
- [ ] Entendo a diferença entre classe e objeto
- [ ] Sei criar uma classe com atributos e métodos
- [ ] Sei criar construtores padrão e parametrizados
- [ ] Entendo e sei usar a palavra-chave `this`
- [ ] Sei criar objetos com `new`
- [ ] Entendo referências e `null`
- [ ] Sei sobrescrever `toString()`

### Encapsulamento
- [ ] Sei explicar o que é encapsulamento e por que ele existe
- [ ] Conheço os quatro modificadores de acesso
- [ ] Sei criar getters e setters adequados
- [ ] Sei validar dados dentro de setters
- [ ] Conheço a convenção JavaBeans
- [ ] Sei criar um Record simples (Java 16+)

### Herança
- [ ] Sei usar `extends` para herdar de uma classe
- [ ] Sei usar `super` para acessar construtor e métodos do pai
- [ ] Sei sobrescrever métodos com `@Override`
- [ ] Entendo que toda classe herda de `Object`
- [ ] Sei sobrescrever `equals()`, `hashCode()` e `toString()`
- [ ] Entendo quando NÃO usar herança

### Polimorfismo e Abstração
- [ ] Sei explicar polimorfismo com exemplos práticos
- [ ] Entendo upcasting e downcasting
- [ ] Sei usar o operador `instanceof`
- [ ] Sei criar classes abstratas e métodos abstratos
- [ ] Sei criar interfaces e implementá-las
- [ ] Entendo a diferença entre classe abstrata e interface
- [ ] Sei usar `default` methods em interfaces

### Exceções
- [ ] Entendo a hierarquia de exceções do Java
- [ ] Sei a diferença entre checked e unchecked exceptions
- [ ] Sei usar try/catch/finally corretamente
- [ ] Sei usar multi-catch e try-with-resources
- [ ] Sei criar minhas próprias exceções
- [ ] Conheço as boas práticas de tratamento de exceções

### Collections
- [ ] Entendo por que Collections são melhores que arrays simples
- [ ] Sei usar ArrayList e LinkedList
- [ ] Sei usar HashSet, LinkedHashSet e TreeSet
- [ ] Sei usar HashMap, LinkedHashMap e TreeMap
- [ ] Entendo o conceito de Generics
- [ ] Sei iterar sobre coleções com for-each e Iterator
- [ ] Sei implementar Comparable e usar Comparator

### Enums e Boas Práticas
- [ ] Sei criar enums simples e com atributos/métodos
- [ ] Entendo sobrecarga de métodos
- [ ] Sei explicar a diferença entre composição e herança
- [ ] Conheço os princípios SOLID básicos
- [ ] Reconheço code smells comuns

### Projeto Prático
- [ ] Completei o Sistema de Gerenciamento de Biblioteca
- [ ] Todas as classes estão bem modeladas com encapsulamento
- [ ] O projeto usa herança e polimorfismo onde apropriado
- [ ] O projeto trata exceções adequadamente
- [ ] O projeto usa Collections onde faz sentido
- [ ] O código compila e executa sem erros

---

## Recursos Complementares

### Documentação Oficial
- [Java SE 17 Documentation](https://docs.oracle.com/en/java/javase/17/)
- [Java Language Specification](https://docs.oracle.com/javase/specs/)
- [Java API Reference](https://docs.oracle.com/en/java/javase/17/docs/api/)

### Ferramentas Online
- [JShell](https://docs.oracle.com/en/java/javase/17/jshell/) — REPL interativo do Java (ótimo para experimentar código rapidamente)
- [Visualizador de execução Java](https://pythontutor.com/java.html) — veja o código executando passo a passo

### Livros Recomendados
- *Core Java Volume I* — Cay S. Horstmann
- *Effective Java* — Joshua Bloch (leitura após concluir o módulo)
- *Clean Code* — Robert C. Martin

---

## Suporte e Dúvidas

Se travar em algum exercício ou conceito:

1. Releia a seção relevante com calma
2. Procure o erro no Google (é o que desenvolvedores fazem o tempo todo)
3. Consulte o arquivo `11-erros-comuns-e-correcoes.md` na raiz do projeto
4. Experimente no JShell para testar conceitos isolados

---

**Vamos começar! Abra o arquivo `01-fundamentos-java.md` e bora aprender Java!**
