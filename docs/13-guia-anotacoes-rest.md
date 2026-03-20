# Guia de anotacoes REST (conceito aprofundado)

Este guia responde tres perguntas para cada anotacao:
1. O que faz?
2. Por que usar?
3. O que quebra sem ela?

## `@RestController`
- Faz: registra classe como controller REST e retorna corpo HTTP direto.
- Por que: API precisa responder JSON/texto, nao view HTML.
- Sem ela: endpoint pode nao ser registrado corretamente para resposta REST.

## `@RequestMapping`
- Faz: define rota base da classe.
- Por que: organiza endpoints por recurso.
- Sem ela: repeticao de rota e maior chance de erro.

## `@GetMapping`
- Faz: mapeia metodo para GET.
- Por que: semantica de leitura.
- Sem ela: metodo nao atende GET.

## `@PostMapping`
- Faz: mapeia metodo para POST.
- Por que: semantica de criacao.
- Sem ela: nao ha endpoint de criacao.

## `@PutMapping`
- Faz: mapeia metodo para PUT.
- Por que: semantica de atualizacao.
- Sem ela: atualizacao fica mal definida na API.

## `@DeleteMapping`
- Faz: mapeia metodo para DELETE.
- Por que: semantica de remocao.
- Sem ela: API perde operacao de exclusao.

## `@PathVariable`
- Faz: captura valor da URL para parametro Java.
- Por que: identificar recurso alvo (`id`).
- Sem ela: metodo nao recebe o identificador da rota.

## `@RequestBody`
- Faz: converte JSON para objeto Java.
- Por que: trabalhar com objeto tipado.
- Sem ela: request body nao e mapeado automaticamente.

## `@Valid`
- Faz: ativa Bean Validation no objeto recebido.
- Por que: impedir dado invalido antes da regra de negocio.
- Sem ela: anotacoes de validacao nao executam.

## `@NotBlank`
- Faz: campo obrigatorio nao vazio.
- Por que: garantir dado minimo.
- Sem ela: campo vazio pode entrar no sistema.

## `@Email`
- Faz: valida formato de email.
- Por que: evitar dado mal formatado.
- Sem ela: qualquer texto passa como email.

## `ResponseEntity`
- Faz: controla status, headers e body explicitamente.
- Por que: resposta HTTP clara por cenario.
- Sem ela: controle de status pode ficar menos preciso.

## `@ResponseStatus`
- Faz: define status fixo para metodo.
- Por que: simplifica retorno quando regra e estavel.
- Sem ela: metodo retorna status padrao (geralmente 200).

## Fluxo REST completo
1. HTTP chega na rota.
2. Spring encontra metodo mapeado.
3. Converte JSON em objeto (`@RequestBody`).
4. Valida (`@Valid`).
5. Executa regra.
6. Retorna status + body.

## Perguntas de autoavaliacao
1. Quando usar `ResponseEntity` em vez de `@ResponseStatus`?
2. Qual diferenca pratica entre `@PathVariable` e `@RequestBody`?
3. O que acontece se remover `@Valid` mantendo `@NotBlank`?
