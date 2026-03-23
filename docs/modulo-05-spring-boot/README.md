# Módulo 5 — Spring Boot: CRUD e REST APIs

## Visão Geral

Bem-vindo ao Módulo 5 do Java Zero to Hero! Este é o módulo mais prático e aplicado da trilha até agora. Aqui você vai sair do mundo teórico e construir uma API REST completa do zero, usando o ecossistema Spring Boot — o framework mais utilizado no mercado Java corporativo.

Se você completou os Módulos 1 a 4, você já sabe orientação a objetos, SQL, JDBC e os fundamentos do protocolo HTTP e REST. Agora é hora de juntar tudo isso em uma aplicação real, profissional, e pronta para o mercado.

Ao final deste módulo, você terá construído um CRUD completo de Clientes com API REST, persistência no Oracle Database (via Docker), validações de entrada, tratamento de erros padronizado, e uma estrutura de projeto que reflete as melhores práticas do mercado.

---

## O Que Você Vai Construir

Uma API REST de Gerenciamento de Clientes com os seguintes endpoints:

```
GET    /api/v1/clientes          → Lista todos os clientes (paginado)
GET    /api/v1/clientes/{id}     → Busca cliente por ID (404 se não existir)
POST   /api/v1/clientes          → Cadastra novo cliente (201 Created)
PUT    /api/v1/clientes/{id}     → Atualiza cliente completo
PATCH  /api/v1/clientes/{id}/status → Ativa ou desativa cliente
DELETE /api/v1/clientes/{id}     → Remove cliente (204 No Content)
```

Tecnologias: Spring Boot 3.x + Java 17 + Spring Data JPA + Oracle + Bean Validation

---

## Ementa

| # | Arquivo | Tópico Principal | Subtópicos |
|---|---------|-----------------|------------|
| 1 | `01-introducao-spring.md` | Fundamentos do Spring Boot | IoC, DI, Beans, Auto-configuration, Spring Initializr, estrutura de projeto |
| 2 | `02-controllers-e-endpoints.md` | Controllers e Endpoints REST | @RestController, @GetMapping, @PostMapping, ResponseEntity, curl, Postman |
| 3 | `03-services-e-repositorios.md` | Camadas de Serviço e Repositório | @Service, @Repository, Spring Data JPA, JpaRepository, @Entity, Query Methods |
| 4 | `04-dtos-validacao-e-erros.md` | DTOs, Validação e Tratamento de Erros | Bean Validation, @Valid, @ControllerAdvice, exceções customizadas |
| 5 | `05-crud-completo.md` | CRUD Completo — Projeto Final | Código completo de todos os arquivos, testes com curl, desafios de extensão |

---

## Objetivos de Aprendizagem

Ao concluir este módulo, você será capaz de:

### Conhecimento (Saber)
- Explicar o que é o Spring Framework e por que o Spring Boot foi criado
- Descrever o conceito de Inversão de Controle (IoC) e Injeção de Dependência (DI) com suas próprias palavras
- Identificar o papel de cada camada na arquitetura Controller → Service → Repository
- Explicar o que é JPA e como o Spring Data JPA simplifica o acesso ao banco de dados
- Descrever para que servem os DTOs e por que não se deve expor entidades JPA diretamente
- Listar as anotações de validação do Bean Validation e quando usar cada uma

### Habilidade (Saber Fazer)
- Gerar um projeto Spring Boot completo com o Spring Initializr
- Criar endpoints REST com todos os verbos HTTP (GET, POST, PUT, PATCH, DELETE)
- Retornar respostas com os status codes corretos usando ResponseEntity
- Configurar conexão com Oracle Database no `application.yml`
- Implementar um repositório JPA com métodos de busca customizados
- Criar classes DTO separadas para request e response
- Aplicar validações de campo com Bean Validation
- Implementar um tratador de erros global com @ControllerAdvice
- Testar todos os endpoints com curl e Postman

### Atitude (Ser)
- Desenvolver o hábito de separar responsabilidades em camadas desde o início
- Nunca expor detalhes internos de implementação na API (entidades, stack traces)
- Validar toda entrada de dados antes de persistir
- Retornar mensagens de erro claras e padronizadas

