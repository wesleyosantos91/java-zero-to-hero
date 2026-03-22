# Formação Java Zero to Hero
## Trilha Completa de Aprendizado — do Básico ao Spring Batch

> **Nível:** Iniciante ao Júnior/Pleno
> **Base:** Apostila Caelum + evolução profissional
> **Objetivo:** Formar um desenvolvedor Java capaz de construir sistemas completos com APIs REST e processamento batch em produção

---

## Sobre esta Formação

Esta formação foi construída sobre a base do material da Caelum (*Apostila Java e Orientação a Objetos*), amplamente reconhecida na comunidade Java brasileira, e foi **completamente reestruturada e expandida** para levar o estudante do zero absoluto até o desenvolvimento profissional com Spring Boot e Spring Batch integrado ao Oracle.

O material segue uma progressão rigorosa: **nunca avançamos sem solidificar o que veio antes**. Cada módulo começa com uma revisão e termina com exercícios e um projeto prático.

---

## Ordem de Estudo Obrigatória

```
MÓDULO 1 → MÓDULO 2 → MÓDULO 3 → MÓDULO 4 → MÓDULO 5 → MÓDULO 6
 Java OO     Oracle      JDBC     REST API   Spring Boot  Spring Batch
```

Não pule módulos. Cada etapa depende da anterior.

---

## Mapa da Formação

| # | Módulo | Tema Central | Pré-requisito |
|---|--------|-------------|---------------|
| 1 | [Java — Orientação a Objetos](./modulo-01-java-oo/README.md) | Fundamentos da linguagem + OOP | Nenhum |
| 2 | [Banco de Dados Relacional com Oracle](./modulo-02-banco-dados/README.md) | SQL, DDL, DML, modelagem | Módulo 1 |
| 3 | [Java + JDBC](./modulo-03-jdbc/README.md) | Acesso a dados com Java puro | Módulos 1 e 2 |
| 4 | [Fundamentos de REST API](./modulo-04-rest-api/README.md) | HTTP, verbos, JSON, boas práticas | Módulo 1 |
| 5 | [Spring Boot — CRUD e APIs](./modulo-05-spring-boot/README.md) | APIs REST completas com Spring | Módulos 1–4 |
| 6 | [Spring Batch](./modulo-06-spring-batch/README.md) | Processamento em lote arquivo ↔ Oracle | Módulos 1–5 |

---

## O que Você Vai Construir

Ao longo da formação, você vai construir **projetos reais e incrementais**:

1. **Módulo 1** — Sistema de cadastro de clientes em Java puro (console)
2. **Módulo 2** — Banco de dados de clientes no Oracle com scripts SQL completos
3. **Módulo 3** — CRUD em Java conectado ao Oracle via JDBC
4. **Módulo 4** — Documentação e testes de uma API REST (teoria + Postman/curl)
5. **Módulo 5** — API REST completa de gerenciamento de clientes com Spring Boot + Oracle
6. **Módulo 6** — Sistema de importação/exportação de dados em lote entre arquivo CSV e Oracle

Ao final, você terá um **portfólio funcional** com projetos encadeados e complementares.

---

## Metodologia de Estudo

### Como usar este material

Para cada tópico novo, siga este ciclo:

```
1. Leia a teoria        → entenda o conceito
2. Analise o exemplo    → veja como funciona
3. Reproduza o código   → escreva você mesmo, sem copiar
4. Faça o exercício     → aplique sem o gabarito
5. Revise o gabarito    → compare e corrija
6. Explique em voz alta → se não consegue explicar, ainda não entendeu
```

### Regras da Trilha

- **Não avance** sem concluir os exercícios do tópico anterior
- **Ao encontrar um erro**, tente resolver sozinho por 15 minutos antes de buscar ajuda
- **Revise** o módulo anterior antes de iniciar o próximo
- **Construa** todos os exemplos na mão — não copie e cole sem entender

---

## Ambiente de Desenvolvimento

Antes de começar, garanta que você tem instalado:

| Ferramenta | Versão Mínima | Para que serve |
|-----------|---------------|----------------|
| JDK (OpenJDK ou Oracle JDK) | 17+ | Compilar e executar Java |
| Maven | 3.8+ | Gerenciar dependências e build |
| IntelliJ IDEA ou VS Code | Qualquer | IDE para desenvolvimento |
| Docker Desktop | Qualquer | Subir Oracle localmente |
| DBeaver ou SQL Developer | Qualquer | Cliente de banco de dados |
| Postman ou Insomnia | Qualquer | Testar APIs REST |
| Git | 2.x+ | Controle de versão |

### Verificação do Ambiente

```bash
# Verifique cada ferramenta:
java -version        # Deve mostrar 17 ou superior
mvn -version         # Deve mostrar 3.8 ou superior
docker --version     # Qualquer versão recente
git --version        # Qualquer versão recente
```

---

## Estrutura de Cada Módulo

Cada módulo segue esta estrutura padrão:

```
modulo-XX-tema/
  README.md              ← Ementa, objetivos e visão geral
  01-introducao.md       ← Primeiro tópico com teoria e exemplos
  02-...md               ← Tópicos subsequentes
  ...
  XX-exercicios.md       ← Exercícios de fixação por tópico
  XX-projeto-pratico.md  ← Mini projeto ou desafio do módulo
```

---

## Referências e Base do Material

Este material foi construído com base em:

- **Apostila Java e Orientação a Objetos — Caelum** (referência pedagógica principal)
- Documentação oficial do Java (docs.oracle.com)
- Documentação oficial do Spring Framework (spring.io/docs)
- Documentação oficial do Spring Batch
- Boas práticas da comunidade Java (Effective Java — Joshua Bloch)
- Padrões de projeto e arquitetura limpa

---

## Checklist de Conclusão da Formação

Ao terminar os 6 módulos, você deve ser capaz de:

- [ ] Explicar e aplicar os 4 pilares da OO em Java
- [ ] Modelar e criar bancos de dados relacionais no Oracle
- [ ] Conectar Java a um banco de dados via JDBC sem frameworks
- [ ] Explicar os fundamentos de uma API REST
- [ ] Construir uma API REST completa com Spring Boot
- [ ] Implementar jobs de processamento em lote com Spring Batch
- [ ] Integrar todos os conceitos em um sistema coeso
- [ ] Diagnosticar e corrigir erros comuns em cada camada

---

*Bons estudos. O código que você vai escrever hoje é o produto que alguém vai usar amanhã.*
