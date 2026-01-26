/*********** SET-LEVEL DUPLICATE DETECTION & DELETION **********/
-- 1. Create a fingerprint for every unique Title + Ingredient Set
WITH UniqueSets AS (
	SELECT 
		R.[title], 
		R.[recipeLoopNum], -- We keep this just to identify WHICH one to delete
		R.[CreateDate],    -- We keep this to decide which one is the "original"
		(
			-- This creates the fingerprint based ONLY on what's in the recipe
			SELECT CAST([ingredient] AS VARCHAR(MAX)) + ':' + CAST([amount] AS VARCHAR(MAX)) + '|'
			FROM dbo.Custom_Recipes AS InnerR
			WHERE InnerR.[title] = R.[title] 
			  AND InnerR.[recipeLoopNum] = R.[recipeLoopNum]
			  AND InnerR.[CreateDate] = R.[CreateDate]
			ORDER BY [ingredient], [amount]
			FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') AS RecipeContent
	FROM dbo.Custom_Recipes AS R
	GROUP BY R.[title], R.[recipeLoopNum], R.[CreateDate]
),
-- 2. Identify duplicates of the same title with the same content
DuplicateSets AS (
	SELECT 
		[title], 
		[recipeLoopNum], 
		[CreateDate],
		ROW_NUMBER() OVER (
			PARTITION BY [title], [RecipeContent] 
			ORDER BY [CreateDate] ASC, [recipeLoopNum] ASC -- Keep the oldest one
		) AS SetRank
	FROM UniqueSets
)
-- 3. Final Result: Every row belonging to a "Rank 2+" batch
SELECT 
	Main.*
FROM dbo.Custom_Recipes AS Main
INNER JOIN DuplicateSets AS DS
	ON Main.title = DS.title 
	AND Main.recipeLoopNum = DS.recipeLoopNum
	AND Main.CreateDate = DS.CreateDate
WHERE DS.SetRank > 1
ORDER BY Main.[title], Main.[CreateDate];

/* -- To DELETE the extra batches, use this:
DELETE Main
FROM dbo.Custom_Recipes AS Main
INNER JOIN BatchDuplicateFinder AS BDF
	ON Main.title = BDF.title 
	AND Main.CreateDate = BDF.CreateDate
WHERE BDF.BatchRank > 1;
*/