/************************************************************************************
Inspect Co-existence of ingredients.
************************************************************************************/

/************************************************************************************
Example: much allulose amt varied
************************************************************************************/

/* --- CONFIGURATION --- */
DECLARE @use1 BIT = 1, @term1 VARCHAR(50) = '%bamboo fiber%';
DECLARE @use2 BIT = 1, @term2 VARCHAR(50) = '%allulose%';
DECLARE @use3 BIT = 1, @term3 VARCHAR(50) = '%flax%';
DECLARE @use4 BIT = 1, @term4 VARCHAR(50) = '%vanilla%';
DECLARE @use5 BIT = 1, @term5 VARCHAR(50) = '%philadelphia%';

/* --- LOGIC --- */
WITH MatchGroups AS (
    SELECT Day, [Group]
    FROM servings
    GROUP BY Day, [Group]
    HAVING 
        (@use1 = 0 OR MAX(CASE WHEN Food_Name LIKE @term1 THEN 1 ELSE 0 END) = 1)
        AND (@use2 = 0 OR MAX(CASE WHEN Food_Name LIKE @term2 AND Food_Name NOT LIKE '%syrup%' THEN 1 ELSE 0 END) = 1)
        AND (@use3 = 0 OR MAX(CASE WHEN Food_Name LIKE @term3 THEN 1 ELSE 0 END) = 1)
        AND (@use4 = 0 OR MAX(CASE WHEN Food_Name LIKE @term4 THEN 1 ELSE 0 END) = 1)
        AND (@use5 = 0 OR MAX(CASE WHEN Food_Name LIKE @term5 THEN 1 ELSE 0 END) = 1)
),
ParsedData AS (
    -- Step 1: Extract numeric value from 'Amount' (e.g., "10g" -> 10.0)
    SELECT 
        s.Day, s.Time, s.[Group], s.Food_Name,
        CAST(LEFT(s.Amount, PATINDEX('%[a-z]%', s.Amount + 'a') - 1) AS DECIMAL(18,1)) AS AmountValue
    FROM servings s
    JOIN MatchGroups m ON s.Day = m.Day AND s.[Group] = m.[Group]
    WHERE 
        (@use1 = 1 AND s.Food_Name LIKE @term1) OR
        (@use2 = 1 AND s.Food_Name LIKE @term2 AND s.Food_Name NOT LIKE '%syrup%') OR
        (@use3 = 1 AND s.Food_Name LIKE @term3) OR
        (@use4 = 1 AND s.Food_Name LIKE @term4) OR
        (@use5 = 1 AND s.Food_Name LIKE @term5)
)
-- Step 2: Sum the amounts per Day and Group
SELECT 
    Day, 
    Time, 
    [Group], 
    Food_Name, 
    AmountValue,
    -- Window Function to sum Allulose only within each day/group
    SUM(CASE WHEN Food_Name LIKE @term2 THEN AmountValue ELSE 0 END) 
        OVER (PARTITION BY Day, [Group]) AS TotalAlluloseInGroup
FROM ParsedData
ORDER BY Day DESC, [Group], Time;