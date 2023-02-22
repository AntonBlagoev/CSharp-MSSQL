-- 01. One-To-One Relationship
CREATE DATABASE Relations 

USE Relations

CREATE TABLE Passports 
(
	PassportID INT PRIMARY KEY IDENTITY(101,1)
	,PassportNumber VARCHAR (8) NOT NULL
);
CREATE TABLE Persons (
	PersonID INT PRIMARY KEY IDENTITY(1,1)
	,FirstName VARCHAR(50) NOT NULL
	,Salary DECIMAL(8, 2) NOT NULL
	,PassportID INT FOREIGN KEY (PassportID)  REFERENCES Passports(PassportID) UNIQUE NOT NULL
);

INSERT INTO Passports 
	(PassportNumber)
VALUES
	('N34FG21B')
	,('K65LO4R7')
	,('ZE657QP2')

INSERT INTO Persons 
	(FirstName, Salary, PassportID)
VALUES
	('Roberto', 43300.00, 102 )
	,('Tom', 56100.00, 103 )
	,('Yana', 60200.00, 101 )

-- 02. One-To-Many Relationship

CREATE TABLE Models 
(
	ModelID INT IDENTITY(101,1) PRIMARY KEY
	,[Name] VARCHAR(50)
	,ManufacturerID INT
);

CREATE TABLE Manufacturers (
	ManufacturerID INT IDENTITY(1,1) PRIMARY KEY
	,[Name] VARCHAR(50)
	,EstablishedOn DATE
);

ALTER TABLE Models
ADD CONSTRAINT FK_Models_Manufacturers FOREIGN KEY (ManufacturerID) 
REFERENCES Manufacturers(ManufacturerID)

INSERT INTO Manufacturers 
	([Name], EstablishedOn)
VALUES
	('BMW', '07/03/1916')
	,('Tesla', '01/01/2003')
	,('Lada', '01/05/1966')

INSERT INTO Models
	([Name], ManufacturerID)
VALUES 
	('X1', 1)
	,('i6', 1)
	,('Model S', 2)
	,('Model X', 2)
	,('Model 3', 2)
	,('Nova', 3)

-- 03. Many-To-Many Relationship

CREATE TABLE Students (
	StudentID INT IDENTITY(1,1) PRIMARY KEY
	,[Name] VARCHAR(50)
);

CREATE TABLE Exams (
	ExamID INT IDENTITY(101,1) PRIMARY KEY
	,[Name] VARCHAR(50)
);

CREATE TABLE StudentsExams (
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL
	,ExamID INT FOREIGN KEY REFERENCES Exams(ExamID) NOT NULL
);

ALTER TABLE StudentsExams
ADD CONSTRAINT PK_StudentsExams 
PRIMARY KEY (StudentID, ExamID)

INSERT INTO Students ([Name])
VALUES 
	('Mila')
	,('Toni')
	,('Ron')

INSERT INTO Exams ([Name])
VALUES 
	('SpringMVC')
	,('Neo4j')
	,('Oracle 11g')

INSERT INTO StudentsExams
VALUES
	(1, 101)
	,(1, 102)
	,(2, 101)
	,(3, 103)
	,(2, 102)
	,(2, 103)

-- 04. Self-Referencing

CREATE TABLE Teachers (
	TeacherID INT IDENTITY(101,1) PRIMARY KEY
	,[Name] VARCHAR(50)
	,ManagerID INT FOREIGN KEY REFERENCES Teachers(TeacherID) NULL
);

INSERT INTO Teachers 
	([Name], ManagerID)
VALUES
	('John', NULL)
	,('Maya', 106)
	,('Silvia', 106)
	,('Ted', 105)
	,('Mark', 101)
	,('Greta', 101)

-- 05. Online Store Database

CREATE TABLE ItemTypes 
(
	ItemTypeID INT IDENTITY PRIMARY KEY
	,[Name] VARCHAR(50)
);

CREATE TABLE Items 
(
	ItemID INT IDENTITY PRIMARY KEY
	,[Name] VARCHAR(50)
	,ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID)
);

CREATE TABLE Cities 
(
	CityID INT IDENTITY PRIMARY KEY
	,[Name] VARCHAR(50)
);

CREATE TABLE Customers 
(
	CustomerID INT IDENTITY PRIMARY KEY
	,[Name] VARCHAR(50)
	,Birthday DATE
	,CityID INT FOREIGN KEY REFERENCES Cities(CityID)
);

CREATE TABLE Orders 
(
	OrderID INT IDENTITY PRIMARY KEY
	,CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
	OrderID INT FOREIGN KEY REFERENCES Orders(OrderID) NOT NULL
	,ItemID INT FOREIGN KEY REFERENCES Items(ItemID) NOT NULL
	,CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, ItemID) 
);

-- 06. University Database

CREATE TABLE Majors 
(
	MajorID INT IDENTITY PRIMARY KEY
	,[Name] VARCHAR(50)
);

CREATE TABLE Students (
	StudentID INT IDENTITY PRIMARY KEY
	,StudentNumber INT
	,StudentName VARCHAR(50)
	,MajorID INT FOREIGN KEY REFERENCES Majors(MajorID)
);

CREATE TABLE Payments (
	PaymentID INT IDENTITY PRIMARY KEY
	,PaymentDate DATE
	,PaymentAmount FLOAT
	,StudentID INT FOREIGN KEY REFERENCES Students(StudentID)
);

CREATE TABLE Subjects (
	SubjectID INT IDENTITY PRIMARY KEY
	,SubjectName VARCHAR(50)
);

CREATE TABLE Agenda (
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID)
	,SubjectID INT FOREIGN KEY REFERENCES Subjects(SubjectID)
	,CONSTRAINT PK_StudentsSubjects PRIMARY KEY (StudentID, SubjectID) 
);

-- 07. SoftUni Design

-- Create an E/R Diagram of the SoftUni Database. There are some special relations you should check out:
-- •	Employees are self-referenced (ManagerID) 
-- •	Departments have One-to-One with the Employees (ManagerID)
-- •	Employees have One-to-Many (DepartmentID)
-- You might find it interesting how it looks on the diagram. 

-- 08. Geography Design
-- Create an E/R Diagram of the Geography Database.

-- 09. *Peaks in Rila

USE Geography
SELECT m.MountainRange, p.PeakName, p.Elevation 
FROM Mountains AS m
JOIN Peaks AS p 
ON p.MountainId = m.Id
WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC