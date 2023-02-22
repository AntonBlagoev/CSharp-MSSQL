-- 01. Employee Address
	--Create a query that selects:
	--•	EmployeeId
	--•	JobTitle
	--•	AddressId
	--•	AddressText
	--Return the first 5 rows sorted by AddressId in ascending order.

USE SoftUni

SELECT TOP 5
	 e.EmployeeId
	,e.JobTitle
	,e.AddressId
	,a.AddressText
FROM Employees AS e
LEFT JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY AddressID;

-- 02. Addresses with Towns
	--Write a query that selects:
	--•	FirstName
	--•	LastName
	--•	Town
	--•	AddressText
	--Sort them by FirstName in ascending order, then by LastName. Select the first 50 employees

SELECT TOP 50
	 e.FirstName
	,e.LastName
	,t.[Name] AS Town
	,a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY FirstName, LastName;

-- 03. Sales Employees
	--Create a query that selects:
	--•	EmployeeID
	--•	FirstName
	--•	LastName
	--•	DepartmentName
	--Sort them by EmployeeID in ascending order. Select only employees from the "Sales" department.

SELECT 
	e.EmployeeID
	,e.FirstName
	,e.LastName
	,d.Name AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY EmployeeID;

-- 04. Employee Departments
	--Create a query that selects:
	--•	EmployeeID
	--•	FirstName 
	--•	Salary
	--•	DepartmentName
	--Filter only employees with a salary higher than 15000. Return the first 5 rows, sorted by DepartmentID in ascending order.
 
SELECT TOP 5
	 e.EmployeeID
	,e.FirstName
	,e.Salary
	,d.Name AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY e.DepartmentID;

-- 05. Employees Without Projects
	--Create a query that selects:
	--•	EmployeeID
	--•	FirstName
	--Filter only employees without a project. Return the first 3 rows, sorted by EmployeeID in ascending order.

SELECT TOP 3
	 e.EmployeeID
	,e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS p ON e.EmployeeID = p.EmployeeID
WHERE p.EmployeeID IS NULL
ORDER BY e.EmployeeID;


--06. Employees Hired After

	--Create a query that selects:
	--•	FirstName
	--•	LastName
	--•	HireDate
	--•	DeptName
	--Filter only employees hired after 1.1.1999 and are from either "Sales" or "Finance" department. Sort them by HireDate (ascending).

SELECT 
	e.FirstName
	,e.LastName
	,e.HireDate
	,d.Name AS DeptName
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1999-01-01'
AND d.Name IN ('Sales', 'Finance')
ORDER BY e.HireDate;

-- 07. Employees With Project

	--Create a query that selects:
	--•	EmployeeID
	--•	FirstName
	--•	ProjectName
	--Filter only employees with a project which has started after 13.08.2002 and it is still ongoing (no end date). Return the first 5 rows sorted by EmployeeID in ascending order.

SELECT TOP 5
	e.EmployeeID
	,e.FirstName
	,p.[Name] AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID;

-- 08. Employee 24

	--Create a query that selects:
	--•	EmployeeID
	--•	FirstName
	--•	ProjectName
	--Filter all the projects of employee with Id 24. If the project has started during or after 2005 the returned value should be NULL.

SELECT
	e.EmployeeID
	,e.FirstName
	,CASE
		WHEN DATEPART(YEAR, p.StartDate) >= '2005' THEN NULL
		ELSE p.[Name]
	 END AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24;

-- 09. Employee Manager

	--Create a query that selects:
	--•	EmployeeID
	--•	FirstName
	--•	ManagerID
	--•	ManagerName
	--Filter all employees with a manager who has ID equals to 3 or 7. Return all the rows, sorted by EmployeeID in ascending order.

SELECT 
	e.EmployeeID
	,e.FirstName
	,e.ManagerID
	,b.FirstName AS ManagerName
FROM Employees AS e
LEFT JOIN Employees AS b ON e.ManagerID = b.EmployeeID
WHERE e.ManagerID IN (3, 7)
ORDER BY EmployeeID;


-- 10.	Employees Summary

	--Create a query that selects:
	--•	EmployeeID
	--•	EmployeeName
	--•	ManagerName
	--•	DepartmentName
	--Show the first 50 employees with their managers and the departments they are in (show the departments of the employees). Order them by EmployeeID.

SELECT TOP 50
	e.EmployeeID
	,CONCAT_WS(' ', e.FirstName, e.LastName) AS EmployeeName
	,CONCAT_WS(' ', m.FirstName, m.LastName) AS ManagerName
	,d.[Name] AS DepartmentName
FROM Employees AS e
LEFT JOIN Employees AS m ON e.ManagerID = m.EmployeeID
LEFT JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY EmployeeID;

-- 11.	Min Average Salary

	-- Create a query that returns the value of the lowest average salary of all departments.

SELECT TOP 1 AVG(Salary) AS MinAverageSalary 
FROM Employees
GROUP BY DepartmentID
ORDER BY MinAverageSalary

-- OR 

