-- Exam-27-Jun-2020
-- https://judge.softuni.org/Contests/2482/Databases-MSSQL-Server-Exam-27-Jun-2020

CREATE DATABASE WMS
GO

USE WMS
GO

-- 01. DDL

	--Crate a database called WMS. You need to create 9 tables:
	--•	Clients – contains information about the customers that use the service;
	--•	Mechanics – contains information about employees;
	--•	Jobs – contains information about all machines that clients submitted for repairs;
	--•	Models – list of all washing machine models that the servie operates with;
	--•	Orders – contains information about orders for parts;
	--•	Parts – list of all parts the service operates with;
	--•	OrderParts – mapping table between Orders and Parts with additional Quantity field;
	--•	PartsNeeded – mapping table between Jobs and Parts with additional Quantity field;
	--•	Vendors – list of vendors that supply parts to the service.
	--Include the following fields in each table. Unless otherwise specified, all fields are required.
	--NOTE: Please keep in mind that in case you have to work with a date, you have to use the exact same data type, described in the models tables. For example, data type Date means that you have to use Date, DateTime means that you have to use DateTime. If you don't use the correct type, the Judge system won't accept your submission as correct.
	--NOTE: Keep in mind that Judge doesn't accept "ALTER" statement and square brackets naming (when the names are not keywords).

CREATE TABLE Clients
(
	ClientId INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR(50) NOT NULL
	,LastName NVARCHAR(50) NOT NULL
	,Phone CHAR(12) NOT NULL
)

CREATE TABLE Mechanics
(
	MechanicId INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR(50) NOT NULL
	,LastName NVARCHAR(50) NOT NULL
	,[Address] NVARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
	ModelId INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs
(
	JobId INT PRIMARY KEY IDENTITY
	,ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL
	,[Status] NVARCHAR(11) CHECK([Status] IN ('Pending', 'In Progress', 'Finished')) DEFAULT 'Pending' NOT NULL
	,ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL
	,MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId)
	,IssueDate DATE NOT NULL
	,FinishDate DATE
)



