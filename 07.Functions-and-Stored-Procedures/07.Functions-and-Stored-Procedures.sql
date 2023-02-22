USE SoftUni

-- 01. Employees with Salary Above 35000
	-- Create stored procedure usp_GetEmployeesSalaryAbove35000 that returns all employees' first and last names, whose salary above 35000. 

CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
BEGIN
	SELECT 
		FirstName
		,LastName
	FROM Employees
	WHERE Salary > 35000
END;

-- 02. Employees with Salary Above Number
	--Create a stored procedure usp_GetEmployeesSalaryAboveNumber that accepts a number (of type DECIMAL(18,4)) as parameter and returns all employees' first and last names, whose salary is above or equal to the given number. 

CREATE PROC usp_GetEmployeesSalaryAboveNumber 
	@number DECIMAL(18,4)
AS 
BEGIN
	SELECT 
		FirstName
		,LastName
	FROM Employees
	WHERE Salary >= @number
END;

-- 03. Town Names Starting With
	--Create a stored procedure usp_GetTownsStartingWith that accepts a string as parameter and returns all town names starting with that string. 

CREATE PROC usp_GetTownsStartingWith 
	@TownFirstLetter NVARCHAR(10)
AS
BEGIN
 	SELECT [Name]
	FROM Towns
	WHERE LEFT([Name], LEN(@TownFirstLetter)) = @TownFirstLetter
END;

-- 04. Employees from Town
--Create a stored procedure usp_GetEmployeesFromTown that accepts town name as parameter and returns the first and last name of those employees, who live in the given town. 

CREATE PROC usp_GetEmployeesFromTown
	@SearchedTown VARCHAR(50)
AS
BEGIN
	SELECT 
		e.FirstName AS 'First Name'
		,e.LastName AS 'Last Name'
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON a.TownID = t.TownID
	WHERE t.[Name] = @SearchedTown
END;
--
EXEC dbo.usp_GetEmployeesFromTown Sofia

-- 05. Salary Level Function

	--Create a function ufn_GetSalaryLevel(@salary DECIMAL(18,4)) that receives salary of an employee and returns the level of the salary.
	--•	If salary is < 30000, return "Low"
	--•	If salary is between 30000 and 50000 (inclusive), return "Average"
	--•	If salary is > 50000, return "High"

CREATE FUNCTION ufn_GetSalaryLevel
(
	@salary DECIMAL(18,4)
)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(10)
	IF(@salary < 30000)
	BEGIN
		SET @salaryLevel = 'Low'
	END
	ELSE IF(@salary BETWEEN 30000 AND 50000)
	BEGIN
		SET @salaryLevel = 'Average'
	END
	ELSE IF(@salary > 50000) 
	BEGIN
		SET @salaryLevel = 'High'
	END
	RETURN @salaryLevel
END;

-- 06. Employees by Salary Level

	--Create a stored procedure usp_EmployeesBySalaryLevel that receives as parameter level of salary (low, average, or high) and print the names of all employees, who have the given level of salary. You should use the function - "dbo.ufn_GetSalaryLevel(@Salary)", which was part of the previous task, inside your "CREATE PROCEDURE …" query.

CREATE PROC usp_EmployeesBySalaryLevel 
	@levelOfSalary VARCHAR(8)
AS
BEGIN
	SELECT 
		e.FirstName AS 'First Name'
		,e.LastName AS 'Last Name'
	FROM Employees AS e
	WHERE @levelOfSalary = dbo.ufn_GetSalaryLevel(e.Salary)
END;

-- 07. Define Function
	--Define a function ufn_IsWordComprised(@setOfLetters, @word) that returns true or false, depending on that if the word is comprised of the given set of letters. 

CREATE FUNCTION ufn_IsWordComprised
(
	@setOfLetters VARCHAR(50)
	,@word VARCHAR(50)	
) 
RETURNS BIT
AS
BEGIN
	DECLARE @wordIndex INT = 1;
	WHILE (@wordIndex <= LEN(@word))
	BEGIN
		DECLARE @currentCharacter CHAR = SUBSTRING(@word, @wordIndex, 1);
		IF (CHARINDEX(@currentCharacter, @setOfLetters) = 0)
		BEGIN
			RETURN 0;
		END
		SET @wordIndex += 1;
	END
	RETURN 1;
END;

-- 08. *Delete Employees and Departments
	--Create a procedure with the name usp_DeleteEmployeesFromDepartment (@departmentId INT) which deletes all Employees from a given department. Delete these departments from the Departments table too. Finally, SELECT the number of employees from the given department. If the delete statements are correct the select query should return 0.
	--After completing that exercise restore your database to revert all changes.
	--Hint:
	--You may set ManagerID column in Departments table to nullable (using query "ALTER TABLE …").

CREATE PROC usp_DeleteEmployeesFromDepartment 
	@departmentID INT
