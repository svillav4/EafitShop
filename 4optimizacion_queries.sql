-- Primer paso: Índices para las FK

CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_item_order_id ON order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_product_id ON order_item(product_id);
CREATE INDEX IF NOT EXISTS idx_payment_order_id ON payment(order_id);

-- Segundo paso: Índice para la fecha

CREATE INDEX idx_orders_order_date ON orders (order_date);

-- Tercer paso: Optimización.

DROP INDEX idx_orders_order_date;
DROP INDEX idx_order_item_product_id;
DROP INDEX idx_payment_order_id;

-- Fecha
CREATE INDEX idx_orders_order_date
ON orders (order_date, customer_id, order_id)
INCLUDE (total_amount, status);

-- Para Q2
CREATE INDEX idx_order_item_product_id
ON order_item (product_id)
INCLUDE (quantity);

EXPLAIN (ANALYZE, BUFFERS)
SELECT p.name, s.total_sold
FROM (
    SELECT product_id, SUM(quantity) AS total_sold
    FROM order_item
    GROUP BY product_id
) s
JOIN product p ON p.product_id = s.product_id
ORDER BY s.total_sold DESC
LIMIT 10;

-- Para Q3
CREATE INDEX IF NOT EXISTS idx_orders_customer_date_desc 
ON orders(customer_id, order_date DESC);

CREATE INDEX IF NOT EXISTS idx_orders_customer_date_desc 
ON orders(customer_id, order_date DESC)
INCLUDE (order_id, total_amount, status);

-- Para Q4
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_product_name_trgm
ON product
USING gin (name gin_trgm_ops);

-- Para Q5
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM orders
WHERE order_date >= '2023-11-15'
AND order_date <  '2023-11-16';

-- Para Q6
CREATE INDEX idx_payment_status_order_id
ON payment (payment_status, order_id);

-- Para Q8
CREATE INDEX idx_payment_method_order_id
ON payment (payment_method, order_id);

EXPLAIN (ANALYZE, BUFFERS)
SELECT o.status, SUM(total_amount) AS total_amount
FROM orders o
JOIN payment p ON o.order_id = p.order_id
WHERE payment_method = 'CARD'
AND o.order_date > TIMESTAMPTZ '2023-01-01'
GROUP BY o.status;