CREATE TABLE Orders
(
	OrderId INT PRIMARY KEY IDENTITY
	,JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL
	,IssueDate DATE
	,Delivered BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Vendors
(
	VendorId INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts
(
	PartId INT PRIMARY KEY IDENTITY
	,SerialNumber NVARCHAR(50) UNIQUE NOT NULL
	,[Description] NVARCHAR(50)
	,Price DECIMAL(6,2) CHECK(Price > 0) NOT NULL
	,VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL
	,StockQty INT CHECK(StockQty >= 0) DEFAULT 0 NOT NULL
)

CREATE TABLE OrderParts
(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL
	,PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL
	,PRIMARY KEY (OrderId, PartId)
	,Quantity INT CHECK(Quantity > 0) DEFAULT 1 NOT NULL
)

CREATE TABLE PartsNeeded
(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL
	,PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL
	,PRIMARY KEY (JobId, PartId)
	,Quantity INT CHECK(Quantity > 0) DEFAULT 1 NOT NULL
)

GO

-- 02. Insert
	-- Let's insert some sample data into the database. Write a query to add the following records into the corresponding tables. All Ids should be auto-generated. Replace names that relate to other tables with the appropriate ID (look them up manually, there is no need to perform table joins).

INSERT INTO Clients (FirstName, LastName, Phone)
VALUES
	('Teri', 'Ennaco', '570-889-5187')
	,('Merlyn', 'Lawler', '201-588-7810')
	,('Georgene', 'Montezuma', '925-615-5185')
	,('Jettie', 'Mconnell', '908-802-3564')
	,('Lemuel', 'Latzke', '631-748-6479')
	,('Melodie', 'Knipp', '805-690-1682')
	,('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts (SerialNumber, Description, Price, VendorId)
VALUES
	('WP8182119', 'Door Boot Seal', 117.86, 2)
	,('W10780048', 'Suspension Rod', 42.81, 1)
	,('W10841140', 'Silicone Adhesive', 6.77, 4)
	,('WPY055980', 'High Temperature Adhesive', 13.94, 3)

GO

-- 03. Update
	-- Assign all Pending jobs to the mechanic Ryan Harnos (look up his ID manually, there is no need to use table joins) and change their status to 'In Progress'.

UPDATE Jobs
SET MechanicId = 3, [Status] = 'In Progress'
WHERE [Status] = 'Pending'

GO

-- 04. Delete
	-- Cancel Order with ID 19 – delete the order from the database and all associated entries from the mapping table.

DELETE FROM OrderParts
WHERE OrderId = 19;

DELETE FROM Orders
WHERE OrderId = 19;

-- 05. Mechanic Assignments
	-- Select all mechanics with their jobs. Include job status and issue date. Order by mechanic Id, issue date, job Id (all ascending).
	--Required columns
	--•	Mechanic Full Name
	--•	Job Status
	--•	Job Issue Date

SELECT
	CONCAT_WS(' ', m.FirstName, m.LastName) AS Mechanic
	,j.[Status]
	,j.IssueDate
FROM Jobs AS j
JOIN Mechanics AS m ON j.MechanicId = m.MechanicId
ORDER BY m.MechanicId, j.IssueDate,j.JobId;

GO

-- 06. Current Clients
	--Select the names of all clients with active jobs (not Finished). Include the status of the job and how many days it’s been since it was submitted. Assume the current date is 24 April 2017. Order results by time length (descending) and by client ID (ascending).
	--Required columns
	--•	Client Full Name
	--•	Days going – how many days have passed since the issuing
	--•	Status

SELECT
	CONCAT_WS(' ', c.FirstName,c.LastName) AS Client
	,DATEDIFF(DAY, j.IssueDate, '2017-04-24') AS [Days going]
	,j.[Status]
FROM Jobs AS j
JOIN Clients AS c ON j.ClientId = c.ClientId
WHERE j.[Status] <> 'Finished'
ORDER BY [Days going] DESC, c.ClientId;

GO

-- 07. Mechanic Performance
	--Select all mechanics and the average time they take to finish their assigned jobs. Calculate the average as an integer. Order results by mechanic ID (ascending).
	--Required columns
	--•	Mechanic Full Name
	--•	Average Days – average number of days the machanic took to finish the job

SELECT
	CONCAT_WS(' ', m.FirstName, m.LastName) AS Mechanic
	,j.DaysToFinsish AS [Average Days]
FROM 
	(
		SELECT
			MechanicId
			,AVG(DATEDIFF(DAY, IssueDate, FinishDate)) AS DaysToFinsish
		FROM Jobs AS j
		WHERE [Status] = 'Finished'
		GROUP BY MechanicId
	) AS j
JOIN Mechanics AS m ON j.MechanicId = m.MechanicId
ORDER BY m.MechanicId;

GO

-- v.2

SELECT
	CONCAT_WS(' ', m.FirstName, m.LastName) AS Mechanic
    ,AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS AverageDays
FROM Mechanics AS m
JOIN Jobs AS j ON m.MechanicId = j.MechanicId
GROUP BY m.FirstName, m.LastName, j.MechanicId
ORDER BY j.MechanicId

GO

-- 08. Available Mechanics
	--Select all mechanics without active jobs (include mechanics which don't have any job assigned or all of their jobs are finished). Order by ID (ascending).
	--Required columns
	--•	Mechanic Full Name

SELECT
	CONCAT_WS(' ', m.FirstName, m.LastName) AS Available
FROM Mechanics AS m
LEFT JOIN 
	(
		SELECT 
			MechanicId
			,COUNT(MechanicId) AS CountOfJobs
		FROM Jobs 
		GROUP BY MechanicId
	) AS jj ON m.MechanicId = jj.MechanicId
LEFT JOIN 
	(
		SELECT
			MechanicId
			,COUNT(MechanicId) AS CountOfFinishedJobs
		FROM Jobs 
		WHERE [Status] = 'Finished'
		GROUP BY MechanicId
	) AS j ON j.MechanicId = jj.MechanicId
WHERE j.CountOfFinishedJobs = jj.CountOfJobs OR jj.MechanicId IS NULL
ORDER BY m.MechanicId

GO

-- v.2

SELECT
    CONCAT_WS(' ', FirstName, LastName) AS Available
FROM Mechanics
WHERE MechanicId NOT IN
(
    SELECT MechanicId 
    FROM Jobs
    WHERE [Status] = 'In Progress'
)
ORDER BY MechanicId

-- 09. Past Expenses

	--Select all finished jobs and the total cost of all parts that were ordered for them. Sort by total cost of parts ordered (descending) and by job ID (ascending).
	--Required columns
	--•	Job ID
	--•	Total Parts Cost

SELECT
	j.JobId
	,ISNULL(SUM(p.Price * op.Quantity), 0) AS Total
FROM Jobs AS j
LEFT JOIN Orders AS o ON j.JobId = o.JobId
LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
LEFT JOIN Parts AS p ON op.PartId = p.PartId
WHERE j.[Status] = 'Finished'
GROUP BY j.JobId
ORDER BY Total DESC, j.JobId

GO

-- 10. Missing Parts
	-- List all parts that are needed for active jobs (not Finished) without sufficient quantity in stock and in pending orders (the sum of parts in stock and parts ordered is less than the required quantity). Order them by part ID (ascending).
SELECT
	fj.NeededPartId
	,fj.[Description]
	,fj.[Required]
	,fj.[In Stock]
	,ISNULL(sj.SumOfOrderdQuantity, 0) AS Ordered
FROM
	(
		SELECT
			pn.PartId AS NeededPartId
			,SUM(pn.Quantity) AS [Required]
			,SUM(p.StockQty) AS [In Stock]
			,p.[Description]
		FROM Jobs AS j
		JOIN PartsNeeded AS pn ON j.JobId = pn.JobId
		JOIN Parts AS p ON pn.PartId = p.PartId
		WHERE j.[Status] <>'Finished'
		GROUP BY pn.PartId, p.[Description]
	) AS fj
LEFT JOIN 
	(
		SELECT
			op.PartId AS OrderdPartId
			,SUM(op.Quantity) AS SumOfOrderdQuantity
		FROM Jobs AS j
		JOIN Orders AS o ON j.JobId = o.JobId
		JOIN OrderParts AS op ON o.OrderId = op.OrderId
		WHERE j.[Status] <>'Finished' AND o.Delivered = 0
		GROUP BY op.PartId
	) AS sj ON fj.NeededPartId = sj.OrderdPartId
WHERE fj.[Required] > (fj.[In Stock] + ISNULL(sj.SumOfOrderdQuantity, 0))
ORDER BY fj.NeededPartId

-- v.2

SELECT
	pn.PartId
	,p.[Description] AS [Description]
	,ISNULL(SUM(pn.Quantity),0) AS [Required]
	,ISNULL(SUM(p.StockQty), 0) AS [In Stock]
	,ISNULL(SUM(op.Quantity), 0) AS Ordered
FROM Jobs AS j
LEFT JOIN PartsNeeded AS pn ON j.JobId = pn.JobId
LEFT JOIN Parts AS p ON pn.PartId = p.PartId
LEFT JOIN Orders AS o ON j.JobId = o.JobId
LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
WHERE j.[Status] <>'Finished'
GROUP BY pn.PartId, p.[Description]
HAVING ISNULL(SUM(pn.Quantity),0) > (ISNULL(SUM(p.StockQty), 0) + ISNULL(SUM(op.Quantity), 0))
ORDER BY pn.PartId;

GO

-- 11. Place Order

	--Your task is to create a user defined procedure (usp_PlaceOrder) which accepts job ID, part serial number and   quantity and creates an order with the specified parameters. If an order already exists for the given job that and the order is not issued (order's issue date is NULL), add the new product to it. If the part is already listed in the order, add the quantity to the existing one.
	--When a new order is created, set it's IssueDate to NULL.
	--Limitations:
	--•	An order cannot be placed for a job that is Finished; error message ID 50011 "This job is not active!"
	--•	The quantity cannot be zero or negative; error message ID 50012 "Part quantity must be more than zero!"
	--•	The job with given ID must exist in the database; error message ID 50013 "Job not found!"
	--•	The part with given serial number must exist in the database ID 50014 "Part not found!"
	--If any of the requirements aren't met, rollback any changes to the database you've made and throw an exception with the appropriate message and state 1. 
	--Parameters
	--•	JobId
	--•	Part Serial Number
	--•	Quantity

CREATE PROC usp_PlaceOrder 
	(
		@JobId INT
		,@SerialNumber NVARCHAR(50)
		,@Quantity INT
	)
AS
BEGIN

	IF (@JobId IN (SELECT JobId FROM Jobs WHERE [Status] = 'Finished')) THROW 50011, 'This job is not active!', 1
	IF (@Quantity <= 0) THROW 50012, 'Part quantity must be more than zero!', 1
	IF (@jobId NOT IN (SELECT JobId FROM Jobs)) THROW 50013, 'Job not found!', 1
	IF (@SerialNumber NOT IN (SELECT SerialNumber FROM Parts)) THROW 50014, 'Part not found!', 1

	DECLARE @PartId INT = (SELECT PartId FROM Parts WHERE SerialNumber = @SerialNumber)
	DECLARE @OrderId INT = (SELECT OrderId FROM Orders WHERE JobId = @JobId)

	IF (SELECT JobId FROM Orders WHERE JobId = @JobId AND IssueDate IS NULL) IS NOT NULL
	BEGIN
		IF (@PartId IN (SELECT PartId FROM OrderParts WHERE OrderId = @OrderId))
		BEGIN
			UPDATE OrderParts
			SET Quantity += @Quantity 
			WHERE OrderId = @OrderId AND PartId = @PartId
			RETURN
		END
		INSERT INTO OrderParts VALUES (@OrderId, @PartId, @Quantity)
		RETURN
	END
	INSERT INTO Orders (JobId, IssueDate) VALUES (@jobId, NULL)
	SET @OrderId = (SELECT TOP(1) OrderId FROM Orders ORDER BY OrderId DESC)
	INSERT INTO OrderParts VALUES (@OrderId, @PartId, @Quantity)

END

GO

-- 12. Cost of Order
	--Create a user defined function (udf_GetCost) that receives a job's ID and returns the total cost of all parts that were ordered for it. Return 0 if there are no orders.

CREATE FUNCTION udf_GetCost
	(
		@JobId INT
	)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @TotalCost DECIMAL(18,2)
	SET @TotalCost = 
		(
			SELECT 
				SUM(op.Quantity * p.Price) AS TotalPrice
			FROM Orders AS o
			LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
			LEFT JOIN Parts AS p ON op.PartId = p.PartId
			WHERE o.JobId = @JobId
			GROUP BY o.JobId
		)
	IF (@TotalCost IS NULL)
		SET @TotalCost = 0

	RETURN @TotalCost
END
GO

SELECT dbo.udf_GetCost(1)
SELECT dbo.udf_GetCost(3)
SELECT dbo.udf_GetCost(23)

GO