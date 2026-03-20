# Dia 2 - 22/03/2026 (Domingo, 4h)

Tema: logica + orientacao a objetos com foco nos 4 pilares.

## Objetivo do dia
1. usar estruturas de decisao e repeticao.
2. entender classe e objeto.
3. demonstrar encapsulamento, heranca, polimorfismo e abstracao.

## Conceito antes do codigo

### Classe vs objeto
- Classe: molde.
- Objeto: instancia concreta.

### Por que OO?
Para organizar sistema complexo em partes reutilizaveis e de facil manutencao.

---

## Bloco 1 - Logica de decisao (00:00-01:00)

```java
int nota = 7;
if (nota >= 6) {
    System.out.println("Aprovado");
} else {
    System.out.println("Reprovado");
}
```

### Por que `if/else`?
Para desviar fluxo conforme condicao.

---

## Bloco 2 - Repeticao (01:00-01:40)

```java
for (int i = 1; i <= 3; i++) {
    System.out.println(i);
}
```

### Por que repetir?
Porque evita duplicar codigo manualmente.

---

## Bloco 3 - 4 pilares com exemplos (01:40-03:10)

### Encapsulamento
```java
public class Cliente {
    private String nome;
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
}
```
Por que: proteger dado interno.

### Heranca
```java
public class Pessoa { protected String nome; }
public class Cliente extends Pessoa { }
```
Por que: reutilizar estrutura comum.

### Polimorfismo
```java
public interface Notificacao { void enviar(String msg); }
```
Por que: mesmo contrato com comportamentos diferentes.

### Abstracao
Focar no que faz, sem expor detalhes internos de como faz.

---

## Bloco 4 - Fixacao (03:10-03:45)
- N1: classe com encapsulamento.
- N2: heranca com sobrescrita.
- N3: interface com duas implementacoes.

## Bloco 5 - Revisao (03:45-04:00)
Perguntas:
1. por que `private` no encapsulamento?
2. quando heranca ajuda?
3. o que torna um caso polimorfico?

## Checklist
- [ ] logica basica validada.
- [ ] 4 pilares demonstrados em codigo.
- [ ] aluno explica cada pilar sem ler.
