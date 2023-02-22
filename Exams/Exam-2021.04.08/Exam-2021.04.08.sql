-- Retake-Exam-8-April-2021
-- https://judge.softuni.org/Contests/2866/Databases-MSSQL-Server-Retake-Exam-8-April-2021

CREATE DATABASE [Service]
GO

USE [Service]
GO

-- 01. DDL
	--Create a database called Service. You need to create 6 tables:
	--•	Users - contains information about the people who submist reports;
	--•	Reports - contains information about the problems;
	--•	Employees - contains information about the employees;
	--•	Departments - contains information about the departments;
	--•	Categories - contains information about categories of the reports;
	--•	Status - contains information about the possible status.

	--NOTE: Please keep in mind that in case you have to work with a date, you have to use the exact same data type, described in the models tables. For example, data type Date means that you have to use Date, DateTime means that you have to use DateTime. If you don't use the correct type, the Judge system won't accept your submission as correct.
	--NOTE: Keep in mind that Judge doesn't accept "ALTER" statement and square brackets naming (when the names are not keywords).

CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY
	,Username VARCHAR(30) UNIQUE NOT NULL
	,[Password] VARCHAR(50) NOT NULL
	,[Name] VARCHAR(50)
	,Birthdate DATETIME
	,Age INT CHECK(Age BETWEEN 14 AND 110)
	,Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY
	,FirstName VARCHAR(25)
	,LastName VARCHAR(25)
	,Birthdate DATETIME
	,Age INT CHECK(Age BETWEEN 18 AND 110)
	,DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)

)

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(50) NOT NULL
	,DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE [Status]
(
	Id INT PRIMARY KEY IDENTITY
	,[Label] VARCHAR(20) NOT NULL
)

