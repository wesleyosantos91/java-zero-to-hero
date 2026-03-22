# Guia de Ambiente

## Stack da formação
- Java 21 (LTS)
- Maven 3.9+
- Docker + Docker Compose
- Oracle XE via compose existente no repositório
- IDE sugerida: IntelliJ IDEA Community

## Checklist de instalação
1. `java -version`
2. `mvn -version`
3. `docker --version`
4. `docker compose version`

## Organização local sugerida
- `projects/` para aplicações
- `db/oracle/` para scripts SQL
- `docs/` para estudo guiado

## Diagnóstico rápido
- Porta Oracle ocupada: troque mapeamento no compose.
- Driver JDBC ausente: adicione dependência no `pom.xml`.
- Erro de encoding: configure UTF-8 no projeto.
