-- STRING_SPLIT with JOINs - learning it the hard way

CREATE TABLE #Customers (
    CustomerID INT,
    CustomerName VARCHAR(50),
    FriendIDs VARCHAR(100)
);

INSERT INTO #Customers VALUES 
(1, 'Alice', '2,3'),
(2, 'Bob', '1,4'),
(3, 'Carol', '1,2'),
(4, 'Dave', '2');

SELECT * FROM #Customers;

-- THE GOAL: Get friend names, not just IDs
-- We want to turn Alice's FriendIDs "2,3" into actual names: "Bob, Carol"

-- Step 1: Let's split Alice's friends
SELECT * FROM STRING_SPLIT('2,3', ',');
-- ^^ Works! Returns 2 rows: value = '2', value = '3'

-- Step 2: Now let's join those IDs back to get names
SELECT c.CustomerName
FROM STRING_SPLIT('2,3', ',') split
JOIN #Customers c ON c.CustomerID = CAST(split.value AS INT);
-- ^^ Works! Returns: Bob, Carol

-- Step 3: Great! Now let's do it for ALL customers
-- Natural thought: just replace '2,3' with the column
SELECT c1.CustomerName, c2.CustomerName AS Friend
FROM #Customers c1
JOIN STRING_SPLIT(c1.FriendIDs, ',') split ON 1=1
JOIN #Customers c2 ON c2.CustomerID = CAST(split.value AS INT);
-- ^^ ERROR! "Invalid column name 'c1'"
-- ^^ Why? Because STRING_SPLIT(c1.FriendIDs, ',') is evaluated BEFORE c1 exists

-- WHY JOIN DOESN'T WORK:
-- In a JOIN, SQL evaluates both sides independently first, then matches them up
-- But STRING_SPLIT(c1.FriendIDs, ',') NEEDS c1 to already exist - it's a chicken-and-egg problem
-- Think about it: SQL would need to:
-- 1. Evaluate #Customers c1
-- 2. For each row, evaluate STRING_SPLIT(c1.FriendIDs, ',')
-- 3. Then join them
-- That's not how JOIN works. That's how CROSS APPLY works.

-- CROSS APPLY: The solution
-- CROSS APPLY says (example 1): "For each row in c1, run this function and attach the results"
-- CROSS APPLY says (example 2): "Do a dynamic join, e.g. add a where clause etc. or a join to a manipulated column from the base table"
SELECT c1.CustomerName, split.value AS FriendID
FROM #Customers c1
CROSS APPLY STRING_SPLIT(c1.FriendIDs, ',') split;
-- ^^ This works! For Alice, it splits "2,3" into 2 rows. For Bob, it splits "1,4" into 2 rows, etc.

-- Now add the final JOIN to get friend names
SELECT c1.CustomerName AS Customer, c2.CustomerName AS Friend
FROM #Customers c1
CROSS APPLY STRING_SPLIT(c1.FriendIDs, ',') split
JOIN #Customers c2 ON c2.CustomerID = CAST(split.value AS INT);
-- ^^ Perfect! Alice -> Bob, Alice -> Carol, Bob -> Alice, Bob -> Dave, etc.

-- When JOIN actually works:
-- JOIN works fine when the string is hardcoded (doesn't reference c1)
SELECT * FROM #Customers c1
JOIN STRING_SPLIT('1,2,3', ',') split ON c1.CustomerID = CAST(split.value AS INT);
-- ^^ This returns customers 1, 2, and 3 (filters the table)
-- ^^ But it's not what we want - we want EACH customer's specific friend list

-- You can also join a table to itself using CROSS APPLY
SELECT * FROM #Customers c1
CROSS APPLY (SELECT * FROM #Customers) c2;
-- ^^ FOR EACH record in Customers, return EACH RECORD in Customers (explode-squares the resultset)

DROP TABLE #Customers;