-- Script DML da trilha (dados)
-- Objetivo: inserir, consultar, atualizar e remover dados com seguranca.

-- INSERTS INICIAIS
INSERT INTO clientes (nome, email, data_cadastro) VALUES ('Ana Souza', 'ana.souza@email.com', DATE '2026-03-21');
INSERT INTO clientes (nome, email, data_cadastro) VALUES ('Bruno Lima', 'bruno.lima@email.com', DATE '2026-03-21');
INSERT INTO clientes (nome, email, data_cadastro) VALUES ('Carla Reis', 'carla.reis@email.com', DATE '2026-03-22');
INSERT INTO clientes (nome, email, data_cadastro) VALUES ('Diego Alves', 'diego.alves@email.com', DATE '2026-03-22');
INSERT INTO clientes (nome, email, data_cadastro) VALUES ('Elisa Nunes', 'elisa.nunes@email.com', DATE '2026-03-23');

-- CONSULTA ORDENADA
SELECT id, nome, email, data_cadastro
FROM clientes
ORDER BY nome;

-- UPDATE COM WHERE (NUNCA REMOVER O WHERE)
UPDATE clientes
SET email = 'carla.reis+novo@email.com'
WHERE id = 3;

-- DELETE COM WHERE (NUNCA REMOVER O WHERE)
DELETE FROM clientes
WHERE id = 5;

-- VALIDACAO FINAL
SELECT id, nome, email, data_cadastro
FROM clientes
ORDER BY id;
