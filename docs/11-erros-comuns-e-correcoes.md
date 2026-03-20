# Erros comuns e correcoes rapidas

## 1) `java` nao reconhecido
Causa: Java fora do PATH.
Correcao:
1. reinstalar Java 21.
2. reabrir terminal.
3. validar `java -version`.

## 2) `mvn` nao reconhecido
Causa: Maven fora do PATH.
Correcao:
1. instalar Maven.
2. reabrir terminal.
3. validar `mvn -version`.

## 3) Oracle nao sobe no Docker
Causa: porta ocupada ou recurso insuficiente.
Correcao:
1. `docker ps -a`.
2. `docker logs oracle-free-capacitacao`.
3. liberar porta 1521 e tentar novamente.

## 4) Erro de conexao JDBC
Causa: URL, usuario ou senha incorretos.
Correcao no `application.yml`:
- `jdbc:oracle:thin:@localhost:1521/FREEPDB1`
- `app_user`
- `app_password`

## 5) POST retorna 400
Causa: payload invalido.
Correcao:
1. conferir JSON.
2. conferir campos obrigatorios.
3. conferir formato de email.

## 6) `GET /clientes/{id}` retorna 404
Causa: id nao existe.
Correcao:
1. criar registro com POST.
2. usar id retornado no POST.

## 7) Job Batch nao executa
Causa: conflito de parametros ou erro de caminho.
Correcao:
1. usar timestamp em JobParameters.
2. validar caminhos de input/output.

## 8) Export nao gera arquivo
Causa: pasta `output` ausente.
Correcao:
1. criar `output`.
2. disparar export novamente.

## 9) Arquivo CSV em formato invalido
Causa: cabecalho/colunas divergentes.
Correcao:
1. ajustar cabecalho conforme aula.
2. separar colunas por virgula.

## 10) Aluno roda mas nao entende
Causa: estudo focado em copiar.
Correcao:
1. pausar execucao.
2. explicar linha por linha.
3. refazer N1 com verbalizacao.
