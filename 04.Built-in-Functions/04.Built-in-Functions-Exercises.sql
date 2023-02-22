-- 01. Find Names of All Employees by First Name
USE SoftUni

SELECT FirstName, LastName 
FROM Employees
WHERE  LEFT(FirstName, 2) = 'Sa'

-- or

SELECT FirstName, LastName 
FROM Employees
WHERE FirstName LIKE 'Sa%';

-- 02. Find Names of All Employees by Last Name

SELECT FirstName, LastName FROM Employees
WHERE  LastName LIKE '%ei%'

-- 03. Find First Names of All Employees

SELECT FirstName FROM Employees
WHERE DepartmentID IN (3, 10)
AND DATEPART(YEAR,[HireDate]) BETWEEN 1995 AND 2005


-- 04. Find All Employees Except Engineers

SELECT FirstName, LastName FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

-- 05. Find Towns with Name Length

SELECT [Name] FROM Towns
WHERE LEN([Name]) IN (5,6)
ORDER BY [Name]

-- 06. Find Towns Starting With

SELECT * FROM Towns
WHERE LEFT([Name], 1) IN ('M', 'K', 'B', 'E')
ORDER BY [Name]

-- or

SELECT * FROM Towns
WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name]


-- 07. Find Towns Not Starting With

SELECT * FROM Towns
WHERE LEFT([Name], 1) NOT IN ('R', 'B', 'D')
ORDER BY [Name]

-- 08. Create View Employees Hired After 2000 Year

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName FROM Employees
WHERE DATEPART(YEAR, HireDate) > 2000;

-- 09. Length of Last Name

SELECT FirstName, LastName FROM Employees
WHERE LEN(LastName) = 5

-- 10. Rank Employees by Salary

SELECT 
	EmployeeID
	,FirstName
	,LastName
	,Salary
	,DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000 
ORDER BY Salary DESC;

-- 11. Find All Employees with Rank 2 *
SELECT
	* 
FROM
	(
		SELECT e.EmployeeID, e.FirstName, e.LastName, e.Salary, 
				DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
		FROM Employees AS e
		WHERE Salary BETWEEN 10000 AND 50000 
	) AS [RankSubQuery]
WHERE [Rank] = 2
ORDER BY Salary DESC

-- 12. Countries Holding 'A' 3 or More Times

USE Geography 

SELECT CountryName, IsoCode FROM Countries
WHERE  CountryName LIKE '%a%a%a%'
ORDER BY IsoCode;

-- or

SELECT CountryName, IsoCode FROM Countries
WHERE  LEN([CountryName]) -  LEN(REPLACE(LOWER([CountryName]), 'a', '')) >= 3
ORDER BY IsoCode;

-- 13. Mix of Peak and River Names

SELECT 
	p.PeakName
	,r.RiverName
	,LOWER (CONCAT(p.PeakName, RIGHT(r.RiverName, LEN(r.RiverName) - 1))) AS Mix
FROM Peaks AS p
JOIN Rivers as r
ON RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY Mix

-- or

SELECT 
	p.PeakName
	,r.RiverName
	,LOWER (CONCAT(p.PeakName, SUBSTRING(r.RiverName, 2, LEN(r.RiverName)))) AS Mix
FROM Peaks AS p, Rivers AS r
WHERE RIGHT(LOWER(p.PeakName), 1) = LEFT(LOWER(r.RiverName), 1)
ORDER BY Mix

-- 14. Games From 2011 and 2012 Year

USE Diablo

SELECT TOP (50) [Name], FORMAT([Start],'yyyy-MM-dd') AS [Start] 
FROM Games
WHERE DATEPART(YEAR, [Start]) IN (2011, 2012)
ORDER BY [Start], [Name];

-- 15. User Email Providers

SELECT 
	Username
	,SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email))  AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username;

-- or

SELECT 
	Username
	,SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email) - CHARINDEX('@', Email))  AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username;

-- 16. Get Users with IP Address Like Pattern

SELECT 
	Username
	,IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username;

-- 17. Show All Games with Duration & Part of the Day

SELECT [Name] AS Game
	  ,CASE
			WHEN DATEPART(HOUR, [Start]) BETWEEN 0 AND 11 THEN 'Morning'
			WHEN DATEPART(HOUR, [Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
			WHEN DATEPART(HOUR, [Start]) BETWEEN 18 AND 23 THEN 'Evening'
	   END
	   AS [Part of the Day]
	  ,CASE
			WHEN Duration <= 3 THEN 'Extra Short'
			WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
			WHEN Duration > 6 THEN 'Long'
			ELSE 'Extra Long'
	   END
	   AS Duration
FROM Games
ORDER BY Game, Duration, [Part of the Day];

-- 18. Orders Table
USE Orders

SELECT
	ProductName
	,OrderDate
	,DATEADD(DAY, 3, OrderDate) AS [Pay Due]
	,DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM Orders;

-- 19. People Table

CREATE TABLE People
(
	 ID INT PRIMARY KEY IDENTITY(1,1)
	,[Name] VARCHAR (50) NOT NULL
	,Birthdate DATETIME2
);

INSERT INTO People ([Name], Birthdate)
VALUES
	 ('Victor', '2000-12-07 00:00:00.000')
	,('Steven', '1992-09-10 00:00:00.000')
	,('Stephen', '1910-09-19 00:00:00.000')
	,('John', '2010-01-06 00:00:00.000');

SELECT 
	 [Name]
	,DATEDIFF(YEAR, [Birthdate], GETDATE()) AS [Age in Years]
	,DATEDIFF(MONTH, [Birthdate], GETDATE()) AS [Age in Months]
	,DATEDIFF(DAY, [Birthdate], GETDATE()) AS [Age in Days]
	,DATEDIFF(MINUTE, [Birthdate], GETDATE()) AS [Age in Minutes]
FROM People