---

## Pré-requisitos

Antes de iniciar este módulo, você deve ter concluído:

| Módulo | O que você precisará usar aqui |
|--------|-------------------------------|
| **Módulo 1** — Java e OO | Classes, herança, interfaces, generics, coleções |
| **Módulo 2** — Banco de Dados SQL | DDL (CREATE TABLE), DML (INSERT/SELECT/UPDATE/DELETE), tipos de dados Oracle |
| **Módulo 3** — JDBC | Entender como Java se conecta a bancos de dados (o Spring Data JPA abstrai isso, mas o conceito é fundamental) |
| **Módulo 4** — REST API | HTTP, verbos, status codes, JSON, design de URIs |

Se você pulou algum desses módulos, considere revisá-los antes de continuar. O Spring Boot simplifica muito, mas não substitui o entendimento dos fundamentos.

### Verificação Rápida de Pré-requisitos

Antes de começar, responda mentalmente:
- [ ] Você consegue criar uma classe Java com getters/setters sem ajuda?
- [ ] Você entende o que é uma interface e como implementá-la?
- [ ] Você sabe o que o comando `SELECT * FROM tabela WHERE id = ?` faz?
- [ ] Você sabe a diferença entre GET e POST? Entre 200 e 404?
- [ ] Você já abriu o Docker e rodou o Oracle Database?

Se respondeu "sim" a todos, está pronto para começar!

---

## Ferramentas Necessárias

Certifique-se de ter instalado e configurado:

| Ferramenta | Versão Mínima | Para Que Serve |
|-----------|---------------|----------------|
| JDK | 17 ou superior | Compilar e rodar Java |
| Maven | 3.8+ (ou use o wrapper do projeto) | Gerenciar dependências e build |
| IntelliJ IDEA | Community ou Ultimate | IDE (recomendada) |
| Docker Desktop | Qualquer versão recente | Rodar o Oracle Database |
| Oracle XE 21c (Docker) | 21c | Banco de dados |
| Postman ou Insomnia | Qualquer versão recente | Testar a API graficamente |
| curl | Disponível no terminal | Testar a API pela linha de comando |

### Como verificar se o Java está instalado:
```bash
java -version
# Esperado: openjdk version "17.x.x" ou superior

javac -version
# Esperado: javac 17.x.x
```

### Como subir o Oracle no Docker:
```bash
# Se ainda não tem a imagem:
docker pull container-registry.oracle.com/database/express:21.3.0-xe

# Subir o container:
docker run -d \
  --name oracle-xe \
  -p 1521:1521 \
  -e ORACLE_PWD=oracle123 \
  container-registry.oracle.com/database/express:21.3.0-xe

# Verificar se está rodando:
docker ps
```

---

## Estrutura de Arquivos do Módulo

```
modulo-05-spring-boot/
├── README.md                          ← Este arquivo (visão geral e orientação)
├── 01-introducao-spring.md            ← Teoria: Spring, IoC, DI, Spring Boot
├── 02-controllers-e-endpoints.md      ← Prática: criando endpoints REST
├── 03-services-e-repositorios.md      ← Prática: camadas de serviço e JPA
├── 04-dtos-validacao-e-erros.md       ← Prática: DTOs, validação, error handling
├── 05-crud-completo.md                ← Projeto final: CRUD completo com todos os arquivos
└── exercicios.md                      ← 27 exercícios + desafio de API Produtos/Categorias
```

---

## Roteiro de Estudo Recomendado

Este módulo pode ser concluído em **5 a 7 dias de estudo**, dedicando de 2 a 3 horas por dia.

### Dia 1: Fundamentos (01-introducao-spring.md)
- Leia a teoria sobre IoC e DI com atenção — esse conceito muda a forma como você pensa em código
- Gere um projeto com o Spring Initializr e explore cada arquivo
- Rode o projeto pela primeira vez e veja o banner do Spring no console

### Dia 2: Controllers (02-controllers-e-endpoints.md)
- Crie seu primeiro endpoint GET e teste com curl
- Implemente endpoints com parâmetros de path e query
- Pratique com Postman

