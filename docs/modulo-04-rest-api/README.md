# Módulo 4 — Fundamentos de REST API

## Visão Geral

Bem-vindo ao Módulo 4 do **Java Zero to Hero**! Este módulo é um divisor de águas na sua jornada como desenvolvedor: aqui você aprenderá os fundamentos teóricos e práticos das APIs REST, o padrão de comunicação dominante na web moderna.

Antes de escrever uma linha de código Spring Boot, é fundamental entender o protocolo que sustenta tudo isso: o HTTP. Muitos desenvolvedores pulam essa etapa e depois enfrentam dificuldades ao depurar problemas de CORS, status codes errados, ou endpoints mal projetados. Aqui você não vai pular.

Este módulo é predominantemente **teórico e conceitual**, mas repleto de exemplos práticos com `curl`. A implementação em Java Spring Boot vem no Módulo 5 — e quando você chegar lá, já vai entender o "porquê" de cada decisão de design.

---

## Ementa Completa

| # | Arquivo | Tópico | Conteúdo Principal |
|---|---------|--------|--------------------|
| 1 | `01-fundamentos-http.md` | Fundamentos HTTP | Protocolo, requisição, resposta, métodos, status codes, curl |
| 2 | `02-rest-e-restful.md` | REST e RESTful | Princípios REST, 6 restrições, Modelo de Maturidade de Richardson |
| 3 | `03-json-e-payload.md` | JSON e Payload | Sintaxe JSON, path params, query params, body, paginação |
| 4 | `04-boas-praticas-e-design.md` | Boas Práticas e Design | Versionamento, erros, autenticação, CORS, documentação |
| 5 | `05-exercicios-e-revisao.md` | Exercícios e Revisão | 20+ exercícios, gabarito comentado, mapa mental |

---

## Objetivos de Aprendizagem

Ao concluir este módulo, você será capaz de:

### Conhecimento (Saber)
- Explicar o funcionamento do protocolo HTTP com clareza e precisão
- Identificar todos os grupos de status codes e seus significados semânticos
- Descrever as 6 restrições do REST e justificar por que cada uma existe
- Diferenciar os quatro níveis do Modelo de Maturidade de Richardson
- Explicar o que é idempotência e sua importância em sistemas distribuídos
- Descrever os tipos de parâmetros em APIs REST (path, query, body)
- Compreender os conceitos de autenticação JWT, CORS e rate limiting

### Habilidade (Saber Fazer)
- Ler e interpretar requisições e respostas HTTP brutas (sem framework)
- Analisar e identificar problemas em URIs mal projetadas
- Escrever e interpretar JSON válido sem auxílio de ferramentas
- Usar `curl` para testar qualquer endpoint REST manualmente
- Projetar conjuntos completos de endpoints CRUD seguindo as convenções REST
- Identificar o status code correto para diferentes situações de erro ou sucesso
- Formatar payloads de requisição e resposta corretamente

### Atitude (Ser)
- Desenvolver o hábito de verificar status codes antes de assumir sucesso ou falha
- Adotar nomenclatura consistente e semântica desde o início de projetos
- Questionar decisões de design de API com embasamento técnico e argumentação clara
- Documentar decisões de design para que outros desenvolvedores entendam o raciocínio

---

## Pré-requisitos

### Módulos Anteriores
Antes de iniciar este módulo, você deve ter concluído:

- **Módulo 1** — Fundamentos de Java e Orientação a Objetos
- **Módulo 2** — Banco de Dados e SQL
- **Módulo 3** — JDBC e Persistência de Dados

Conhecimento esperado:
- Programação básica em Java (classes, métodos, variáveis)
- Conceito de cliente e servidor (mesmo que superficial)
- Uso básico do terminal / linha de comando

### Ferramentas Necessárias

| Ferramenta | Obrigatório | Como verificar |
|-----------|-------------|----------------|
| `curl` | Sim | `curl --version` |
| Terminal | Sim | — |
| Conexão à internet | Sim (exercícios) | — |
| VS Code ou editor | Recomendado | — |
| Postman ou Insomnia | Opcional | — |

Para verificar se o curl está disponível no seu sistema:
```bash
curl --version
# Saída esperada: curl 7.x.x (linux-gnu) libcurl/7.x.x ...
```

Se o curl não estiver instalado:
```bash
# Ubuntu/Debian
sudo apt-get install curl

# macOS (via Homebrew)
brew install curl

# Windows: usar Git Bash ou WSL
```

---

## Estrutura do Módulo

