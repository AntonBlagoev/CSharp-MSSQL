-- Exam-19-June-2022
-- https://judge.softuni.org/Contests/3533/Databases-MSSQL-Server-Exam-19-June-2022

CREATE DATABASE Zoo
GO

USE Zoo
GO

-- 01. DDL
	--Create a database called Zoo. You need to create 7 tables:
	--•	Owners – contains information about the owners of the animals;
	--•	AnimalTypes – contains information about the different animal types in the zoo;
	--•	Cages – contains information about the animal cages;
	--•	Animals – contains information about the animals;
	--•	AnimalsCages – a many-to-many mapping table between the animals and the cages;
	--•	VolunteersDepartments – contains information about the departments of the volunteers;
	--•	Volunteers – contains information about the volunteers.

CREATE TABLE Owners
(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR(50) NOT NULL
	,PhoneNumber VARCHAR(15) NOT NULL
	,Address VARCHAR(50)
)

CREATE TABLE AnimalTypes
(
	Id INT PRIMARY KEY IDENTITY
	,AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages
(
	Id INT PRIMARY KEY IDENTITY
	,AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE Animals
(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR(30) NOT NULL
	,BirthDate DATE NOT NULL
	,OwnerId INT FOREIGN KEY REFERENCES Owners(Id)
	,AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE AnimalsCages
(
	CageId INT NOT NULL FOREIGN KEY REFERENCES Cages(Id)
	,AnimalId INT NOT NULL FOREIGN KEY REFERENCES Animals(Id)
	,PRIMARY KEY (CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments
(
	Id INT PRIMARY KEY IDENTITY
	,DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers
(
	Id INT PRIMARY KEY IDENTITY
	,Name VARCHAR(50) NOT NULL
	,PhoneNumber VARCHAR(15) NOT NULL
	,Address VARCHAR(50)
	,AnimalId INT FOREIGN KEY REFERENCES Animals(Id)
	,DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)

GO

-- 02. Insert
	--Let's insert some sample data into the database. Write a query to add the following records into the corresponding tables. All Ids should be auto-generated.

INSERT INTO Animals (Name, BirthDate, OwnerId, AnimalTypeId)
VALUES
	('Giraffe', '2018-09-21', 21, 1)
	,('Harpy Eagle', '2015-04-17', 15, 3)
	,('Hamadryas Baboon', '2017-11-02', NULL, 1)
	,('Tuatara', '2021-06-30', 2, 4)

INSERT INTO Volunteers (Name, PhoneNumber, Address, AnimalId, DepartmentId)
VALUES
	('Anita Kostova','0896365412', 'Sofia, 5 Rosa str.', 15, 1)
	,('Dimitur Stoev','0877564223', NULL, 42, 4)
	,('Kalina Evtimova','0896321112', 'Silistra, 21 Breza str.', 9, 7)
	,('Stoyan Tomov','0898564100', 'Montana, 1 Bor str.', 18, 8)
	,('Boryana Mileva','0888112233', NULL, 31, 5)

GO

-- 03. Update
	--Kaloqn Stoqnov (a current owner, present in the database) came to the zoo to adopt all the animals, who don't have an owner. Update the records by putting to those animals the correct OwnerId.

UPDATE Animals
SET OwnerId = (SELECT Id FROM Owners WHERE Name = 'Kaloqn Stoqnov')
WHERE OwnerID IS NULL

GO

-- 04. Delete
	--The Zoo decided to close one of the Volunteers Departments - Education program assistant. Your job is to delete this department from the database. 
	--NOTE: Keep in mind that there could be foreign key constraint conflicts!

DELETE FROM Volunteers
WHERE DepartmentId = (SELECT Id FROM VolunteersDepartments WHERE DepartmentName = 'Education program assistant')

DELETE FROM VolunteersDepartments
WHERE DepartmentName = 'Education program assistant'

GO

-- 05. Volunteers
	--Extract information about all the Volunteers – name, phone number, address, id of the animal, they are responsible to and id of the department they are involved into. Order the result by name of the volunteer (ascending), then by the id of the animal (ascending) and then by the id of the department (ascending).

SELECT 
	Name
	,PhoneNumber
	,Address
	,AnimalId
	,DepartmentId
FROM Volunteers
ORDER BY Name, AnimalId, DepartmentId

GO

-- 06. Animals data
	--Select all animals and their type. Extract name, animal type and birth date (in format 'dd.MM.yyyy'). Order the result by animal's name (ascending).

SELECT
	a.Name
	,ant.AnimalType
	,FORMAT(a.BirthDate, 'dd.MM.yyyy') AS BirthDate
FROM Animals AS a
LEFT JOIN AnimalTypes AS ant ON a.AnimalTypeId = ant.Id
ORDER BY a.Name

GO

-- 07. Owners and Their Animals
	-- Extract the animals for each owner. Find the top 5 owners, who have the biggest count of animals. Select the owner's name and the count of the animals he owns. Order the result by the count of animals owned (descending) and then by the owner's name.

SELECT TOP 5
	o.Name AS [Owner]
	,COUNT(a.Name) AS CountOfAnimals
FROM Owners AS o
LEFT JOIN Animals AS a ON o.Id = a.OwnerId
GROUP BY o.Name
ORDER BY CountOfAnimals DESC

GO

-- 08. Owners, Animals and Cages
	--Extract information about the owners of mammals, the name of their animal and in which cage these animals are. Select owner's name and animal's name (in format 'owner-animal'), owner's phone number and the id of the cage. Order the result by the name of the owner (ascending) and then by the name of the animal (descending).

SELECT
	CONCAT(o.Name, '-', a.Name) AS OwnersAnimals
	,o.PhoneNumber
	,ac.CageId
FROM Owners AS o
JOIN Animals AS a ON o.Id = a.OwnerId
JOIN AnimalTypes AS ant ON a.AnimalTypeId = ant.Id
JOIN AnimalsCages AS ac ON a.Id = ac.AnimalId
WHERE ant.AnimalType = 'Mammals'
ORDER BY o.Name, a.Name DESC

GO

-- 09. Volunteers in Sofia
	--Extract information about the volunteers, involved in 'Education program assistant' department, who live in Sofia. Select their name, phone number and their address in Sofia (skip city's name). Order the result by the name of the volunteers (ascending).

SELECT
	Name
	,PhoneNumber
	,LTRIM(SUBSTRING(LTRIM(Address),8,50)) AS Address 
FROM Volunteers
WHERE Address LIKE '%Sofia%' AND DepartmentId = (SELECT Id FROM VolunteersDepartments WHERE DepartmentName = 'Education program assistant' )
ORDER BY Name

-- v.2
	--SELECT v.Name, v.PhoneNumber,
	--SUBSTRING(Address, CHARINDEX(',', Address) + 2, LEN(v.Address)) AS Address
	--FROM Volunteers AS v
	--JOIN VolunteersDepartments AS vd ON v.DepartmentId = vd.Id
	--WHERE vd.DepartmentName = 'Education program assistant'
	--AND v.Address LIKE ('%Sofia%')
	--ORDER BY v.Name

GO

-- 10. Animals for Adoption
	--Extract all animals, who does not have an owner and are younger than 5 years (5 years from '01/01/2022'), except for the Birds. Select their name, year of birth and animal type. Order the result by animal's name.

SELECT
	a.Name
	,YEAR(a.BirthDate)
	,ant.AnimalType
FROM Animals AS a
LEFT JOIN AnimalTypes AS ant ON a.AnimalTypeId = ant.Id
WHERE ant.AnimalType <> 'Birds' AND OwnerId IS NULL
AND DATEDIFF(YEAR, a.BirthDate, '2022-01-01') < 5
ORDER BY a.Name

GO

-- 11. All Volunteers in a Department
	--Create a user-defined function named udf_GetVolunteersCountFromADepartment (@VolunteersDepartment) that receives a department and returns the count of volunteers, who are involved in this department.

CREATE FUNCTION udf_GetVolunteersCountFromADepartment 
(
	@VolunteersDepartment VARCHAR(50)
)
RETURNS INT
AS
BEGIN
	DECLARE @VolunteersCount INT
	SET @VolunteersCount = 
	(
		SELECT 
			COUNT(vd.DepartmentName)
		FROM Volunteers AS v
		LEFT JOIN VolunteersDepartments AS vd ON v.DepartmentId = vd.Id
		WHERE vd.DepartmentName = @VolunteersDepartment
		GROUP BY vd.DepartmentName
	)
	RETURN @VolunteersCount
END

GO

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Guest engagement')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Zoo events')

GO

-- 12. Animals with Owner or Not
	--Create a stored procedure, named usp_AnimalsWithOwnersOrNot(@AnimalName). 
	--Extract the name of the owner of the given animal.  If there is no owner, put 'For adoption'.

CREATE PROC usp_AnimalsWithOwnersOrNot
(
	@AnimalName VARCHAR(30)
)
AS
BEGIN
	SELECT
		a.Name
		,CASE
			WHEN o.Name IS NULL THEN 'For adoption'
			ELSE o.Name
		END
		AS OwnersName
	FROM Animals AS a
	LEFT JOIN Owners AS o ON a.OwnerId = o.Id
	WHERE a.Name = @AnimalName
END

GO

EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'
EXEC usp_AnimalsWithOwnersOrNot 'Hippo'
EXEC usp_AnimalsWithOwnersOrNot 'Brown bear'

GO