--we use the data base created
USE vrindaStore;




--showing the records
SELECT * FROM sales




--if the column Date is in format YY-DD-MM and you want to format the date to yyyy-mm-dd

BEGIN TRAN

ALTER TABLE sales
ADD [date2] VARCHAR(10)

UPDATE sales
SET [date2] = FORMAT([Date], 'yyyy-dd-MM')

UPDATE sales
SET [Date] = CONVERT(DATE, [date2], 120) -- or without 120 cause is default

ALTER TABLE sales
DROP COLUMN date2

SELECT * FROM sales

COMMIT TRAN






--drop the index column
BEGIN TRAN

ALTER TABLE [dbo].[sales]
DROP COLUMN [index]

SELECT * FROM sales

COMMIT TRAN




--Genders
SELECT
	DISTINCT Gender
FROM
	sales




--Gender
BEGIN TRAN

UPDATE
	sales
SET
	Gender =
		CASE
			WHEN Gender = 'W' THEN 'Women'
			WHEN Gender = 'M' THEN 'Men'
			WHEN Gender = 'Women' THEN 'Women'
			WHEN Gender = 'Men' THEN 'Men'
		END

SELECT * FROM sales

COMMIT TRAN




--adding a column for ageGroup
BEGIN TRAN;

ALTER TABLE sales
ADD ageGroup NVARCHAR(20)


SELECT * FROM sales

COMMIT TRAN




--adding column ageGroup
BEGIN TRAN

UPDATE
	sales
SET
	ageGroup =
		CASE
			WHEN Age < 30 THEN 'Young Adult'
			WHEN Age < 50 THEN 'Adult'
			ELSE 'Senior'
		END

SELECT * FROM sales

COMMIT TRAN





--adding a month column
BEGIN TRAN;

ALTER TABLE sales
ADD [month] NVARCHAR(20)


SELECT * FROM sales

COMMIT TRAN




--getting the month of the date

BEGIN TRAN;

UPDATE
	sales
SET
	[month] = 
	FORMAT(
		Date,
		'MMMM'
	);

SELECT * FROM sales

COMMIT TRAN




--quantity cleaning
BEGIN TRAN

UPDATE
	sales
SET
	Qty =
		CASE
			WHEN Qty = 'One' THEN 1
			WHEN Qty = 'Two' THEN 2
			WHEN Qty IN (1,2,3,4,5) THEN Qty
		END

SELECT * FROM sales

COMMIT TRAN 





--order vs sales
SELECT
	month,
	SUM(Amount) AS SumOfAmount,
	COUNT(*) AS CountOfSales
FROM sales
GROUP BY month
ORDER BY SumOfAmount DESC





--order vs sales with monetary and numeric format
SELECT
	month,
	FORMAT(SUM(Amount), 'C') AS SumOfAmount,
	FORMAT(COUNT(*),'N2') AS CountOfSales
FROM sales
GROUP BY month
ORDER BY SumOfAmount DESC




--women vs men sales percentage
WITH percentages AS (
	SELECT
		COUNT(*) AS totalSales,
		SUM(
			CASE
				WHEN Gender = 'Women' THEN 1 ELSE 0
			END
		) AS WomenSalesCount,
		SUM(
			CASE
				WHEN Gender = 'Men' THEN 1 ELSE 0
			END
		) AS MenSalesCount
	FROM
		sales
)


--getting the percentages
SELECT
	CAST((CAST(WomenSalesCount AS DECIMAL(10,2)) / totalSales * 100) AS DECIMAL(10,2)) AS WomenPercentage,
	CAST((CAST(MenSalesCount AS DECIMAL(10,2)) / totalSales * 100) AS DECIMAL(10,2)) AS MenPercentage
FROM percentages





--men vs women sales amount percentage
WITH percentages AS (
	SELECT
		SUM(Amount) AS TotalSumOfAmount,
		SUM(
			CASE
				WHEN Gender = 'Women' THEN Amount ELSE 0
			END
		) AS SumOfWomenSalesAmount,
		SUM(
			CASE
				WHEN Gender = 'Men' THEN Amount ELSE 0
			END
		) AS SumOfMenSalesAmount
	FROM
		sales
)



--getting the percentages
SELECT
	CAST((CAST(SumOfWomenSalesAmount AS DECIMAL(10,2)) / TotalSumOfAmount * 100) AS DECIMAL(10,2)) AS WomenAmountPercentage,
	CAST((CAST(SumOfMenSalesAmount AS DECIMAL(10,2)) / TotalSumOfAmount * 100) AS DECIMAL(10,2)) AS MenAmountPercentage
FROM percentages






--Status percentages
WITH percentages AS (
	SELECT
		COUNT(*) AS TotalSales,
		SUM(
			CASE
				WHEN [Status] = 'Refunded' THEN 1 ELSE 0
			END
		) AS RefundedCount,
		SUM(
			CASE
				WHEN [Status] = 'Returned' THEN 1 ELSE 0
			END
		) AS ReturnedCount,
		SUM(
			CASE
				WHEN [Status] = 'Delivered' THEN 1 ELSE 0
			END
		) AS DeliveredCount,
		SUM(
			CASE
				WHEN [Status] = 'Cancelled' THEN 1 ELSE 0
			END
		) AS CancelledCount
	FROM
		sales
)



--getting the percentages
SELECT
	CAST((CAST(RefundedCount AS DECIMAL(10,2)) / TotalSales * 100) AS DECIMAL(10,2)) AS RefundedPercentage,
	CAST((CAST(ReturnedCount AS DECIMAL(10,2)) / TotalSales * 100) AS DECIMAL(10,2)) AS ReturnedPercentage,
	CAST((CAST(DeliveredCount AS DECIMAL(10,2)) / TotalSales * 100) AS DECIMAL(10,2)) AS DeliveredPercentage,
	CAST((CAST(CancelledCount AS DECIMAL(10,2)) / TotalSales * 100) AS DECIMAL(10,2)) AS CancelledPercentage
FROM percentages






--sales: top 5 states
SELECT
	TOP 5
	ship_state,
	SUM(Amount) AS SumOfAmount
FROM
	sales
GROUP BY
	ship_state
ORDER BY
	SumOfAmount DESC




--sales formatted: top 5 states
SELECT
TOP 5
	ship_state,
	SUM(Amount) AS SumOfAmount,
	FORMAT(SUM(Amount),'C') AS SumOfAmountFormatted
FROM
	sales
GROUP BY
	ship_state
ORDER BY
	SumOfAmount DESC





--age and gender percentages
DECLARE @totalSales INT
SET @totalSales = (SELECT COUNT(*) FROM sales)


SELECT
	ageGroup,
	Gender,
	CAST((CAST(COUNT(*) AS DECIMAL(10,2)) / @totalSales * 100) AS DECIMAL(10,2)) AS SalesPercentage
FROM
	sales
GROUP BY
	ageGroup,
	Gender
ORDER BY
	ageGroup ASC,
	Gender ASC





--channels percentages
DECLARE @totalSales INT
SET @totalSales = (SELECT COUNT(*) FROM sales)


SELECT
	Channel,
	CAST((CAST(COUNT(*) AS DECIMAL(10,2)) / @totalSales * 100) AS DECIMAL(10,2)) AS SalesPercentage
FROM
	sales
GROUP BY
	Channel
ORDER BY
	SalesPercentage DESC




--for creating transactions
BEGIN TRAN --begin
ROLLBACK TRAN --undo
COMMIT TRAN --accept 
SELECT @@TRANCOUNT AS CurrentTransactions --current