```
modulo-04-rest-api/
├── README.md                    ← Este arquivo (visão geral, ementa, checklist)
├── 01-fundamentos-http.md       ← HTTP: o protocolo base de tudo
├── 02-rest-e-restful.md         ← REST: princípios, restrições e arquitetura
├── 03-json-e-payload.md         ← JSON, parâmetros e estrutura de dados
├── 04-boas-praticas-e-design.md ← Como projetar APIs profissionais
├── 05-exercicios-e-revisao.md   ← Revisão completa com mapa mental
└── exercicios.md                ← 19 exercícios + desafio de design de API
```

### Como Estudar Este Módulo

Siga rigorosamente a ordem dos arquivos. Cada um constrói sobre o anterior:

**Passo 1 — `01-fundamentos-http.md`**
Leia com calma. Execute cada exemplo de `curl` no seu terminal. Não copie e cole sem entender o que cada flag significa. Repita os exemplos variando os parâmetros.

**Passo 2 — `02-rest-e-restful.md`**
Leitura mais conceitual. Tente responder as perguntas de reflexão ANTES de ler as respostas. Desenhe o Modelo de Maturidade em um papel.

**Passo 3 — `03-json-e-payload.md`**
Pratique escrevendo JSON na mão. Use o [jsonlint.com](https://jsonlint.com) para validar seus JSONs. Tente criar erros intencionalmente para ver as mensagens de erro.

**Passo 4 — `04-boas-praticas-e-design.md`**
Salve este arquivo como referência permanente. Você voltará aqui durante projetos futuros. Leia com atenção especial a seção de CORS — é um dos erros mais frustrantes para iniciantes.

**Passo 5 — `05-exercicios-e-revisao.md`**
Faça os exercícios **ANTES** de ver o gabarito. Reserve pelo menos 2 horas para esta seção. Anote seus erros e releia as seções correspondentes.

**Tempo estimado total:** 8 a 12 horas de estudo focado.

---

## Mapa de Conceitos do Módulo

```
┌─────────────────────────────────────────────────────────────┐
│                    MÓDULO 4 — REST API                      │
└─────────────────────────────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
   HTTP (Protocolo)    REST (Estilo)     JSON (Formato)
          │                 │                 │
   ┌──────┴──────┐   ┌──────┴──────┐   ┌─────┴──────┐
   │ Requisição  │   │ 6 Restrições│   │   Sintaxe  │
   │ - Método    │   │ - Stateless │   │   Tipos    │
   │ - URL       │   │ - Cacheable │   │   Payloads │
   │ - Headers   │   │ - Uniform   │   └─────┬──────┘
   │ - Body      │   │   Interface │         │
   └──────┬──────┘   └──────┬──────┘   ┌─────┴──────┐
          │                 │           │ Parâmetros │
   ┌──────┴──────┐   ┌──────┴──────┐   │ - Path     │
   │  Resposta   │   │ Richardson  │   │ - Query    │
   │ - Status    │   │ Maturity    │   │ - Body     │
   │ - Headers   │   │ Model       │   └────────────┘
   │ - Body      │   │ Nível 0-3   │
   └─────────────┘   └─────────────┘
          │
   ┌──────┴──────────────────────────────┐
   │           BOAS PRÁTICAS             │
   │ Versionamento | Erros | Auth | CORS │
   └─────────────────────────────────────┘
```

---

## Checklist de Conclusão do Módulo

Use esta lista para acompanhar seu progresso. Marque cada item **somente quando sentir que realmente domina o conceito** — não apenas quando tiver lido.

### Fundamentos HTTP
- [ ] Consigo explicar o ciclo requisição-resposta HTTP com minhas próprias palavras
- [ ] Sei identificar cada parte de uma URL complexa (protocolo, host, porta, path, query, fragment)
- [ ] Conheço todos os métodos HTTP principais e sei quando usar cada um
- [ ] Sei a diferença entre métodos idempotentes e não-idempotentes e consigo dar exemplos
- [ ] Consigo interpretar qualquer status code pela sua categoria (1xx, 2xx, 3xx, 4xx, 5xx)
- [ ] Sei o significado específico de: 200, 201, 204, 400, 401, 403, 404, 409, 422, 500
- [ ] Executei pelo menos 5 comandos `curl` diferentes no terminal com sucesso
- [ ] Sei a diferença prática entre HTTP e HTTPS e por que HTTPS importa
- [ ] Conheço os headers HTTP mais importantes e suas funções

### REST e RESTful
- [ ] Consigo citar e explicar as 6 restrições do REST sem consultar o material
- [ ] Sei o que é "stateless" e por que isso é crucial para escalabilidade
- [ ] Conheço os 4 níveis do Modelo de Maturidade de Richardson com exemplos
- [ ] Sei identificar uma URI mal projetada e propor uma correção fundamentada
- [ ] Entendo a diferença entre "recurso" e "endpoint" e consigo explicar isso para alguém
- [ ] Sei o que é HATEOAS e por que raramente é implementado completamente

### JSON e Payload
- [ ] Consigo escrever JSON válido sem precisar de autocomplete ou ferramentas
- [ ] Sei quando usar path parameter vs query parameter e consigo justificar a escolha
- [ ] Entendo quando usar body em requisições e quais métodos tipicamente têm body
- [ ] Sei implementar paginação básica em um design de API REST
- [ ] Corrigi pelo menos 3 erros comuns em JSONs inválidos propositalmente errados
- [ ] Sei a diferença entre `camelCase`, `snake_case` e `PascalCase` em JSONs

### Boas Práticas e Design
- [ ] Sei por que e como versionar uma API (pelo menos 2 estratégias)
- [ ] Conheço e consigo replicar o formato padrão de resposta de erro
- [ ] Entendo o conceito de JWT sem precisar implementar (o que é, como funciona)
- [ ] Sei o que é CORS, por que o erro acontece e como ele é resolvido
- [ ] Projetei pelo menos um conjunto completo de endpoints CRUD para um recurso
- [ ] Sei a diferença entre autenticação e autorização

### Exercícios Práticos
- [ ] Completei todos os exercícios teóricos do arquivo 05
- [ ] Testei uma API pública com `curl` com sucesso
- [ ] Projetei endpoints para pelo menos 2 cenários propostos nos exercícios
- [ ] Conferi o gabarito e entendi todos os erros que cometi
- [ ] Consegui executar corretamente um GET, POST, PUT, PATCH e DELETE com curl

---

## Por Que Este Módulo Existe?

Muitos cursos de Java pulam direto para Spring Boot sem explicar o protocolo HTTP que está por baixo. O resultado é um desenvolvedor que copia anotações (`@GetMapping`, `@PostMapping`) sem entender o que elas representam.

Quando algo dá errado — e sempre dá — esse desenvolvedor fica perdido porque não tem o modelo mental para depurar. Por que o front-end está recebendo erro 403 e não 401? Por que meu DELETE retorna 200 mas devia retornar 204? Por que o CORS bloqueia minha requisição local?

Este módulo responde essas perguntas **antes** de você precisar se fazer delas em produção.

---

## Recursos Complementares

### Documentação e Referências
- [MDN Web Docs — HTTP](https://developer.mozilla.org/pt-BR/docs/Web/HTTP) — A referência mais completa sobre HTTP (disponível em português)
- [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110) — Especificação oficial HTTP Semantics (inglês, avançado)
- [Dissertação de Roy Fielding](https://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm) — O texto original que definiu REST

### Ferramentas Online
- [JSONLint](https://jsonlint.com/) — Validador e formatador de JSON online
- [Postman](https://www.postman.com/) — Cliente REST com interface gráfica
- [HTTPie](https://httpie.io/) — Alternativa ao curl, mais legível
- [ReqBin](https://reqbin.com/) — Testar requests HTTP diretamente no navegador
- [httpstat.us](https://httpstat.us/) — API que retorna qualquer status code (ótima para testes)

### Artigos Complementares
- [Richardson Maturity Model — Martin Fowler](https://martinfowler.com/articles/richardsonMaturityModel.html)
- [HTTP Status Codes Cheatsheet](https://www.restapitutorial.com/httpstatuscodes.html)
- [Best Practices for REST API Design — Stack Overflow Blog](https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/)

---

## Próximo Módulo

Após concluir este módulo e marcar todos os itens do checklist, você estará pronto para o **Módulo 5 — Spring Boot REST API**.

No Módulo 5 você implementará na prática tudo que aprendeu aqui:
- Criando controllers com `@RestController`
- Mapeando rotas com `@GetMapping`, `@PostMapping`, etc.
- Retornando JSON com os status codes corretos
- Tratando erros com `@ExceptionHandler` e `@ControllerAdvice`
- Validando payloads com Bean Validation

O conhecimento deste módulo é o alicerce. O Módulo 5 é a construção.

---

*Módulo 4 do Java Zero to Hero — Fundamentos de REST API*
*Atualizado em: Março de 2026*
