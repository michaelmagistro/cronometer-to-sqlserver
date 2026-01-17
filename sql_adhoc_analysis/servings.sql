/*********************************************************************
BEGIN: SQL Adhoc Analysis
*********************************************************************/

SELECT SUBSTRING(amount, 0, CHARINDEX(' ', amount)) AS Amt,
	CASE WHEN SUBSTRING(SUBSTRING(amount, CHARINDEX(' ', amount) + 1, LEN(amount)),0,2) = 'x '
		THEN SUBSTRING(amount, CHARINDEX(' ', amount) + 3, LEN(amount))
		ELSE SUBSTRING(amount, CHARINDEX(' ', amount) + 1, LEN(amount))
	END AS Unit,
	*
FROM servings
ORDER BY Day DESC, Time DESC

/*----------------------------------------------------------------------
END: SQL Adhoc Analysis
----------------------------------------------------------------------*/

/*********************************************************************
BEGIN: Simple How Much of a Nutrient
*********************************************************************/

select food_name, day
, sum(cast(SUBSTRING(amount, 0, CHARINDEX(' ', amount)) as float)) as amt
from servings
where Food_Name like '%creatin%'
group by food_name, day
order by day desc

/*----------------------------------------------------------------------
END: Simple How Much of a Nutrient
----------------------------------------------------------------------*/