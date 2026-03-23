# Como Usar Este Material

## Para Quem é Este Material

Este repositório é uma formação completa de Java em português, projetada para quem:
- Nunca programou antes **ou**
- Já programa em outra linguagem e quer aprender Java com foco em backend corporativo

Ao final você estará apto a trabalhar com Spring Boot e Spring Batch em ambientes com Oracle Database.

---

## Estrutura da Formação

A formação é dividida em **6 módulos sequenciais**. Cada módulo tem:
- Um `README.md` com ementa, objetivos e checklist de conclusão
- Tópicos numerados com teoria, código completo e exemplos reais
- Exercícios em 3 níveis: Básico, Intermediário e Avançado
- Um projeto prático integrando todos os conceitos do módulo

```
docs/
├── modulo-01-java-oo/       ← Comece aqui
├── modulo-02-banco-dados/
├── modulo-03-jdbc/
├── modulo-04-rest-api/
├── modulo-05-spring-boot/
└── modulo-06-spring-batch/  ← Conclua aqui
```

---

## Ordem de Estudo

**Nunca pule módulos.** A formação é progressiva:

| Etapa | O que você aprende | Onde encontrar |
|-------|-------------------|----------------|
| 1 | Java OO — fundamentos, classes, herança, coleções | [`modulo-01-java-oo/`](modulo-01-java-oo/README.md) |
| 2 | Oracle SQL — DDL, DML, JOINs, modelagem | [`modulo-02-banco-dados/`](modulo-02-banco-dados/README.md) |
| 3 | JDBC — conectar Java ao Oracle, DAO pattern | [`modulo-03-jdbc/`](modulo-03-jdbc/README.md) |
| 4 | REST API — HTTP, verbos, JSON, boas práticas | [`modulo-04-rest-api/`](modulo-04-rest-api/README.md) |
| 5 | Spring Boot 3 — APIs REST com JPA e validação | [`modulo-05-spring-boot/`](modulo-05-spring-boot/README.md) |
| 6 | Spring Batch — importação e exportação em lote | [`modulo-06-spring-batch/`](modulo-06-spring-batch/README.md) |

---

## Método de Estudo Recomendado

Para cada tópico, siga este ciclo:

```
1. LER    → leia o conteúdo teórico até o final
2. DIGITAR → digite os exemplos na IDE (não copie e cole)
3. EXECUTAR → rode o código e observe o resultado
4. EXPERIMENTAR → modifique o código e veja o que muda
5. PRATICAR → faça os exercícios (Básico → Intermediário → Avançado)
```

### Por que digitar em vez de copiar?

Digitar obriga você a prestar atenção em cada caractere, tipo e anotação. Erros de digitação são aliados — eles ensinam o que cada parte do código faz quando está presente ou ausente.

---

## Os Três Níveis de Exercícios

Cada tópico termina com exercícios em três níveis:

| Nível | O que é | Obrigatoriedade |
|-------|---------|-----------------|
| **Básico** | Reprodução direta do que foi ensinado com pequena variação | Obrigatório — não avance sem completar |
| **Intermediário** | Aplicação combinando conceitos do tópico e anteriores | Fortemente recomendado |
| **Avançado** | Desafio de autonomia que vai além do conteúdo explícito | Opcional — para quem quer mais |

### Regra de Progresso

> Não avance para o próximo tópico sem conseguir fazer o nível Básico **e** explicar com suas próprias palavras o que o código faz e por que existe.

---

## As Três Perguntas

Ao final de cada bloco de conteúdo, responda mentalmente:

1. **O que isso faz?** — descreva o comportamento
2. **Por que isso existe?** — qual problema resolve
3. **O que acontece se eu remover essa parte?** — teste e descubra

---

## Configuração do Ambiente

Antes de iniciar o Módulo 1:

```bash
# Verificar Java 21+
java -version

# Verificar Maven 3.9+
mvn -version

# Verificar Docker (necessário a partir do Módulo 2)
docker --version
```

**IDE recomendada:** IntelliJ IDEA Community Edition (gratuito)
**Alternativa:** VS Code com extensão "Extension Pack for Java"

### Oracle via Docker (necessário a partir do Módulo 2)

```bash
# Na raiz do repositório
docker compose -f docker/docker-compose.oracle.yml up -d

# Aguardar ~60 segundos e checar
docker logs oracle-xe | grep "DATABASE IS READY"
```

---

## Quando Travar

1. **Releia** a seção onde travou — lentamente, linha por linha
2. **Isole** o problema: qual linha ou conceito está confuso?
3. **Pesquise** o erro exato no Google — é o que desenvolvedores fazem diariamente
4. **Experimente** no código: teste hipóteses removendo e adicionando partes
5. **Revise** o módulo anterior — o problema pode estar em um conceito anterior

---

## Sobre o Projeto Prático de Cada Módulo

Cada módulo culmina em um projeto prático que integra tudo que foi aprendido:

| Módulo | Projeto |
|--------|---------|
| 1 — Java OO | Sistema de Gerenciamento de Biblioteca (console) |
| 2 — Oracle SQL | Schema completo de e-commerce com scripts SQL |
| 3 — JDBC | CRUD de Clientes conectado ao Oracle |
| 4 — REST API | Documentação e design de uma API REST |
| 5 — Spring Boot | API REST de Clientes com Spring Boot + JPA |
| 6 — Spring Batch | Sistema de processamento de pedidos (CSV ↔ Oracle) |

O projeto do Módulo 5 evolui naturalmente para o Módulo 6 — você adicionará processamento batch à API que construiu.

---

**Pronto para começar? Abra [`modulo-01-java-oo/README.md`](modulo-01-java-oo/README.md) e vamos nessa.**