AS
BEGIN
	DECLARE @EmpleesToDelete TABLE(Id INT);
	INSERT INTO @EmpleesToDelete
	SELECT EmployeeID
	FROM Employees
	WHERE DepartmentID = @departmentID
	--
	DELETE 
	FROM EmployeesProjects
	WHERE EmployeeID IN (SELECT * FROM  @EmpleesToDelete);
	--
	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT * FROM @EmpleesToDelete)
	--
	UPDATE Employees
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT * FROM @EmpleesToDelete)
	--
	DELETE 
	FROM Employees
	WHERE DepartmentID = @departmentID;

	DELETE 
	FROM Departments
	WHERE DepartmentID = @departmentID;
	--
	SELECT COUNT(*) AS [Count]
	FROM Employees
	WHERE DepartmentID = @departmentID

END;

EXEC dbo.usp_DeleteEmployeesFromDepartment 7

-- 09. Find Full Name
	--You are given a database schema with tables AccountHolders(Id (PK), FirstName, LastName, SSN) and Accounts(Id (PK), AccountHolderId (FK), Balance).  Write a stored procedure usp_GetHoldersFullName that selects the full name of all people. 

USE Bank;

CREATE PROC usp_GetHoldersFullName
AS
BEGIN
	SELECT
		CONCAT_WS(' ', FirstName, LastName)
	FROM AccountHolders
END;

-- 10. People with Balance Higher Than
	--Your task is to create a stored procedure usp_GetHoldersWithBalanceHigherThan that accepts a number as a parameter and returns all the people, who have more money in total in all their accounts than the supplied number. Order them by their first name, then by their last name.

CREATE PROC usp_GetHoldersWithBalanceHigherThan
	@balance MONEY
AS
BEGIN
	SELECT
		gah.FirstName AS [First Name]
		,gah.LastName AS [Last Name]
	FROM
	(
		SELECT
			ah.FirstName
			,ah.LastName
			,SUM(a.Balance) AS SumBalance
		FROM AccountHolders AS ah
		LEFT JOIN Accounts AS a ON ah.Id = a.AccountHolderId
		GROUP BY ah.Id,	ah.FirstName, ah.LastName
	) AS gah
	WHERE gah.SumBalance > @balance
	ORDER BY gah.FirstName, gah.LastName
END;


-- 11. Future Value Function
	--Your task is to create a function ufn_CalculateFutureValue that accepts as parameters – sum (decimal), yearly interest rate (float), and the number of years (int). It should calculate and return the future value of the initial sum rounded up to the fourth digit after the decimal delimiter. Use the following formula:
	--FV=I×(〖(1+R)〗^T)
	--	I – Initial sum
	--	R – Yearly interest rate
	--	T – Number of years

USE Bank;

CREATE FUNCTION ufn_CalculateFutureValue
	(
	@sum DECIMAL(38,4)
	,@rate FLOAT
	,@years INT
	)
RETURNS DECIMAL(38,4)
AS
BEGIN
	DECLARE @result DECIMAL(38,4)
	SET @result = @sum * POWER((1 + @rate), @years)
	RETURN @result
END;

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5) 

-- 12. Calculating Interest
	--Your task is to create a stored procedure usp_CalculateFutureValueForAccount that uses the function from the previous problem to give an interest to a person's account for 5 years, along with information about their account id, first name, last name and current balance as it is shown in the example below. It should take the AccountId and the interest rate as parameters. Again, you are provided with the dbo.ufn_CalculateFutureValue function, which was part of the previous task.

CREATE PROC usp_CalculateFutureValueForAccount
(
	@accountId INT
	,@interestRate FLOAT
)
AS
BEGIN
	SELECT
		ah.Id AS [Account Id]
		,ah.FirstName AS [First Name]
		,ah.LastName AS [Last Name]
		,a.Balance AS [Current Balance]
		,dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS [Balance in 5 years]
	FROM AccountHolders AS ah
	JOIN Accounts AS a ON ah.Id = a.Id
	WHERE ah.Id = @accountId
END;
--
EXEC usp_CalculateFutureValueForAccount 1, 0.1


-- 13. *Cash in User Games Odd Rows

	--Create a function ufn_CashInUsersGames that sums the cash of the odd rows. Rows must be ordered by cash in descending order. The function should take a game name as a parameter and return the result as a table. Submit only your function in.
	--Execute the function over the following game names, ordered exactly like: "Love in a mist".

USE Diablo

CREATE FUNCTION ufn_CashInUsersGames 
(
	@gameName NVARCHAR(50)
)
RETURNS TABLE AS
RETURN
(	SELECT 
		SUM(Cash) AS SumCash
	FROM
	(
		--SELECT	
		--	ROW_NUMBER() OVER(ORDER BY ug.Cash DESC)  AS RowNumber
		--	,ug.Cash 
		--FROM UsersGames AS ug
		--WHERE GameId = 
		--	(
		--		SELECT g.Id 
		--		FROM Games AS g 
		--		WHERE g.[Name] = @gameName
		--	)

		SELECT 
			ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS RowNumber
			,ug.Cash
		FROM UsersGames AS ug
		LEFT JOIN Games AS g ON ug.GameId = g.Id
		WHERE g.[Name] = @gameName
	) AS RankingSubQuery
	WHERE RowNumber % 2 <> 0
);

--
SELECT * FROM ufn_CashInUsersGames ('Love in a mist')



 
