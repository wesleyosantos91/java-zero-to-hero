# Dia 1 - 21/03/2026 (Sabado, 4h)

Tema: setup do ambiente + primeiro programa Java + fundamentos basicos.

## Objetivo do dia
1. entender JDK, JRE e JVM com clareza.
2. instalar e validar Java.
3. criar e executar `HelloWorld`.
4. entender tipos e variaveis.

## Conceito antes do codigo

### O que e JDK?
Conjunto de ferramentas para desenvolver Java (inclui compilador `javac`).

### O que e JRE?
Ambiente para executar aplicacoes Java.

### O que e JVM?
Maquina virtual que executa bytecode Java.

### Por que isso importa?
Porque sem distinguir essas tres partes, o aluno nao entende erros de ambiente.

---

## Bloco 1 - Validacao do ambiente (00:00-00:40)

```powershell
java -version
javac -version
```

### Resultado esperado
- ambos os comandos devem responder versao.

### Erro comum
- `java nao reconhecido`: PATH nao configurado.

---

## Bloco 2 - Primeiro codigo (00:40-01:30)

Criar `HelloWorld.java`:
```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Ola, Java!");
    }
}
```

Compilar e executar:
```powershell
javac HelloWorld.java
java HelloWorld
```

### Por que existe `main`?
Porque e o ponto de entrada do programa.
Sem `main`, a JVM nao sabe por onde comecar.

### Por que `System.out.println`?
Porque imprime texto no console para validar comportamento.

---

## Bloco 3 - Tipos e variaveis (01:30-02:20)

```java
public class TiposBasicos {
    public static void main(String[] args) {
        String nome = "Ana";
        int idade = 19;
        double media = 8.5;
        boolean ativo = true;

        System.out.println(nome);
        System.out.println(idade);
        System.out.println(media);
        System.out.println(ativo);
    }
}
```

### Conceito
- `String`: texto.
- `int`: inteiro.
- `double`: decimal.
- `boolean`: verdadeiro/falso.

### Por que tipagem importa?
Porque define operacoes validas e previne erro de dado.

---

## Bloco 4 - Fixacao (02:20-03:30)
- N1: PerfilAluno.
- N2: Calculadora simples.
- N3: mini menu com `if/else`.

## Bloco 5 - Revisao (03:30-04:00)
Perguntas:
1. diferenca entre JDK e JRE?
2. funcao do `main`?
3. por que tipo de variavel importa?

## Checklist
- [ ] Java validado.
- [ ] HelloWorld rodando.
- [ ] Tipos explicados com exemplo.
- [ ] N1 concluido.
