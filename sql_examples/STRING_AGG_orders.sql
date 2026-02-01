-- STRING_AGG - The modern, clean way to concatenate rows
-- Available in SQL Server 2017+

CREATE TABLE #Orders (
	OrderID INT,
	CustomerID INT,
	ProductName VARCHAR(50),
	Quantity INT
);

INSERT INTO #Orders VALUES
(1, 101, 'Widget', 2),
(2, 101, 'Gadget', 1),
(3, 101, 'Doohickey', 5),
(4, 102, 'Thingamajig', 3),
(5, 102, 'Whatsit', 1);

-- Look at the data
SELECT * FROM #Orders;

-- ========================================
-- BASIC STRING_AGG
-- ========================================

-- Get all products for customer 101 as a comma-separated list
SELECT STRING_AGG(ProductName, ', ') AS Products
FROM #Orders
WHERE CustomerID = 101;
-- Result: "Widget, Gadget, Doohickey"

-- ========================================
-- STRING_AGG WITH GROUP BY
-- ========================================

-- Get products per customer
SELECT 
	CustomerID,
	STRING_AGG(ProductName, ', ') AS Products
FROM #Orders
GROUP BY CustomerID;

-- ========================================
-- STRING_AGG WITH ORDERING
-- ========================================

-- Order the concatenated results
SELECT 
	CustomerID,
	STRING_AGG(ProductName, ', ') WITHIN GROUP (ORDER BY ProductName) AS ProductsAlphabetical,
	STRING_AGG(ProductName, ', ') WITHIN GROUP (ORDER BY Quantity DESC) AS ProductsByQuantity
FROM #Orders
GROUP BY CustomerID;

-- ========================================
-- STRING_AGG WITH CUSTOM SEPARATORS
-- ========================================

SELECT 
	CustomerID,
	STRING_AGG(ProductName, ' | ') WITHIN GROUP (ORDER BY ProductName) AS PipeSeparated,
	STRING_AGG(ProductName, CHAR(13) + CHAR(10)) WITHIN GROUP (ORDER BY ProductName) AS NewlineSeparated
FROM #Orders
GROUP BY CustomerID;

-- ========================================
-- STRING_AGG WITH EXPRESSIONS
-- ========================================

-- Concatenate with quantities
SELECT 
	CustomerID,
	STRING_AGG(ProductName + ' (x' + CAST(Quantity AS VARCHAR) + ')', ', ') 
		WITHIN GROUP (ORDER BY ProductName) AS DetailedProducts
FROM #Orders
GROUP BY CustomerID;
-- Result: "Doohickey (x5), Gadget (x1), Widget (x2)"

-- ========================================
-- COMPARING: STRING_AGG vs FOR XML PATH + STUFF
-- ========================================

-- STRING_AGG way (clean, readable)
SELECT 
	CustomerID,
	STRING_AGG(ProductName, ', ') WITHIN GROUP (ORDER BY ProductName) AS Products
FROM #Orders
GROUP BY CustomerID;

-- Old FOR XML PATH + STUFF way (verbose, harder to read)
SELECT DISTINCT
	o1.CustomerID,
	STUFF((
		SELECT ', ' + ProductName
		FROM #Orders o2
		WHERE o2.CustomerID = o1.CustomerID
		ORDER BY ProductName
		FOR XML PATH('')
	), 1, 2, '') AS Products
FROM #Orders o1;

-- Both produce identical results, but STRING_AGG is clearer

DROP TABLE #Orders;