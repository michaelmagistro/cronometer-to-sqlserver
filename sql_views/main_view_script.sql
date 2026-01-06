/*
  File: main_views_script.sql
  Purpose: Create / update all reporting views
  Run this file ONCE to refresh all views
*/

USE Cronometer
GO

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


/* ======= Servings Counts ======= */

-- See which items you consume the most often
CREATE OR ALTER VIEW dbo.vw_ServingsCounts
AS

SELECT TOP 10000
    Food_Name,
    COUNT(*) as Counts
FROM servings
GROUP BY Food_Name
ORDER BY Counts DESC
GO

/* ======= Servings Counts ======= */

-- See which items you consumed the most recently
CREATE OR ALTER VIEW dbo.vw_ServingsRecency
AS

SELECT TOP 10000
    Food_Name,
    MAX(
        CAST([Day] AS datetime) + CAST([Time] AS datetime)
    ) AS last_consumed_dt
FROM dbo.servings
GROUP BY Food_Name
ORDER BY last_consumed_dt DESC
GO

/* ======= Forgotten Classics ======= */

-- See which items you used to frequently consume in the past, but haven't any more
CREATE OR ALTER VIEW dbo.vw_ServingsForgottenClassics
AS

SELECT TOP 10000
    Food_Name,
    MAX(
        CAST([Day] AS datetime) + CAST([Time] AS datetime)
    ) AS last_consumed_dt,
    COUNT(*) as iCount
FROM servings
WHERE day < dateadd(day,-20,getdate())
AND Food_Name NOT IN (
    SELECT DISTINCT
        Food_Name
    FROM servings
    WHERE day > dateadd(day,-20,getdate())
    GROUP BY Food_Name
)
GROUP BY Food_Name
HAVING COUNT(*) > 10
ORDER BY last_consumed_dt DESC
GO

/* ======= All Food Pairings Matrix ======= */

-- see how often you pair foods together -- no discrimination
CREATE OR ALTER VIEW dbo.vw_FoodCoOccurrence_ByGroup
AS


SELECT TOP 10000
    a.Food_Name AS Food_A,
    b.Food_Name AS Food_B,
    COUNT(DISTINCT a.[Day]) AS CoOccurrenceDays
FROM dbo.servings a
JOIN dbo.servings b
   ON a.[Group] = b.[Group]
   AND a.[Day]   = b.[Day]
   AND a.Food_Name < b.Food_Name
GROUP BY
    a.Food_Name,
    b.Food_Name
ORDER BY CoOccurrenceDays DESC;
GO

/* ======= Food Pairings Matrix - No Supplements ======= */

-- see how often you pair foods together -- pills and supplements excluded
CREATE OR ALTER VIEW dbo.vw_FoodCoOccurrenceNoSupplements_ByGroup
AS

-- a select for debugging purposes
--SELECT CASE 
--    WHEN SUBSTRING(SUBSTRING(amount, CHARINDEX(' ', amount) + 1, LEN(amount)), 0, 2) = 'x '
--    THEN SUBSTRING(amount, CHARINDEX(' ', amount) + 3, LEN(amount))
--    ELSE SUBSTRING(amount, CHARINDEX(' ', amount) + 1, LEN(amount))
--END
--FROM Servings

SELECT TOP 10000
    cleaned_unit_a,
    a.Food_Name AS Food_A,
    b.Food_Name AS Food_B,
    COUNT(DISTINCT a.[Day]) AS CoOccurrenceDays
FROM dbo.servings a
JOIN dbo.servings b
    ON a.[Group] = b.[Group]
   AND a.[Day] = b.[Day]
   AND a.Food_Name < b.Food_Name
CROSS APPLY (
    SELECT CASE 
        WHEN SUBSTRING(SUBSTRING(a.amount, CHARINDEX(' ', a.amount) + 1, LEN(a.amount)), 0, 2) = 'x '
        THEN SUBSTRING(a.amount, CHARINDEX(' ', a.amount) + 3, LEN(a.amount))
        ELSE SUBSTRING(a.amount, CHARINDEX(' ', a.amount) + 1, LEN(a.amount))
    END AS cleaned_unit_a
) ca
CROSS APPLY (
    SELECT CASE 
        WHEN SUBSTRING(SUBSTRING(b.amount, CHARINDEX(' ', b.amount) + 1, LEN(b.amount)), 0, 2) = 'x '
        THEN SUBSTRING(b.amount, CHARINDEX(' ', b.amount) + 3, LEN(b.amount))
        ELSE SUBSTRING(b.amount, CHARINDEX(' ', b.amount) + 1, LEN(b.amount))
    END AS cleaned_unit_b
) cb
WHERE LOWER(ca.cleaned_unit_a) NOT LIKE '%capsule%'
  AND LOWER(cb.cleaned_unit_b) NOT LIKE '%capsule%'
  AND LOWER(ca.cleaned_unit_a) NOT LIKE '%tablet%'
  AND LOWER(cb.cleaned_unit_b) NOT LIKE '%tablet%'
  AND LOWER(ca.cleaned_unit_a) NOT LIKE '%soft%gel%'
  AND LOWER(cb.cleaned_unit_b) NOT LIKE '%soft%gel%'
  AND LOWER(ca.cleaned_unit_a) NOT LIKE '%softgel%'
  AND LOWER(cb.cleaned_unit_b) NOT LIKE '%softgel%'
  AND LOWER(ca.cleaned_unit_a) NOT LIKE '%scoop%'
  AND LOWER(cb.cleaned_unit_b) NOT LIKE '%scoop%'
  AND LOWER(ca.cleaned_unit_a) NOT LIKE '%drop%'
  AND LOWER(cb.cleaned_unit_b) NOT LIKE '%drop%'
  AND LOWER(ca.cleaned_unit_a) NOT LIKE '%caplet%'
  AND LOWER(cb.cleaned_unit_b) NOT LIKE '%caplet%'