CREATE TABLE Reports
(
	Id INT PRIMARY KEY IDENTITY
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
	,StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL
	,OpenDate DATETIME NOT NULL
	,CloseDate DATETIME
	,[Description] VARCHAR(200) NOT NULL
	,UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
	,EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

GO

-- 02. Insert
	--Let's insert some sample data into the database. Write a query to add the following records into the corresponding tables. All Id's should be auto-generated.

INSERT INTO Reports
	(CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId)
VALUES
	( 1, 1, '2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2)
	,( 6, 3, '2015-09-05', '2015-12-06', 'Charity trail running', 3, 5)
	,( 14, 2, '2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2)
	,( 4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1)

INSERT INTO Employees
	(FirstName, LastName, Birthdate, DepartmentId)
VALUES
	('Marlo', 'O''Malley', '1958-9-21', 1)
	,('Niki', 'Stanaghan', '1969-11-26', 4)
	,('Ayrton', 'Senna', '1960-03-21', 9)
	,('Ronnie', 'Peterson', '1944-02-14', 9)
	,('Giovanna', 'Amati', '1959-07-20', 5)

GO

-- 03. Update
	-- Update the CloseDate with the current date of all reports, which don't have CloseDate. 

UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

GO

-- 04. Delete
	-- Delete all reports who have a Status 4.

DELETE FROM Reports
WHERE StatusId = 4

GO

-- 05. Unassigned Reports
	-- Find all reports that don't have an assigned employee. Order the results by OpenDate in ascending order, then by Description ascending. OpenDate must be in format - 'dd-MM-yyyy'

SELECT 
	[Description]
	,FORMAT(OpenDate, 'dd-MM-yyyy')
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, [Description]

GO

-- 06. Reports & Categories
	-- Select all descriptions from reports, which have category. Order them by description (ascending) then by category name (ascending).

SELECT
	r.[Description]
	,c.[Name] AS CategoryName
FROM Reports AS r
LEFT JOIN Categories AS c ON r.CategoryId = c.Id
ORDER BY r.[Description], c.[Name]

GO

-- 07. Most Reported Category
	-- Select the top 5 most reported categories and order them by the number of reports per category in descending order and then alphabetically by name.

SELECT TOP (5)
	c.[Name] AS CategoryName
	,COUNT(r.CategoryId) AS ReportsNumber
FROM Reports AS r
LEFT JOIN Categories AS c ON r.CategoryId = c.Id
GROUP BY r.CategoryId, c.[Name]
ORDER BY COUNT(r.CategoryId) DESC

GO

-- 08. Birthday Report
	-- Select the user's username and category name in all reports in which users have submitted a report on their birthday. Order them by username (ascending) and then by category name (ascending).

SELECT
	u.Username
	,c.[Name] AS CategoryName
FROM Reports AS r
LEFT JOIN Users AS u ON r.UserId = u.Id
LEFT JOIN Categories AS c ON r.CategoryId = c.Id
WHERE DATEPART(DAY,r.OpenDate) = DATEPART(DAY,u.Birthdate)
AND DATEPART(MONTH,r.OpenDate) = DATEPART(MONTH,u.Birthdate)
ORDER BY u.Username, c.[Name]

GO

-- 09. User per Employee
	-- Select all employees and show how many unique users each of them has served to.
	-- Order by users count  (descending) and then by full name (ascending).

SELECT 
	CONCAT_WS(' ', e.FirstName, e.LastName) AS FullName
	,COUNT(r.UserId)
FROM Employees AS e
LEFT JOIN Reports AS r ON e.Id = r.EmployeeId
GROUP BY r.EmployeeId, e.FirstName, e.LastName
ORDER BY COUNT(r.UserId) DESC, FullName

-- 10. Full Info
	-- Select all info for reports along with employee first name and last name (concataned with space), their department name, category name, report description, open date, status label and name of the user. Order them by first name (descending), last name (descending), department (ascending), category (ascending), description (ascending), open date (ascending), status (ascending) and user (ascending).
	--Date should be in format 'dd.MM.yyyy'.
	--If there are empty records, replace them with 'None'.

SELECT
	CASE
		WHEN CONCAT_WS(' ', e.FirstName, e.LastName) = ' ' THEN 'None'
		ELSE CONCAT_WS(' ', e.FirstName, e.LastName) 
	END AS Employee
	,CASE 
		WHEN d.[Name] IS NULL THEN 'None'
		ELSE d.[Name]
	END AS Department
	,c.[Name] AS Category
	,r.[Description]
	,FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate
	,s.[Label] AS [Status]
	,u.[Name] AS [User]
FROM Reports AS r
LEFT JOIN Employees AS e ON r.EmployeeId = e.Id
LEFT JOIN Departments AS d ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c ON r.CategoryId = c.Id
LEFT JOIN Status AS s ON r.StatusId = s.Id
LEFT JOIN Users AS u ON r.UserId = u.Id
ORDER BY e.FirstName DESC, e.LastName DESC, d.[Name], c.[Name], r.[Description], r.OpenDate, s.[Label], u.[Name]

GO

-- 11. Hours to Complete
	-- Create a user defined function with the name udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME) that receives a start date and end date and must returns the total hours which has been taken for this task. If start date is null or end is null, return 0.

CREATE FUNCTION udf_HoursToComplete
	(
		@StartDate DATETIME
		,@EndDate DATETIME
	)
RETURNS INT
AS
BEGIN
	DECLARE @TotalHours INT

	SET @TotalHours = DATEDIFF(HOUR, @StartDate, @EndDate)

	RETURN @TotalHours
END

GO

-- 12. Assign Employee
	--Create a stored procedure with the name usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT) that receives an employee's Id and a report's Id and assigns the employee to the report only if the department of the employee and the department of the report's category are the same. Otherwise throw an exception with message: "Employee doesn't belong to the appropriate department!". 

CREATE PROC usp_AssignEmployeeToReport
	(
		@EmployeeId INT
		,@ReportId INT
	)
AS
BEGIN
	IF
	(
		(SELECT
			d.Id
		FROM Employees AS e
		LEFT JOIn Departments AS d ON e.DepartmentId = d.Id
		WHERE e.Id = @EmployeeId
		)
		<>
		(SELECT 
			d.Id
		FROM Reports AS r
		LEFT JOIN Categories AS c ON r.CategoryId = c.Id
		LEFT JOIN Departments AS d ON c.DepartmentId = d.Id
		WHERE r.Id = @ReportId
		)
	)
		SELECT 'Employee doesn''t belong to the appropriate department!'
	ELSE
	
		UPDATE Reports 
		SET EmployeeId = @EmployeeId
		WHERE Id = @ReportId
	
END

GO

EXEC usp_AssignEmployeeToReport 30, 1
EXEC usp_AssignEmployeeToReport 17, 2

GO