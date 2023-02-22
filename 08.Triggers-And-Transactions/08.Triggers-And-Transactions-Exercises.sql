-- 01. Create Table Logs

	--Create a table – Logs (LogId, AccountId, OldSum, NewSum). Add a trigger to the Accounts table that enters a new entry into the Logs table every time the sum on an account change. Submit only the query that creates the trigger.
USE Bank

CREATE TABLE Logs
(
	LogId INT NOT NULL IDENTITY
	,AccountId INT FOREIGN KEY REFERENCES Accounts(Id)
	,OldSum MONEY
	,NewSum MONEY
)

-- NEXT is for Judge 

CREATE TRIGGER tr_AddToLogsOnAccountAfterUpdates ON Accounts
AFTER UPDATE
AS
BEGIN
	INSERT INTO Logs (AccountId, OldSum, NewSum)
	SELECT i.Id, d.Balance, i.Balance
	FROM inserted AS i
	JOIN deleted AS d ON i.Id = d.Id
END

-- 02. Create Table Emails
	--Create another table – NotificationEmails(Id, Recipient, Subject, Body). Add a trigger to logs table and create new email whenever new record is inserted in logs table. The following data is required to be filled for each email:
	--•	Recipient – AccountId
	--•	Subject – "Balance change for account: {AccountId}"
	--•	Body - "On {date} your balance was changed from {old} to {new}."
	--Submit your query only for the trigger action.

CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY
	,Recipient INT FOREIGN KEY REFERENCES Accounts(Id)
	,[Subject] NVARCHAR (50) 
	,Body NVARCHAR (200)
)

CREATE TRIGGER tr_CreateEmailWheneverNewRecordIsInsertedInLogs 
ON Logs
AFTER INSERT
AS
BEGIN
	INSERT NotificationEmails
	(
		Recipient, [Subject], Body
	)
	SELECT 
		i.AccountId
		,CONCAT('Balance change for account: ', i.AccountId)
		,CONCAT('On ',GETDATE(), ' your balance was changed from ', i.OldSum,' to ', i.NewSum)
	FROM inserted AS i
END

-- 03. Deposit Money
	--Add stored procedure usp_DepositMoney(AccountId, MoneyAmount) that deposits money to an existing account. Make sure to guarantee valid positive MoneyAmount with precision up to the fourth sign after the decimal point. The procedure should produce exact results working with the specified precision.

CREATE PROC usp_DepositMoney
	@AccountId INT
	,@MoneyAmount DECIMAL(18,4)
AS
BEGIN
	UPDATE Accounts
	SET Balance += @MoneyAmount
	WHERE Id = @AccountId
END;

EXEC usp_DepositMoney 1, 10

-- 04. Withdraw Money Procedure
	--Add stored procedure usp_WithdrawMoney (AccountId, MoneyAmount) that withdraws money from an existing account. Make sure to guarantee valid positive MoneyAmount with precision up to the fourth sign after decimal point. The procedure should produce exact results working with the specified precision.

CREATE PROC usp_WithdrawMoney
	@AccountId INT
	,@MoneyAmount DECIMAL(18,4)
AS
BEGIN
	UPDATE Accounts
	SET Balance -= @MoneyAmount
	WHERE Id = @AccountId
END;

-- 05. Money Transfer
	--Create stored procedure usp_TransferMoney(SenderId, ReceiverId, Amount) that transfers money from one account to another. Make sure to guarantee valid positive MoneyAmount with precision up to the fourth sign after the decimal point. Make sure that the whole procedure passes without errors and if an error occurs make no change in the database. You can use both: "usp_DepositMoney", "usp_WithdrawMoney" (look at the previous two problems about those procedures). 

CREATE PROC usp_TransferMoney
	@SenderId INT
	,@ReceiverId INT
	,@Amount DECIMAL(18,4)
AS
BEGIN TRANSACTION 
	UPDATE Accounts
	SET Balance -= @Amount
	WHERE Id = @SenderId

	UPDATE Accounts
	SET Balance += @Amount
	WHERE Id = @ReceiverId
COMMIT

-- 06. Trigger

	--Users should not be allowed to buy items with a higher level than their level. Create a trigger that restricts that. The trigger should prevent inserting items that are above the specified level while allowing all others to be inserted.
	--Add bonus cash of 50000 to users: baleremuda, loosenoise, inguinalself, buildingdeltoid, monoxidecos in the game "Bali".
	--There are two groups of items that you must buy for the above users. The first are items with id between 251 and 299 including. The second group are items with id between 501 and 539 including.
	--Take cash from each user for the bought items.
	--Select all users in the current game ("Bali") with their items. Display username, game name, cash and item name. Sort the result by username alphabetically, then by item name alphabetically. 

USE Diablo

CREATE TRIGGER tr_UserGameItems ON UserGameItems 
INSTEAD OF INSERT 
AS
BEGIN 
	INSERT INTO UserGameItems
	SELECT i.Id, ug.Id FROM inserted
	JOIN UsersGames AS ug ON UserGameId = ug.Id
	JOIN Items AS i ON ItemId = i.Id
	WHERE ug.Level >= i.MinLevel
END

UPDATE UsersGames
SET Cash += 50000
FROM UsersGames AS ug
JOIN Users AS u ON ug.UserId = u.Id
JOIN Games AS g ON ug.GameId = g.Id
WHERE g.Name = 'Bali' AND u.Username IN('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')

