-- The combo: CROSS APPLY + STUFF
-- Get each customer with their orders as a comma-separated list

CREATE TABLE #Customers (
	CustomerID INT,
	CustomerName VARCHAR(50)
);

CREATE TABLE #Orders (
	OrderID INT,
	CustomerID INT,
	ProductName VARCHAR(50)
);

INSERT INTO #Customers VALUES 
(1, 'Alice'),
(2, 'Bob'),
(3, 'Carol');

INSERT INTO #Orders VALUES 
(101, 1, 'Widget'),
(102, 1, 'Gadget'),
(103, 1, 'Doohickey'),
(104, 2, 'Thingamajig'),
(105, 2, 'Whatsit');

-- Now get each customer with all their products in ONE cell
SELECT 
	c.CustomerName,
	o.ProductList
FROM #Customers c
CROSS APPLY (
	SELECT STUFF((
		SELECT ', ' + ProductName
		FROM #Orders
		WHERE CustomerID = c.CustomerID
		ORDER BY ProductName
		FOR XML PATH('')
	), 1, 2, '') AS ProductList
) o;

DROP TABLE #Customers;
DROP TABLE #Orders;