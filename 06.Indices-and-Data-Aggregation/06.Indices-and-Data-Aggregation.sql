USE Gringotts

-- 01. Records’ Count
	-- Import the database and send the total count of records from the one and only table to Mr. Bodrog. Make sure nothing gets lost.

SELECT 
	Count(Id) AS [Count] 
FROM WizzardDeposits

-- 02. Longest Magic Wand
	-- Select the size of the longest magic wand. Rename the new column appropriately.

SELECT 
	MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits;

-- 03. Longest Magic Wand per Deposit Groups
	-- For wizards in each deposit group show the longest magic wand. Rename the new column appropriately.

SELECT 
	DepositGroup
	,MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup;

-- 04. Smallest Deposit Group per Magic Wand Size (not included in final score)
	-- Select the two deposit groups with the lowest average wand size.

SELECT TOP 2 
	DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize);

-- 05. Deposits Sum
	-- Select all deposit groups and their total deposit sums

SELECT 
	DepositGroup
	,SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup;

-- 06. Deposits Sum for Ollivander Family
	-- Select all deposit groups and their total deposit sums, but only for the wizards, who have their magic wands crafted by the Ollivander family.

SELECT mwc.DepositGroup, SUM(mwc.DepositAmount) AS TotalSum
FROM 
(
	SELECT * 
	FROM WizzardDeposits
	WHERE MagicWandCreator = 'Ollivander family'
) AS mwc
GROUP BY mwc.DepositGroup;

-- or

SELECT 
	DepositGroup
	,SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits	
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup;

-- 07. Deposits Filter
	-- Select all deposit groups and their total deposit sums, but only for the wizards, who have their magic wands crafted by the Ollivander family. Filter total deposit amounts lower than 150000. Order by total deposit amount in descending order.

SELECT 
	mwc.DepositGroup
	,SUM(mwc.DepositAmount) AS TotalSum
FROM 
(
	SELECT * FROM WizzardDeposits
	WHERE MagicWandCreator = 'Ollivander family'
) AS mwc
GROUP BY mwc.DepositGroup
HAVING SUM(mwc.DepositAmount) < 150000
ORDER BY SUM(mwc.DepositAmount) DESC;

-- or

SELECT 
	DepositGroup
	,SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY SUM(DepositAmount) DESC;

-- 08. Deposit Charge
	--Create a query that selects:
	--•	Deposit group 
	--•	Magic wand creator
	--•	Minimum deposit charge for each group 
	--Select the data in ascending order by MagicWandCreator and DepositGroup.

SELECT 
	DepositGroup
	,MagicWandCreator
	,MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup;

-- 09. Age Groups
	--Write down a query that creates 7 different groups based on their age.
	--Age groups should be as follows:
	--•	[0-10]
	--•	[11-20]
	--•	[21-30]
	--•	[31-40]
	--•	[41-50]
	--•	[51-60]
	--•	[61+]
	--The query should return
	--•	Age groups
	--•	Count of wizards in it

SELECT 
	ga.AgeGroup
	,COUNT(ga.AgeGroup) AS WizardCount
FROM
(
	SELECT
		CASE
			WHEN Age <= 10 THEN '[0-10]'
			WHEN Age <= 20 THEN '[11-20]'
			WHEN Age <= 30 THEN '[21-30]'
			WHEN Age <= 40 THEN '[31-40]'
			WHEN Age <= 50 THEN '[41-50]'
			WHEN Age <= 60 THEN '[51-60]'
			ELSE '[61+]'
		END AS AgeGroup
	FROM WizzardDeposits
) AS ga
GROUP BY ga.AgeGroup;

-- 10. First Letter
	--Create a query that returns all the unique wizard first letters of their first names only if they have deposit of type Troll Chest. Order them alphabetically. Use GROUP BY for uniqueness.

SELECT 
	FirstLetter
FROM
(
	SELECT LEFT(FirstName,1) AS FirstLetter
	FROM WizzardDeposits
	WHERE DepositGroup = 'Troll Chest'
) AS gfn
GROUP BY gfn.FirstLetter
ORDER BY FirstLetter;

-- 11. Average Interest
	--Mr. Bodrog is highly interested in profitability. He wants to know the average interest of all deposit groups, split by whether the deposit has expired or not. But that's not all. He wants you to select deposits with start date after 01/01/1985. Order the data descending by Deposit Group and ascending by Expiration Flag.

SELECT
	ged.DepositGroup
	,ged.IsDepositExpired
	,AVG(ged.DepositInterest) AS AverageInterest;
FROM
(
	SELECT *
	FROM WizzardDeposits
	WHERE DepositStartDate > '01/01/1985'
) AS ged
GROUP BY ged.DepositGroup, ged.IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired;

-- or

SELECT
	DepositGroup
	,IsDepositExpired
	,AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired;

-- 12. *Rich Wizard, Poor Wizard (not included in final score)

	--Mr. Bodrog definitely likes his werewolves more than you. This is your last chance to survive! Give him some data to play his favorite game Rich Wizard, Poor Wizard. The rules are simple: 
	--You compare the deposits of every wizard with the wizard after him. If a wizard is the last one in the database, simply ignore it. In the end you have to sum the difference between the deposits.

SELECT 
	SUM(DifferenceSubQuery.[Difference]) AS SumDifference
