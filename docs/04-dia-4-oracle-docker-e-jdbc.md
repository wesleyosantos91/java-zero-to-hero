# Dia 4 - 24/03/2026 (Terca, 2h)

Tema: Oracle com Docker + preparacao JDBC para Spring.

## Objetivo do dia
1. subir Oracle localmente.
2. validar conexao com query simples.
3. preparar configuracao JDBC para o projeto do Dia 5.

## Conceito antes da pratica

### Por que Docker aqui?
Porque permite simular ambiente real de banco sem instalacao manual complexa.

### Por que JDBC?
Porque e a forma padrao da aplicacao Java conversar com banco relacional.

---

## Bloco 1 - Subir Oracle (00:00-00:40)
```powershell
cd C:\dev\java-zero-to-hero
docker compose -f docker/docker-compose.oracle.yml up -d
docker ps
```

Resultado esperado:
- container `oracle-free-capacitacao` em `Up`.

---

## Bloco 2 - Validar banco (00:40-01:10)
Opcional:
```powershell
docker exec -it oracle-free-capacitacao sqlplus app_user/app_password@localhost/FREEPDB1
```

Query:
```sql
SELECT 1 FROM dual;
```

---

## Bloco 3 - Anotar dados JDBC (01:10-01:40)
Use no `application.yml` do Dia 5:
- url: `jdbc:oracle:thin:@localhost:1521/FREEPDB1`
- username: `app_user`
- password: `app_password`
- driver: `oracle.jdbc.OracleDriver`

### Por que anotar agora?
Para separar problema de banco (Dia 4) de problema de API (Dia 5).

---

## Bloco 4 - Revisao (01:40-02:00)
Perguntas:
1. por que usar Docker neste curso?
2. o que a URL JDBC representa?
3. qual diferenca entre banco fora do ar e credencial errada?

## Checklist
- [ ] Oracle subiu.
- [ ] query de teste executada.
- [ ] credenciais JDBC anotadas.