### Dia 3: Services e Repositórios (03-services-e-repositorios.md)
- Crie uma entidade JPA simples
- Implemente um repositório e um service
- Teste a persistência no banco

### Dia 4: DTOs e Validação (04-dtos-validacao-e-erros.md)
- Crie DTOs separados para request e response
- Adicione validações com Bean Validation
- Implemente o tratador de erros global

### Dia 5-7: Projeto Final (05-crud-completo.md)
- Implemente o CRUD completo de Clientes
- Teste cada endpoint com curl
- Tente os desafios de extensão

---

## Convenções Usadas neste Módulo

Para manter consistência, adotamos as seguintes convenções em todos os exemplos:

| Convenção | Exemplo |
|-----------|---------|
| Pacote base | `br.com.empresa.clientes` |
| Entidade de exemplo | `Cliente` |
| Tabela no banco | `TB_CLIENTES` |
| Endpoint base | `/api/v1/clientes` |
| Porta da aplicação | `8080` |
| Usuário Oracle | `SYSTEM` |
| Senha Oracle | `oracle123` |
| Host Oracle | `localhost:1521` |
| Service Oracle | `XEPDB1` |

---

## Checklist de Conclusão do Módulo

Use esta lista para verificar seu progresso. Só marque quando conseguir fazer sem consultar a solução:

### Conceitos Teóricos
- [ ] Consigo explicar IoC e DI com minhas próprias palavras e um exemplo do dia a dia
- [ ] Sei a diferença entre @Component, @Service, @Repository e @Controller
- [ ] Entendo o que o `@SpringBootApplication` faz por baixo dos panos
- [ ] Sei quando usar @PathVariable versus @RequestParam
- [ ] Entendo a diferença entre Entity e DTO e por que isso importa
- [ ] Sei quais status codes usar para cada situação (200, 201, 204, 400, 404, 409, 500)

### Habilidades Práticas
- [ ] Gerei um projeto com Spring Initializr e o fiz rodar na minha máquina
- [ ] Criei um endpoint GET que retorna uma lista de objetos como JSON
- [ ] Criei um endpoint POST que recebe um JSON no body e persiste no banco
- [ ] Criei um endpoint PUT que atualiza um recurso existente
- [ ] Criei um endpoint DELETE que remove um recurso
- [ ] Configurei a conexão com o Oracle no application.yml
- [ ] Implementei um @ControllerAdvice que trata erros de validação e retorna JSON formatado
- [ ] Testei todos os endpoints com curl ou Postman

### Projeto Final
- [ ] CRUD completo de Clientes funcionando com Oracle
- [ ] GET /clientes retorna lista paginada
- [ ] GET /clientes/{id} retorna 404 quando não encontrado
- [ ] POST /clientes retorna 201 com o recurso criado
- [ ] PUT /clientes/{id} atualiza corretamente
- [ ] DELETE /clientes/{id} retorna 204
- [ ] Validações retornam 400 com mensagens claras
- [ ] Tratamento de erros global implementado

---

## Dúvidas Frequentes Antes de Começar

**"Preciso saber tudo sobre Spring antes de começar?"**
Não. Este módulo foi desenhado para introduzir Spring Boot de forma progressiva. Você aprenderá fazendo.

**"Posso usar MySQL em vez de Oracle?"**
Sim, conceitualmente tudo funciona igual. Mas o módulo foi calibrado para Oracle porque é o mais utilizado em ambientes corporativos Java no Brasil. Recomendamos seguir com Oracle.

**"O IntelliJ Community funciona para este módulo?"**
Sim. O IntelliJ IDEA Community Edition tem suporte completo a Spring Boot, Java e Maven. A versão Ultimate adiciona suporte a JPA (mapeamento visual de entidades), mas não é obrigatória.

**"Preciso entender XML para usar Maven?"**
Não precisa ser especialista. O `pom.xml` que fornecemos está comentado e explicado. Você copiará e entenderá os pontos importantes.

---

## Por Onde Começar?

Vá para o primeiro arquivo: **[01-introducao-spring.md](./01-introducao-spring.md)**

Boa jornada!