FROM
(
	SELECT  
		FirstName AS 'Host Wizard'
		,DepositAmount AS 'Host Wizard Deposit'
		,LEAD(FirstName) OVER (ORDER BY Id) AS 'Guest Wizard'
		,LEAD(DepositAmount) OVER (ORDER BY Id) AS 'Guest Wizard Deposit'
		,DepositAmount - LEAD(DepositAmount) OVER (ORDER BY Id) AS [Difference]
	FROM WizzardDeposits
) AS DifferenceSubQuery;

-- or

SELECT 
	SUM(wd1.DepositAmount - wd2.DepositAmount) AS SumDifference
FROM WizzardDeposits AS wd1
INNER JOIN WizzardDeposits AS wd2 
ON wd1.Id + 1 = wd2.Id;

-- or wrong

SELECT 
	SUM(ft.[Difference]) AS SumDifference
FROM
(
	SELECT  
		hw.FirstName AS 'Host Wizard'
		,hw.DepositAmount AS 'Host Wizard Deposit'
		,gw.FirstName AS 'Guest Wizard'
		,gw.DepositAmount AS 'Guest Wizard Deposit'
		,hw.DepositAmount - gw.DepositAmount AS [Difference]
	FROM
	(
		SELECT	
			ROW_NUMBER() OVER(ORDER BY Id ASC)  AS RowNumber
			,Id
			,FirstName 
			,DepositAmount 
		FROM WizzardDeposits
		WHERE Id % 2 > 0
	) AS hw
	JOIN
	(
		SELECT	
			ROW_NUMBER() OVER(ORDER BY Id ASC)  AS RowNumber
			,Id
			,FirstName
			,DepositAmount
		FROM WizzardDeposits
		WHERE Id % 2 = 0
	) AS gw 
	ON hw.RowNumber = gw.RowNumber
) AS ft;

-- 13. Departments Total Salaries

	--Create a query that shows the total sum of salaries for each department. Order them by DepartmentID.
	--Your query should return:	
	--•	DepartmentID

USE SoftUni

SELECT 
	DepartmentID
	,SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID;

-- 14. Employees Minimum Salaries
	--Select the minimum salary from the employees for departments with ID (2, 5, 7) but only for those, hired after 01/01/2000.
	--Your query should return:	
	--•	DepartmentID

SELECT 
	DepartmentID
	,MIN(Salary) AS MinimumSalary
FROM Employees
WHERE DepartmentID IN(2, 5, 7) AND HireDate > '01/01/2000'
GROUP BY DepartmentID

-- 15. Employees Average Salaries
	--Select all employees who earn more than 30000 into a new table. Then delete all employees who have ManagerID = 42 (in the new table). Then increase the salaries of all employees with DepartmentID = 1 by 5000. Finally, select the average salaries in each department.

SELECT *
INTO tmpEmployees
FROM Employees
WHERE Salary > 30000;

DELETE
FROM tmpEmployees
WHERE ManagerID = 42;

UPDATE tmpEmployees
SET Salary += 5000
WHERE DepartmentID = 1;

SELECT
	DepartmentID
	,AVG(Salary) AS AverageSalary
FROM tmpEmployees
GROUP BY DepartmentID

-- 16. Employees Maximum Salaries
	--Find the max salary for each department. Filter those, which have max salaries NOT in the range 30000 – 70000.

SELECT 
	DepartmentID
	,MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) < 30000 OR MAX(Salary) > 70000;

-- 17. Employees Count Salaries
	--Count the salaries of all employees, who don’t have a manager.

SELECT 
	COUNT(EmployeeID) AS [Count]
FROM Employees
WHERE ManagerID IS NULL
GROUP BY ManagerID;

-- 18. *3rd Highest Salary (not included in final score)
	--Find the third highest salary in each department if there is such. 

SELECT 
	DepartmentID
	,Salary AS ThirdHighestSalary
FROM
(
	SELECT 
		DepartmentID
		,Salary
		,DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
	FROM Employees
	GROUP BY DepartmentID, Salary
) AS SalaryRankSubQuery
WHERE SalaryRankSubQuery.SalaryRank = 3

-- or

SELECT DISTINCT
	DepartmentID
	,Salary AS ThirdHighestSalary
FROM
(
	SELECT 
		DepartmentID
		,Salary
		,DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
	FROM Employees
) AS SalaryRankSubQuery
WHERE SalaryRankSubQuery.SalaryRank = 3

-- 19. **Salary Challenge (not included in final score)
	--Create a query that returns:
	--•	FirstName
	--•	LastName
	--•	DepartmentID
	--Select all employees who have salary higher than the average salary of their respective departments. Select only the first 10 rows. Order them by DepartmentID.

SELECT TOP 10
	FirstName
	,LastName
	,je.DepartmentID
FROM
(
	SELECT 
		FirstName
		,LastName
		,e.DepartmentID
		--,ge.DepartmentID
		,Salary
		,AvgSalary
	FROM Employees AS e
	LEFT JOIN 
	(
		SELECT
			DepartmentID
			,AVG(Salary) AS AvgSalary
		FROM Employees
		GROUP BY DepartmentID
	) AS ge
	ON e.DepartmentID = ge.DepartmentID
) AS je
WHERE Salary > AvgSalary;

-- or

SELECT TOP 10
	FirstName
	,LastName
	,DepartmentID
FROM Employees AS e
WHERE e.Salary > 
	(
		SELECT AVG(Salary) AS AvgSalary
		FROM Employees AS eSub
		WHERE e.DepartmentID = eSub.DepartmentID
		GROUP BY DepartmentID
	)
ORDER BY e.DepartmentID