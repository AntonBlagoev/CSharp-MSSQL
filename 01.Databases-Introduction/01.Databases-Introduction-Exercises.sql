-- Exercises: Database Introduction

-- 1.	Create Database

CREATE DATABASE Minions;

-- 2.	Create Tables

USE Minions;

CREATE Table Minions
(
	Id INT NOT NULL,
	[Name] VARCHAR(50),
	Age INT,
);

CREATE Table Towns
(
	Id INT PRIMARY KEY,
	Name VARCHAR(50)
);

ALTER TABLE Minions
ADD CONSTRAINT PK_MinionsId PRIMARY KEY(Id);

-- 3.	Alter Minions Table

ALTER TABLE Minions
ADD TownID INT NOT Null

ALTER TABLE Minions
ADD FOREIGN KEY (TownID) REFERENCES Towns(Id);

-- 4.	Insert Records in Both Tables

INSERT INTO Towns
VALUES 
	(1, 'Sofia'),
	(2, 'Plovdiv'),
	(3, 'Varna');

INSERT INTO Minions
VALUES 
	(1, 'Kevin', 22, 1),
	(2, 'Bob', 15, 3),
	(3, 'Steward', NULL, 2);

-- 5.	Truncate Table Minions

TRUNCATE TABLE Minions;

-- 6.	Drop All Tables

DROP TABLE Minions;
DROP TABLE Towns;

-- 7.	Create Table People

CREATE Table People
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Pictute VARBINARY(MAX),
	Height FLOAT,
	[Weight] FLOAT,
	Gender NVARCHAR(1) NOT NULL,
	Birthdate DATETIME2 NOT NULL,
	Biography NVARCHAR(MAX) NULL 
);

INSERT INTO People
VALUES
	('Petar', NULL, 173.4, 73.5, 0, '01-14-2023', 'BC'),
	('Goso', NULL, 173.4, 73.5, 0, '01-14-2023', 'dffffffffff'),
	('Ivan', NULL, 173.4, 73.5, 0, '01-14-2023', 'dffffffffff'),
	('Stamat', NULL, 173.4, 73.5, 0, '01-14-2023', 'dffffffffff'),
	('Roni', NULL, 173.4, 73.5, 0, '01-14-2023', 'dffffffffff');

-- 8.	Create Table Users

CREATE Table Users
(
	Id BIGINT IDENTITY PRIMARY KEY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePictute VARBINARY(MAX) CHECK(LEN(ProfilePictute) >= 900000),
	LastLoginTime DATETIME2 NOT NULL,
	IsDeleted BIT 
);

INSERT INTO Users
VALUES
	('Petar', '123456', NULL, '01-14-2023', 0),
	('Ivan', '123456', NULL, '01-15-2023', 0),
	('Georgi', '123456', NULL, '01-16-2023', 0),
	('Stavri', '123456', NULL, '01-17-2023', 0),
	('Anton', '123456', NULL, '01-18-2023', 0);

-- 9.	Change Primary Key

ALTER TABLE Users 
DROP CONSTRAINT PK__Users__3214EC07A252FF65;

ALTER TABLE Users 
ADD CONSTRAINT PK_IdUsername PRIMARY KEY(Id, Username);

-- 10.	Add Check Constraint

ALTER TABLE Users 
ADD CONSTRAINT CHK_PasswordMinLen CHECK(LEN([Password]) >= 5);

-- 11.	Set Default Value of a Field

ALTER TABLE Users 
ADD CONSTRAINT DF_LastLoginTime DEFAULT GETDATE() FOR LastLoginTime;

-- 12.	Set Unique Field

ALTER TABLE Users DROP CONSTRAINT PK_IdUsername;
ALTER TABLE Users ADD CONSTRAINT PK_Id PRIMARY KEY (Id);
ALTER TABLE Users ADD CONSTRAINT UC_Username UNIQUE (Username);
ALTER TABLE Users ADD CONSTRAINT CHK_UsernameMinLen CHECK(LEN(Username) >= 3);

-- 13.	Movies Database

CREATE DATABASE Movies;

CREATE TABLE Directors 
(
	Id INT IDENTITY(1,1) PRIMARY KEY
	,DirectorName VARCHAR(20) NOT NULL
	,Notes VARCHAR(100)
);

INSERT INTO Directors 
	(DirectorName, Notes)
