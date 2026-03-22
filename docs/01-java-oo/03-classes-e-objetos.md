# Módulo 1 — Classes, Objetos e OO Completa

## Revisão estruturada
Você já controla lógica procedural; agora entra o paradigma OO para modelar domínio real.

## Classe e objeto
- **O que é:** classe é molde; objeto é instância.
- **Por que existe:** representar entidades e comportamentos.
- **Problema que resolve:** código acoplado à lógica procedural sem modelo de domínio.
- **Quando usar:** sempre que houver entidades com estado e comportamento.
- **Quando evitar:** utilitários triviais podem ser estáticos.
- **Como funciona:** atributos armazenam estado; métodos operam estado.

## Encapsulamento e acesso
Use `private` para proteger invariantes e exponha comportamento com métodos.

## Herança, abstração, interface e polimorfismo
- Herança: reuso estrutural com cuidado.
- Interface: contrato de comportamento.
- Classe abstrata: base parcial.
- Polimorfismo: trocar implementação sem alterar cliente.

## Sobrescrita vs sobrecarga
- Sobrescrita: mesma assinatura em subclasse.
- Sobrecarga: mesmo nome com parâmetros diferentes.

## Composição e agregação
Prefira composição para evitar hierarquias rígidas.

## Exceções, arrays e collections
- Trate falhas esperadas com validação.
- Use `try-catch` para exceções recuperáveis.
- Prefira `List` sobre array para coleções dinâmicas.

## Exemplo aplicado
```java
interface Tributavel { double calcularImposto(); }

class Produto implements Tributavel {
    private String nome;
    private double preco;
    @Override
    public double calcularImposto() { return preco * 0.1; }
}
```

## Erros clássicos de iniciantes em Java
1. Tudo `public`.
2. Uso excessivo de `static`.
3. Herança onde composição seria melhor.
4. Ignorar `NullPointerException`.
5. Misturar regra de negócio com `System.out`.

## Boas práticas para código legível
- Nomes expressivos.
- Uma responsabilidade por classe.
- Métodos curtos e coesos.
- Evitar comentários redundantes.
- Organizar pacotes por domínio.

## Fechamento
- **Resumo:** OO organiza código para evoluir com menor acoplamento.
- **Pontos de atenção:** escolha de abstrações e proteção de invariantes.
- **Checklist:** classe/objeto, encapsulamento, herança, interfaces, exceções, collections.
- **Exercícios:**
  - Básico: classe `Conta` com depósito/saque.
  - Intermediário: hierarquia `Funcionario` com polimorfismo.
  - Avançado: carrinho com composição + interface de desconto.
