-- STRING_AGG + CROSS APPLY: The power combo
-- Real-world scenario: customers, their friends (comma-separated IDs), and order history

CREATE TABLE #Customers (
	CustomerID INT,
	CustomerName VARCHAR(50),
	FriendIDs VARCHAR(100)
);

CREATE TABLE #Orders (
	OrderID INT,
	CustomerID INT,
	ProductName VARCHAR(50),
	OrderDate DATE
);

INSERT INTO #Customers VALUES 
(1, 'Alice', '2,3'),
(2, 'Bob', '1,4'),
(3, 'Carol', '1,2'),
(4, 'Dave', '2');

INSERT INTO #Orders VALUES 
(101, 1, 'Widget', '2024-01-15'),
(102, 1, 'Gadget', '2024-01-20'),
(103, 2, 'Doohickey', '2024-01-18'),
(104, 2, 'Thingamajig', '2024-01-22'),
(105, 2, 'Whatsit', '2024-01-25'),
(106, 3, 'Gizmo', '2024-01-19'),
(107, 4, 'Contraption', '2024-01-21');

-- Look at the data
SELECT * FROM #Customers;
SELECT * FROM #Orders;

-- ========================================
-- SCENARIO 1: For each customer, show their friends' names as a list
-- ========================================

SELECT 
	c.CustomerName,
	friendList.FriendNames
FROM #Customers c
CROSS APPLY (
	SELECT STRING_AGG(friend.CustomerName, ', ') AS FriendNames
	FROM STRING_SPLIT(c.FriendIDs, ',') split
	JOIN #Customers friend ON friend.CustomerID = CAST(split.value AS INT)
) friendList;

-- What's happening:
-- 1. CROSS APPLY splits FriendIDs into rows
-- 2. JOIN gets friend names
-- 3. STRING_AGG combines them back into one comma-separated list
-- It's like: explode → transform → collapse

-- ========================================
-- SCENARIO 2: For each customer, show what each friend has ordered
-- ========================================

SELECT 
	c.CustomerName AS Customer,
	friend.CustomerName AS Friend,
	orders.ProductList
FROM #Customers c
CROSS APPLY STRING_SPLIT(c.FriendIDs, ',') split
JOIN #Customers friend ON friend.CustomerID = CAST(split.value AS INT)
CROSS APPLY (
	SELECT STRING_AGG(ProductName, ', ') WITHIN GROUP (ORDER BY OrderDate) AS ProductList
	FROM #Orders
	WHERE CustomerID = friend.CustomerID
) orders;

-- Alice's view:
-- - Bob has ordered: Doohickey, Thingamajig, Whatsit
-- - Carol has ordered: Gizmo

-- ========================================
-- SCENARIO 3: Top 2 most recent orders per friend
-- ========================================

-- This is where CROSS APPLY really shines - you can't do this with just STRING_AGG

SELECT 
	c.CustomerName AS Customer,
	friend.CustomerName AS Friend,
	recentOrders.ProductList
FROM #Customers c
CROSS APPLY STRING_SPLIT(c.FriendIDs, ',') split
JOIN #Customers friend ON friend.CustomerID = CAST(split.value AS INT)
CROSS APPLY (
	SELECT STRING_AGG(ProductName, ', ') AS ProductList
	FROM (
		SELECT TOP 2 ProductName, OrderDate
		FROM #Orders
		WHERE CustomerID = friend.CustomerID
		ORDER BY OrderDate DESC
	) topOrders
) recentOrders;

-- Notice: Bob now shows only his 2 most recent orders (Whatsit, Thingamajig)
-- not all 3

-- ========================================
-- SCENARIO 4: Complex filtering - friends who ordered more than 2 items
-- ========================================

SELECT 
	c.CustomerName AS Customer,
	activeFriends.FriendList
FROM #Customers c
CROSS APPLY (
	SELECT STRING_AGG(friend.CustomerName, ', ') AS FriendList
	FROM STRING_SPLIT(c.FriendIDs, ',') split
	JOIN #Customers friend ON friend.CustomerID = CAST(split.value AS INT)
	WHERE (
		SELECT COUNT(*) 
		FROM #Orders 
		WHERE CustomerID = friend.CustomerID
	) >= 2
) activeFriends
WHERE activeFriends.FriendList IS NOT NULL;

-- Alice's active friends: Bob (3 orders)
-- Carol and Dave are filtered out (only 1 order each)

-- ========================================
-- THE PATTERN
-- ========================================
-- CROSS APPLY: Split/filter/transform data dynamically per row
-- STRING_AGG: Collapse multiple rows back into one comma-separated value
-- Together: Powerful data reshaping

DROP TABLE #Customers;
DROP TABLE #Orders;