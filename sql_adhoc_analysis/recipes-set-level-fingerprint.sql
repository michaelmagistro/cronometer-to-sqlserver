-- See Recipes titles only, no ingredients
WITH RecipeFingerprints AS (
	SELECT 
		R.[title], 
		R.[recipeLoopNum],
		R.[CreateDate],
		/* We create the "DNA" string here. 
		   We use XML PATH to ensure all ingredients are mashed into one string 
		   in a consistent alphabetical order.
		*/
		(
			SELECT CAST([ingredient] AS VARCHAR(MAX)) + ':' + CAST([amount] AS VARCHAR(MAX)) + '|'
			FROM dbo.Custom_Recipes AS InnerR
			WHERE InnerR.[title] = R.[title] 
			  AND InnerR.[recipeLoopNum] = R.[recipeLoopNum]
			  AND InnerR.[CreateDate] = R.[CreateDate]
			ORDER BY [ingredient], [amount]
			FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') AS RecipeComposition
	FROM dbo.Custom_Recipes AS R
	GROUP BY R.[title], R.[recipeLoopNum], R.[CreateDate]
)
SELECT 
	[title],
	[recipeLoopNum],
	[CreateDate],
	-- This is the unique hash of the ingredient set
	-- CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', RecipeComposition), 2) AS RecipeHashKey
	lower(right(CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', RecipeComposition), 2), 5)) + ' -- ' + [title] AS RecipeHashKey
FROM RecipeFingerprints
ORDER BY [title], [CreateDate];
GO

-- See ingredients as well
WITH RecipeFingerprints AS (
	SELECT 
		R.[title], 
		R.[recipeLoopNum],
		R.[CreateDate],
		R.ingredient,
		/* We create the "DNA" string here. 
		   We use XML PATH to ensure all ingredients are mashed into one string 
		   in a consistent alphabetical order.
		*/
		(
			SELECT CAST([ingredient] AS VARCHAR(MAX)) + ':' + CAST([amount] AS VARCHAR(MAX)) + '|'
			FROM dbo.Custom_Recipes AS InnerR
			WHERE InnerR.[title] = R.[title] 
			  AND InnerR.[recipeLoopNum] = R.[recipeLoopNum]
			  AND InnerR.[CreateDate] = R.[CreateDate]
			ORDER BY [ingredient], [amount]
			FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') AS RecipeComposition
	FROM dbo.Custom_Recipes AS R
	--GROUP BY R.[title], R.[recipeLoopNum], R.[CreateDate] -- uncomment if you want distinct view
)
SELECT 
	[title],
	[recipeLoopNum],
	[CreateDate],
	ingredient,
	-- This is the unique hash of the ingredient set
	lower(right(CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', RecipeComposition), 2), 5)) + ' -- ' + [title] AS RecipeHashKey
FROM RecipeFingerprints
-- where title like '%sauce%' -- look for a specific recipe
ORDER BY [title], [CreateDate];