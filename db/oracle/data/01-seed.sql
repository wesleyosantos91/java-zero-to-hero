INSERT INTO clientes (nome, email) VALUES ('Ana Silva', 'ana@email.com');
INSERT INTO clientes (nome, email) VALUES ('Bruno Lima', 'bruno@email.com');

INSERT INTO pedidos (cliente_id, total, status) VALUES (1, 199.90, 'PAGO');
INSERT INTO pedidos (cliente_id, total, status) VALUES (2, 89.00, 'PENDENTE');
COMMIT;
