-- DROP / CREATE SAMPLE TABLES
IF OBJECT_ID('tempdb..#customers') IS NOT NULL
    DROP TABLE #customers;
CREATE TABLE #customers (
    customer_id INT IDENTITY PRIMARY KEY,
    name NVARCHAR(50),
    signup_date DATE
);

INSERT INTO #customers (name, signup_date) VALUES
('Alice', '2025-01-01'),  -- customer_id = 1
('Bob', '2025-02-15'),    -- customer_id = 2
('Alice', '2025-03-05'),  -- customer_id = 3 (duplicate name)
('Charlie', '2025-03-10');-- customer_id = 4

IF OBJECT_ID('tempdb..#orders') IS NOT NULL
    DROP TABLE #orders;
CREATE TABLE #orders (
    order_id INT IDENTITY PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2),
    order_date DATE
);

INSERT INTO #orders (customer_id, amount, order_date) VALUES
(1, 100, '2025-01-05'),
(1, 150, '2025-01-10'),
(2, 200, '2025-02-20'),
(3, 50,  '2025-03-15'),  -- Alice #2
(3, 75,  '2025-03-20'),
(4, 44,  '2025-03-07');

-- --------------------------------------------------
-- VALID: CROSS APPLY + TOP 1 + ORDER BY per customer_id
SELECT
    c.customer_id,
    c.name,
    o.latest_amount,
    o.latest_date
FROM #customers c
CROSS APPLY (
    SELECT TOP 1
        o.amount AS latest_amount,
        o.order_date AS latest_date
    FROM #orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC
) o;
-- ✅ Correct: each customer_id gets their actual latest row

-- --------------------------------------------------
-- ROOKIE TRAP: GROUP BY name after CROSS APPLY
-- Alice appears twice with different customer_ids
-- CROSS APPLY still works per customer_id, but GROUP BY c.name will collapse rows
SELECT
    c.name,
    MAX(o.latest_amount) AS latest_amount  -- naive aggregate
FROM #customers c
CROSS APPLY (
    SELECT TOP 1 
        o.amount AS latest_amount,
        o.order_date AS latest_date
    FROM #orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC
) o
GROUP BY c.name
ORDER BY c.name;

-- How would the analyst double-check their work on the "ROOKIE TRAP: GROUP BY name after CROSS APPLY" example and discover the mistake?


-- VALID: CROSS APPLY example: get the latest order per customer
SELECT
    c.customer_id,
    c.name,
    o.latest_amount,
    o.latest_date
FROM #customers c
CROSS APPLY (
    SELECT TOP 1 
        o.amount AS latest_amount,
        o.order_date AS latest_date
    FROM #orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC
) o;

-- INVALID: using TOP 1 without ORDER BY when thinking it gives the latest
SELECT
    c.customer_id,
    c.name,
    o.amount AS latest_amount
FROM #customers c
CROSS APPLY (
    SELECT TOP 1 o.amount
    FROM #orders o
    WHERE o.customer_id = c.customer_id
) o;


-- trying to create an example here where the group by would create an erroneous result
-- the idea is that with large data sets, the analyst would not know if the cross apply is returning a result for the wrong row for the Group than they are expecting. recreating this pitfall on a smaller dataset is a great learning tool
SELECT
    c.name
    --o.latest_amount,
    --o.latest_date
FROM #customers c
GROUP BY c.name

select * from #orders

-- INVALID: get the total amount per customer using CROSS APPLY (will result in error)
-- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
SELECT
    c.customer_id,
    c.name,
    o.total_amount
FROM #customers c
CROSS APPLY (
    SELECT SUM(o.amount) AS total_amount
    FROM #orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC -- <-- misleading
) o;