GROUP BY
    ca.cleaned_unit_a,
    a.Food_Name,
    b.Food_Name
ORDER BY CoOccurrenceDays DESC;
GO

/* ======= Emergent Combos/Recipes ======= */

-- See which items you often group together, and thus infer these may be recipes
-- This is for those recipes which you may have "exploded" in the diary, and thus no recipe header name exists for the group
-- however, you can infer that it appears to be a recipe by fact that they are in the same group (e.g. the lunch grou)
-- TODO: complete this view
-- CREATE OR ALTER VIEW dbo.vw_EmergentCombosRecipes
-- AS

-- SELECT TOP 10000
--     Food_Name,
--     MAX(
--         CAST([Day] AS datetime) + CAST([Time] AS datetime)
--     ) AS last_consumed_dt,
--     COUNT(*) as Counts
-- FROM servings
-- WHERE MAX(CAST([Day] AS datetime) + CAST([Time] AS datetime)) < DATEADD(DAY,20,GETDATE())
-- GROUP BY Food_Name
-- ORDER BY Counts DESC
-- GO

/* ======= Sparingly-used items - Why? ======= */

-- See which items you tried only a few times in the past
-- Question arises: why did you stop consuming the item? Is that revelation contained in your notes if applicable?
-- TODO: complete this view
-- CREATE OR ALTER VIEW dbo.vw_SparinglyUsedItems
-- AS

-- SELECT TOP 10000
--     Food_Name,
--     MAX(
--         CAST([Day] AS datetime) + CAST([Time] AS datetime)
--     ) AS last_consumed_dt,
--     COUNT(*) as Counts
-- FROM servings
-- WHERE MAX(CAST([Day] AS datetime) + CAST([Time] AS datetime)) < DATEADD(DAY,20,GETDATE())
-- GROUP BY Food_Name
-- ORDER BY Counts DESC
-- GO

/* ======= Warning: Supplement Lapse ======= */

-- see which supplements you have not taken for several days.
-- did you run out? or did they just slip through the cracks? no longer contained in a current recipe?
-- TODO: complete this view
CREATE OR ALTER VIEW dbo.vw_SupplementLapse
AS

SELECT TOP 10000
    Food_Name,
    MAX(
        CAST([Day] AS datetime) + CAST([Time] AS datetime)
    ) AS last_consumed_dt,
    COUNT(*) as iCount
FROM servings s
CROSS APPLY (
    SELECT CASE 
        WHEN SUBSTRING(SUBSTRING(s.amount, CHARINDEX(' ', s.amount) + 1, LEN(s.amount)), 0, 2) = 'x '
        THEN SUBSTRING(s.amount, CHARINDEX(' ', s.amount) + 3, LEN(s.amount))
        ELSE SUBSTRING(s.amount, CHARINDEX(' ', s.amount) + 1, LEN(s.amount))
    END AS cleaned_unit_a
) ca
WHERE (LOWER(ca.cleaned_unit_a) LIKE '%capsule%'
OR LOWER(ca.cleaned_unit_a) LIKE '%tablet%'
OR LOWER(ca.cleaned_unit_a) LIKE '%soft%gel%'
OR LOWER(ca.cleaned_unit_a) LIKE '%softgel%'
OR LOWER(ca.cleaned_unit_a) LIKE '%scoop%'
OR LOWER(ca.cleaned_unit_a) LIKE '%drop%'
OR LOWER(ca.cleaned_unit_a) LIKE '%caplet%')
AND Food_Name NOT IN (
    SELECT DISTINCT
        Food_Name
    FROM servings
    WHERE day > dateadd(day,-7,getdate())
    GROUP BY Food_Name
)
AND day < dateadd(day,-7,getdate())
GROUP BY Food_Name
--HAVING COUNT(*) > 2
ORDER BY iCount DESC
GO