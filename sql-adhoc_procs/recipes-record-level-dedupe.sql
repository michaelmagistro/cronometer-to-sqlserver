/*********** RECORD-LEVEL DUPLICATE DETECTION & DELETION **********/

-- Find duplicates using record-level duplication detection
WITH DuplicateFinder AS (
	SELECT 
		[title], 
		[ingredient], 
		[amount], 
		[recipeLoopNum],
		-- This ranks identical rows. 1 is the original, 2+ are duplicates.
		ROW_NUMBER() OVER (
			PARTITION BY [title], [ingredient], [amount], [recipeLoopNum] 
			ORDER BY (SELECT NULL)
		) AS DuplicateCount
	FROM dbo.Custom_Recipes
)
SELECT * FROM DuplicateFinder WHERE DuplicateCount > 1;
-- This deletes only the extra copies
-- DELETE FROM DuplicateFinder WHERE DuplicateCount > 1;
GO