SELECT MIN (GroupSalary)
FROM
(
	SELECT AVG(Salary) AS GroupSalary
	FROM Employees
	GROUP BY DepartmentID
) AS MinAverageSalary;

-- 12. Highest Peaks in Bulgaria
	--Create a query that selects:
	--•	CountryCode
	--•	MountainRange
	--•	PeakName
	--•	Elevation
	--Filter all the peaks in Bulgaria, which have elevation over 2835. Return all the rows, sorted by elevation in descending order.

USE Geography 

SELECT
	 mc.CountryCode AS CountryCode
	,m.MountainRange AS MountainRange
	,p.PeakName AS PeakName
	,p.Elevation AS Elevation
FROM MountainsCountries AS mc
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON p.MountainId = m.Id
WHERE mc.CountryCode = 'BG'
AND p.Elevation > 2835
ORDER BY p.Elevation DESC;

-- 13. Count Mountain Ranges

	--Create a query that selects:
	--•	CountryCode
	--•	MountainRanges
	--Filter the count of the mountain ranges in the United States, Russia and Bulgaria.

SELECT
	 mc.CountryCode AS CountryCode
	,COUNT(m.MountainRange) AS MountainRange
FROM MountainsCountries AS mc
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
WHERE mc.CountryCode IN ('BG', 'RU', 'US')
GROUP BY mc.CountryCode;

-- or

SELECT
	 CountryCode 
	,COUNT(MountainId) AS MountainRange
FROM MountainsCountries
WHERE CountryCode IN 
	(
		SELECT CountryCode FROM Countries
		WHERE CountryName IN ('United States', 'Russia', 'Bulgaria')
	)
GROUP BY CountryCode;

-- 14. Countries With or Without Rivers

	--Create a query that selects:
	--•	CountryName
	--•	RiverName
	--Find the first 5 countries with or without rivers in Africa. Sort them by CountryName in ascending order.

SELECT TOP 5
	 c.CountryName
	,r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName;

-- 15. Continents and Currencies (not included in final score)

	--Create a query that selects:
	--•	ContinentCode
	--•	CurrencyCode
	--•	CurrencyUsage
	--Find all continents and their most used currency. Filter any currency, which is used in only one country. Sort your results by ContinentCode.

SELECT ContinentCode
	   ,CurrencyCode
	   ,CurrencyUsage
FROM 
(
	SELECT 
		*
		,DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY CurrencyUsage DESC) AS CurrencyRank
	FROM 
	(
		SELECT 
			ContinentCode
			,CurrencyCode
			,COUNT(*) AS CurrencyUsage
		FROM Countries
		GROUP BY ContinentCode, CurrencyCode
		HAVING COUNT(*) > 1
		) AS CurrencyUsageSubquery
	) AS CurrencyRankingSubquery
WHERE CurrencyRank = 1

SELECT * FROM Countries

-- 16. Countries Without any Mountains
	--Create a query that returns the count of all countries, which don’t have a mountain.

SELECT COUNT(c.CountryCode) AS Count
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
WHERE mc.CountryCode IS NULL;

-- 17. Highest Peak and Longest River by Country

	--For each country, find the elevation of the highest peak and the length of the longest river, sorted by the highest peak elevation (from highest to lowest), then by the longest river length (from longest to smallest), then by country name (alphabetically). Display NULL when no data is available in some of the columns. Limit only the first 5 rows.

SELECT TOP 5
		c.CountryName
		,MAX(p.Elevation) AS HighestPeakElevation
		,MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

-- 18. Highest Peak Name and Elevation by Country (not included in final score)

	-- For each country, find the name and elevation of the highest peak, along with its mountain. When no peaks are available in some countries, display elevation 0, "(no highest peak)" as peak name and "(no mountain)" as a mountain name. When multiple peaks in some countries have the same elevation, display all of them. Sort the results by country name alphabetically, then by highest peak name alphabetically. Limit only the first 5 rows.

SELECT TOP 5
	CountryName AS Country
	-- ,ISNULL(PeakName,'(no highest peak)')
	,CASE 
		WHEN PeakName IS NULL THEN '(no highest peak)'
		ELSE PeakName
	END AS 'Highest Peak Name'
	-- ,ISNULL(Elevation,0)
	,CASE
		WHEN Elevation IS NULL THEN 0
		ELSE Elevation
	END AS 'Highest Peak Elevation'
	-- ,ISNULL(MountainRange,'(no mountain)')
	,CASE
		WHEN MountainRange IS NULL THEN '(no mountain)'
		ELSE MountainRange
	END AS 'Mountain'
FROM
(
	SELECT c.CountryName
		,p.PeakName 
		,p.Elevation 
		,m.MountainRange
		,DENSE_RANK() OVER (PARTITION BY c.CountryName ORDER BY p.ELevation DESC) AS PeakRank
	FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
	LEFT JOIN Peaks AS p ON m.Id = p.MountainId
) AS PeakRankingSubquery
WHERE PeakRank = 1 
ORDER BY CountryName, [Highest Peak Name];
