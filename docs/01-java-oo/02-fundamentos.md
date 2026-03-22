# Módulo 1 — Fundamentos da Linguagem

## Ponte com tópico anterior
Agora que você executa Java, vamos construir lógica e estrutura para preparar OO.

## Variáveis e tipos primitivos
- **O que é:** espaço nomeado para guardar valores.
- **Por que existe:** manipular estado do programa.
- **Quando usar:** sempre que houver dado mutável ou referência.
- **Quando evitar:** variáveis desnecessárias e escopo amplo.
- **Internamente:** tipo define tamanho, faixa e operações permitidas.

## Condicionais e loops
- `if/else`: decisão por condição.
- `switch`: múltiplos casos.
- `for/while`: repetição controlada.

## Métodos
- **O que é:** bloco reutilizável com assinatura.
- **Problema que resolve:** duplicação e baixa legibilidade.

## Exemplo simples
```java
static int somar(int a, int b) { return a + b; }
```

## Exemplo aplicado
Cálculo de desconto com validação de entrada e retorno claro.

## Erros comuns
- Comparar `String` com `==`.
- Loop infinito por condição mal definida.
- Métodos gigantes com múltiplas responsabilidades.

## Boas práticas
- Preferir imutabilidade local quando possível.
- Retornos explícitos.
- Separar entrada/saída da regra de negócio.

## Fechamento
- **Resumo:** você domina blocos básicos para construir lógica limpa.
- **Checklist:** tipos, operadores, condicionais, loops e métodos.
- **Exercícios:** básico/intermediário/avançado no arquivo `exercicios.md`.