VALUES 
	('Pesho', 'I`am Pesho')
	,('Gosho', 'I`am Gosho')
	,('Mitko', 'I`am Mitko')
	,('Vanko', 'I`am Vanko')
	,('Stavri', 'I`am Stavri');

CREATE TABLE Genres 
(
	Id INT IDENTITY(1,1) PRIMARY KEY
	,GenreName VARCHAR(20) NOT NULL
	,Notes VARCHAR(100)
);

INSERT INTO Genres 
	(GenreName, Notes)
VALUES 
	('Action', 'This is Action Genre')
	,('Comedy', 'This is Comedy Genre')
	,('Drana', 'This is Drana Genre')
	,('Fantasy', 'This is Fantasy Genre')
	,('Horor', 'This is Horor Genre');


CREATE TABLE Categories 
(
	Id INT IDENTITY(1,1) PRIMARY KEY
	,CategoryName VARCHAR(20) NOT NULL
	,Notes VARCHAR(100)
);

INSERT INTO Categories 
	(CategoryName, Notes)
VALUES 
	('American', 'This is American category')
	,('Russian', 'This is Russian category')
	,('Bulgarian', 'This is Bulgarian category')
	,('Serbian', 'This is Serbian category')
	,('Indian', 'This is Indian category');

CREATE TABLE Movies 
(
	Id INT IDENTITY PRIMARY KEY
	,Title  VARCHAR(20) NOT NULL
	,DirectorId INT FOREIGN KEY REFERENCES Directors(Id)
	,CopyrightYear DATE
	,[Length] INT
	,GenreId  INT FOREIGN KEY REFERENCES Genres(Id)
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id)
	,Rating  INT
	,Notes  VARCHAR(100)
);

INSERT INTO Movies
	(Title, DirectorId, CopyrightYear, [Length], GenreId,CategoryId, Rating, Notes)
VALUES 
	('Title 1', 1, '01-01-2022', 10, 1,1, 1, 'Notes for Title 1')
	,('Title 2', 2, '01-01-2022', 10, 2,2, 2, 'Notes for Title 2')
	,('Title 3', 3, '01-01-2022', 10, 3,3, 3, 'Notes for Title 3')
	,('Title 4', 4, '01-01-2022', 10, 4,4, 4, 'Notes for Title 4')
	,('Title 5', 5, '01-01-2022', 10, 5,5, 5, 'Notes for Title 5');

-- 14.	Car Rental Database

CREATE DATABASE CarRental;

CREATE TABLE Categories 
(
	Id INT IDENTITY PRIMARY KEY
	,CategoryName VARCHAR(20) NOT NULL
	,DailyRate SMALLINT
	,WeeklyRate SMALLINT
	,MonthlyRate SMALLINT
	,WeekendRate SMALLINT
);

INSERT INTO [Categories]
(
	CategoryName
	,DailyRate
	,WeeklyRate
	,MonthlyRate
	,WeekendRate
)
VALUES
	('Category 1', 1, 1, 1, 1)
	,('Category 2', 2, 2, 2, 2)
	,('Category 3', 3, 3, 3, 3)

CREATE TABLE Cars 
(
	Id INT IDENTITY PRIMARY KEY
	,PlateNumber INT
	,Manufacturer VARCHAR(20) NOT NULL
	,Model VARCHAR(20) NOT NULL
	,CarYear DATE  NOT NULL
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
	,Doors INT DEFAULT 4
	,Picture VARBINARY(MAX)
	,Condition VARCHAR(40)
	,Available BIT DEFAULT 0 NOT NULL
);

INSERT INTO Cars 
	(PlateNumber, Manufacturer, Model, CarYear, CategoryId)
VALUES
	(111, 'Mercedes', 'G500', '01-01-2020', 1)
	,(222, 'BMW', '5', '01-01-2020', 2)
	,(333, 'AUDI', 'A', '01-01-2020', 3)

CREATE TABLE Employees 
(
	Id INT IDENTITY PRIMARY KEY
	,FirstName VARCHAR(20) NOT NULL
	,LastName VARCHAR(20) NOT NULL
	,Title VARCHAR(20) 
	,Notes VARCHAR(40)
);

INSERT INTO Employees (FirstName, LastName, Title)
VALUES
	('Pesho', 'Pesho', 'Bai Pesho')
	,('Gosho', 'Gosho', 'Bai Gosho')
	,('Mosho', 'Mosho', 'Bai Mosho');

