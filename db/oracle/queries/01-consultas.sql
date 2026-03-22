SELECT c.nome, p.id AS pedido_id, p.total, p.status
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.id
ORDER BY p.id;
