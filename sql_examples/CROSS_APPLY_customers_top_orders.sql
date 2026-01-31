/**************************************************************
Standalone Example: CROSS APPLY. Customers and their Top Orders
**************************************************************/

-- First, let's create the simplest possible scenario
-- You have customers and their orders

CREATE TABLE #Customers (
    CustomerID INT,
    CustomerName VARCHAR(50)
);

CREATE TABLE #Orders (
    OrderID INT,
    CustomerID INT,
    Amount DECIMAL(10,2)
);

-- Insert some data
INSERT INTO #Customers VALUES 
(1, 'Alice'),
(2, 'Bob'),
(3, 'Carol');

INSERT INTO #Orders VALUES 
(101, 1, 50.00),
(102, 1, 75.00),
(103, 1, 25.00),
(104, 2, 100.00),
(105, 2, 200.00);
-- Note: Carol has NO orders

select * from #orders
select * From #customers

-- Compare to a regular INNER JOIN (notice that all of Alice's orders show up)
SELECT 
    c.CustomerName,
    o.OrderID,
    o.Amount
FROM #Customers c
JOIN #Orders o ON c.CustomerID = o.CustomerID;

-- Now watch this - get top 2 orders per customer.
-- Cross apply is kind of like applying some conditions before the join takes place. it's almost like a dynamic join.
-- "Apply" in this case can either increase or decrease the number of rows returned based on the criteria.
-- Cross Apply is to INNER Join as Outer Apply is to LEFT Join
SELECT 
    c.CustomerName,
    o.OrderID,
    o.Amount
FROM #Customers c
CROSS APPLY (
    SELECT TOP 2 OrderID, Amount
    FROM #Orders
    WHERE CustomerID = c.CustomerID
    ORDER BY Amount DESC
) o;


-- Compare to a CTE which uses row number window function
with cte as (
    select orderid from (
        select
        orderid,
        row_number() over(partition by CustomerID order by amount desc) as rn
        from #orders
    ) a
    where a.rn in (1,2)
)
select *
from #Orders o
join cte c on o.OrderID = c.orderid
join #Customers cu on cu.CustomerID = o.CustomerID

-- This is IMPOSSIBLE with a regular JOIN:
select * From #customers
SELECT c.CustomerName, split.value
FROM #Customers c
CROSS APPLY (
    SELECT 'First' AS value
    UNION ALL
    SELECT 'Second'
) split;
-- ^^ Note how "Apply" in this case means APPLY to each record. So it's multiplicative.. applying the "split" to EACH.

/**************************************************************
INVALID Examples
**************************************************************/

-- INVALID: using TOP 1 without ORDER BY when thinking it gives the latest
SELECT
    c.customerid,
    c.customername,
    o.amount AS latest_amount
FROM #Customers c
CROSS APPLY (
    SELECT TOP 1 o.amount
    FROM #orders o
    WHERE o.customerid = c.customerid
) o


-- INVALID: get the total amount per customer using CROSS APPLY (will result in error)
-- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
SELECT
    c.customerid,
    c.customername,
    o.total_amount
FROM #customers c
CROSS APPLY (
    SELECT SUM(o.amount) AS total_amount
    FROM #orders o
    WHERE o.customerid = c.customerid
    ORDER BY o.OrderID desc -- <-- misleading
) o


DROP TABLE #Customers;
DROP TABLE #Orders;