CREATE TABLE Customers 
(
	Id INT IDENTITY PRIMARY KEY
	,DriverLicenceNumber INT NOT NULL
	,FullName VARCHAR(20) NOT NULL
	,[Address] VARCHAR(40)
	,City VARCHAR(20)
	,ZIPCode TINYINT
	,Notes VARCHAR(40)
);

INSERT INTO Customers 
	(DriverLicenceNumber, FullName)
VALUES
	(0101, 'Pesho')
	,(0202, 'Gosho')
	,(0303, 'Mosho');

CREATE TABLE RentalOrders 
(
	Id INT IDENTITY PRIMARY KEY
	,EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
	,CustomerId INT FOREIGN KEY REFERENCES Customers(Id)
	,CarId INT FOREIGN KEY REFERENCES Cars(Id)
	,TankLevel TINYINT NOT NULL
	,KilometrageStart SMALLINT NOT NULL
	,KilometrageEnd SMALLINT NOT NULL
	,TotalKilometrage SMALLINT NOT NULL
	,StartDate DATE
	,EndDate DATE
	,TotalDays SMALLINT
	,RateApplied TINYINT
	,TaxRate TINYINT
	,OrderStatus BIT DEFAULT 0
	,Notes VARCHAR(40)
);

INSERT INTO RentalOrders 
	(EmployeeId, CustomerId, CarId,TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage)
VALUES
	(1, 1, 1, 10, 100, 200, 1000)
	,(2, 2, 2, 20, 200, 400, 2000)
	,(3, 3, 3, 30, 300, 600, 3000);

-- 15.	Hotel Database

CREATE DATABASE Hotel;

CREATE TABLE Employees 
(
	Id INT IDENTITY PRIMARY KEY
	,FirstName VARCHAR(20) NOT NULL
	,LastName VARCHAR(20) NOT NULL
	,Title VARCHAR(20)
	,Notes VARCHAR(40)
);

INSERT INTO Employees (FirstName, LastName)
VALUES 
	('Ivan', 'Ivanov')
	,('Georgi', 'Georgiev')
	,('Petar', 'Petrov');

CREATE TABLE Customers 
(
	Id INT IDENTITY PRIMARY KEY
	,AccountNumber INT NOT NULL
	,FirstName VARCHAR(20) NOT NULL
	,LastName VARCHAR(20) NOT NULL
	,PhoneNumber VARCHAR(20)
	,EmergencyName VARCHAR(20)
	,EmergencyNumber VARCHAR(20)
	,Notes VARCHAR(40)
);
INSERT INTO Customers 
	(AccountNumber, FirstName, LastName)
VALUES 
	(111, 'Ivan', 'Ivanov')
	,(222,'Georgi', 'Georgiev')
	,(333, 'Petar', 'Petrov');

CREATE TABLE RoomStatus 
(
	Id INT IDENTITY PRIMARY KEY
	,RoomStatus VARCHAR(10)
	,Notes VARCHAR(40)
);

INSERT INTO RoomStatus 
	(RoomStatus)
VALUES 
	('free')
	,('reserved')
	,('canceled');

CREATE TABLE RoomTypes 
(
	Id INT IDENTITY PRIMARY KEY
	,RoomType VARCHAR(10)
	,Notes VARCHAR(40)
);

INSERT INTO RoomTypes (RoomType)
VALUES 
	('single')
	,('double')
	,('apartment');

CREATE TABLE BedTypes 
(
	Id INT IDENTITY PRIMARY KEY
	,BedType VARCHAR(10)
	,Notes VARCHAR(40)
);

INSERT INTO BedTypes 
	(BedType)
VALUES 
	('single')
	,('double')
	,('king size');

CREATE TABLE Rooms 
(
	Id INT IDENTITY PRIMARY KEY
	,RoomNumber INt NOT NULL
	,RoomType INT FOREIGN KEY REFERENCES RoomTypes(Id)
	,BedType INT FOREIGN KEY REFERENCES BedTypes(Id)
	,Rate TINYINT DEFAULT 0
	,RoomStatus INT FOREIGN KEY REFERENCES RoomStatus(Id)
	,Notes VARCHAR(40)
);

INSERT INTO Rooms 
	(RoomNumber, RoomType, BedType, RoomStatus)
VALUES 
	(001, 1, 1, 1)
	,(002, 2, 2, 1)
	,(003, 3, 3, 1);