CREATE PROC usp_BuyItems(@Username VARCHAR(100)) 
AS
BEGIN
	DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = @Username)
	DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = 'Bali')
	DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
	DECLARE @UserGameLevel INT = (SELECT Level FROM UsersGames WHERE Id = @UserGameId)

	DECLARE @counter INT = 251

	WHILE(@counter <= 539)
	BEGIN
		DECLARE @ItemId INT = @counter
		DECLARE @ItemPrice MONEY = (SELECT Price FROM Items WHERE Id = @ItemId)
		DECLARE @ItemLevel INT = (SELECT MinLevel FROM Items WHERE Id = @ItemId)
		DECLARE @UserGameCash MONEY = (SELECT Cash FROM UsersGames WHERE Id = @UserGameId)

		IF(@UserGameCash >= @ItemPrice AND @UserGameLevel >= @ItemLevel)
		BEGIN
			UPDATE UsersGames
			SET Cash -= @ItemPrice
			WHERE Id = @UserGameId

			INSERT INTO UserGameItems 
			VALUES (@ItemId, @UserGameId)
		END

		SET @counter += 1
		
		IF(@counter = 300)
		BEGIN
			SET @counter = 501
		END
	END
END

EXEC usp_BuyItems 'baleremuda'
EXEC usp_BuyItems 'loosenoise'
EXEC usp_BuyItems 'inguinalself'
EXEC usp_BuyItems 'buildingdeltoid'
EXEC usp_BuyItems 'monoxidecos'

SELECT * FROM Users AS u
JOIN UsersGames AS ug ON u.Id = ug.UserId
JOIN Games AS g ON ug.GameId = g.Id
JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
JOIN Items AS i ON ugi.ItemId = i.Id
WHERE g.[Name] = 'Bali'
ORDER BY u.Username, i.[Name]


-- 07. *Massive Shopping
	--User Stamat in Safflower game wants to buy some items. He likes all items from Level 11 to 12 as well as all items from Level 19 to 21. As it is a bulk operation you have to use transactions. 
	--A transaction is the operation of taking out the cash from the user in the current game as well as adding up the items. 
	--Write transactions for each level range. If anything goes wrong turn back the changes inside of the transaction.
	--Extract all of Stamat's item names in the given game sorted by name alphabetically.

USE Diablo

DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = 'Stamat')
DECLARE @GameId INT = (SELECT Id FROM Games WHERE [Name] = 'Safflower')
DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
DECLARE @StamatCash MONEY = (SELECT Cash FROM UsersGames WHERE Id = @UserGameId)

DECLARE @AllItemsPrice MONEY = (SELECT SUM(Price) FROM Items WHERE (MinLevel BETWEEN 11 AND 12)) 
IF(@StamatCash >= @AllItemsPrice)
	BEGIN
		BEGIN TRAN	
			UPDATE UsersGames
			SET Cash -= @AllItemsPrice
			WHERE Id = @UserGameId
	
			INSERT INTO UserGameItems
			SELECT i.Id, @UserGameId  FROM Items AS i
			WHERE (i.MinLevel BETWEEN 11 AND 12)
		COMMIT
	END

SET @AllItemsPrice = (SELECT SUM(Price) FROM Items WHERE (MinLevel BETWEEN 19 AND 21)) 
IF(@StamatCash >= @AllItemsPrice)
	BEGIN
		BEGIN TRAN
			UPDATE UsersGames
			SET Cash -= @AllItemsPrice
			WHERE Id = @UserGameId
	
			INSERT INTO UserGameItems
			SELECT i.Id, @UserGameId  FROM Items AS i
			WHERE (i.MinLevel BETWEEN 19 AND 21)
		COMMIT
	END

SELECT i.[Name] AS [Item Name] FROM Users AS u
JOIN UsersGames AS ug ON u.Id = ug.UserId
JOIN Games AS g ON ug.GameId = g.Id
JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
JOIN Items AS i ON ugi.ItemId = i.Id
WHERE u.Username = 'Stamat' AND g.[Name] = 'Safflower'
ORDER BY i.[Name]



-- 08. Employees with Three Projects
	--Create a procedure usp_AssignProject(@emloyeeId, @projectID) that assigns projects to an employee. If the employee has more than 3 project throw an exception and rollback the changes. The exception message must be: "The employee has too many projects!" with Severity = 16, State = 1.

USE SoftUni

CREATE PROC usp_AssignProject
	@emloyeeId INT
	,@projectID INT

AS
BEGIN TRANSACTION
	IF((SELECT COUNT(ProjectID) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId) >= 3)
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('The employee has too many projects!', 16, 1)
		RETURN
	END

	INSERT INTO EmployeesProjects
	VALUES (@emloyeeId,@projectID)

COMMIT;

EXEC usp_AssignProject 219, 1

-- 09. Delete Employees
	--Create a table Deleted_Employees(EmployeeId PK, FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary) that will hold information about fired (deleted) employees from the Employees table. Add a trigger to Employees table that inserts the corresponding information about the deleted records in Deleted_Employees.

CREATE TABLE Deleted_Employees 
	(	
		EmployeeId INT PRIMARY KEY IDENTITY
		,FirstName VARCHAR(50)
		,LastName VARCHAR(50)
		,MiddleName VARCHAR(50)
		,JobTitle VARCHAR(50)
		,DepartmentId INT FOREIGN KEY REFERENCES Departments(DepartmentId)
		,Salary MONEY NOT NULL
	)

CREATE TRIGGER tr_Deleted_Employees ON Employees
AFTER DELETE
AS
BEGIN
	INSERT INTO Deleted_Employees 
		(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
	SELECT
		d.FirstName, d.LastName, d.MiddleName, d.JobTitle, d.DepartmentID, d.Salary
	FROM deleted AS d
END


