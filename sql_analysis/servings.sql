SELECT SUBSTRING(amount, 0, CHARINDEX(' ', amount)) AS Amt,
	CASE WHEN SUBSTRING(SUBSTRING(amount, CHARINDEX(' ', amount) + 1, LEN(amount)),0,2) = 'x '
		THEN SUBSTRING(amount, CHARINDEX(' ', amount) + 3, LEN(amount))
		ELSE SUBSTRING(amount, CHARINDEX(' ', amount) + 1, LEN(amount))
	END AS Unit,
	*
FROM servings
ORDER BY Day DESC, Time DESC