CREATE TABLE Payments 
(
	Id INT IDENTITY PRIMARY KEY
	,EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
	,PaymentDate DATE DEFAULT '01-01-2023'
	,AccountNumber INT NOT NULL
	,FirstDateOccupied DATE
	,LastDateOccupied DATE
	,TotalDays SMALLINT
	,AmountCharged FLOAT
	,TaxRate FLOAT
	,TaxAmount FLOAT
	,PaymentTotal FLOAT
	,Notes VARCHAR(40)
);

INSERT INTO Payments 
	(EmployeeId, AccountNumber)
VALUES 
	(1, 111)
	,(2, 222)
	,(3, 333);


CREATE TABLE Occupancies 
(
	Id INT IDENTITY PRIMARY KEY
	,EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
	,DateOccupied DATE DEFAULT '01-01-2023'
	,AccountNumber INT NOT NULL
	,RoomNumber INT FOREIGN KEY REFERENCES Rooms(Id)
	,RateApplied BIT DEFAULT 0
	,PhoneCharge BIT DEFAULT 0
	,Notes VARCHAR(40)
);

INSERT INTO Occupancies 
	(EmployeeId, AccountNumber)
VALUES 
	(1, 111)
	,(2, 222)
	,(3, 333);

-- 16.	Create SoftUni Database

--The Id columns are auto incremented, starting from 1 and increased by 1 (1, 2, 3, 4…). Make sure you use appropriate data types for each column. Add primary and foreign keys as constraints for each table. Use only SQL queries. Consider which fields are always required and which are optional.

CREATE DATABASE SoftUni;

CREATE TABLE Towns 
(
	Id INT IDENTITY PRIMARY KEY
	,[Name] VARCHAR(20) NOT NULL
);

CREATE TABLE Addresses (
	Id INT IDENTITY PRIMARY KEY
	,AddressText VARCHAR(20) NOT NULL
	,TownId INT FOREIGN KEY REFERENCES Towns(Id)
);

INSERT INTO Addresses 
	(AddressText, TownId)
VALUES 
	('Sofia adrress', 1)
	,('Varna adrress', 2)
	,('Montana adrress', 3);

CREATE TABLE Departments 
(
	Id INT IDENTITY PRIMARY KEY
	,[Name] VARCHAR(20) NOT NULL
);

CREATE TABLE Employees 
(
	Id INT IDENTITY(1,1) PRIMARY KEY
	,FirstName VARCHAR(20) NOT NULL
	,MiddleName VARCHAR(20)
	,LastName VARCHAR(20) NOT NULL
	,JobTitle VARCHAR(20)
	,DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
	,HireDate DATETIME2
	,Salary FLOAT DEFAULT 1000.00
	,AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
);

-- 17.	Backup Database

BACKUP DATABASE SoftUni
TO DISK = 'D:\Trash';

-- 18.	Basic Insert

INSERT INTO Towns ([Name])
VALUES 
	('Sofia'),
	('Plovdiv'),
	('Varna'),
	('Burgas');

INSERT INTO Departments ([Name])
VALUES 
	('Engineering'),
	('Sales'),
	('Marketing'),
	('Software Development'),
	('Quality Assurance');

INSERT INTO Employees 
	(FirstName, MiddleName, LastName, JobTitle,  DepartmentId, HireDate, Salary)
VALUES 
	('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
	('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
	('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
	('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00),
	('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88);

-- 19.	Basic Select All Fields

SELECT * FROM Towns;
SELECT * FROM Departments;
SELECT * FROM Employees;

-- 20.	Basic Select All Fields and Order Them

SELECT * FROM Towns
ORDER BY [Name];

SELECT * FROM Departments
ORDER BY [Name];

SELECT * FROM Employees
ORDER BY Salary DESC;

-- 21.	Basic Select Some Fields

SELECT [Name] FROM Towns
ORDER BY [Name];

SELECT [Name] FROM Departments
ORDER BY [Name];

SELECT FirstName, LastName, JobTitle, Salary 
FROM Employees
ORDER BY Salary DESC;

-- 22.	Increase Employees Salary

UPDATE Employees
SET Salary = Salary * 1.1;

SELECT Salary FROM Employees;

-- 23.	Decrease Tax Rate

UPDATE Payments
SET TaxRate = TaxRate * 0.97;

SELECT TaxRate FROM Payments;

-- 24.	Delete All Records

USE Hotel;
DELETE FROM Occupancies;
