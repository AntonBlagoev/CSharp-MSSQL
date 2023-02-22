-- Exam-16-October-2021
-- https://judge.softuni.org/Contests/3229/Databases-MSSQL-Server-Exam-16-October-2021

CREATE DATABASE CigarShop
GO

USE CigarShop
GO

-- 01. DDL
	--Create a database called CigarShop. You need to create 7 tables:
	--•	Sizes – contains information about the cigar's length and ring range;
	--•	Tastes – contains information about the cigar's taste type, taste strength, and image of the taste;
	--•	Brands – contains information about the cigar's brand name and brand description;
	--•	Cigars – contains information for every single cigar;
	--•	Addresses – contains information about the clients' address details;
	--•	Clients – contains information about the customers that buy cigars;
	--•	ClientsCigars – mapping table between clients and cigars.

	--NOTE: Keep in mind that Judge doesn't accept "ALTER" statement and square brackets naming (when the names are not keywords).

CREATE TABLE Sizes
(
	Id INT PRIMARY KEY IDENTITY
	,[Length] INT CHECK([Length] BETWEEN 10 AND 25) NOT NULL
	,RingRange DECIMAL(18,2) CHECK(RingRange BETWEEN 1.5 AND 7.5) NOT NULL
)

CREATE TABLE Tastes
(
	Id INT PRIMARY KEY IDENTITY
	,TasteType VARCHAR(20) NOT NULL
	,TasteStrength VARCHAR(15) NOT NULL
	,ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Brands
(
	Id INT PRIMARY KEY IDENTITY
	,BrandName VARCHAR(30) NOT NULL
	,BrandDescription VARCHAR(MAX)
)

CREATE TABLE Cigars
(
	Id INT PRIMARY KEY IDENTITY
	,CigarName VARCHAR(80) NOT NULL
	,BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL
	,TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL
	,SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL
	,PriceForSingleCigar DECIMAL(18,2) NOT NULL
	,ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY
	,Town VARCHAR(30) NOT NULL
	,Country NVARCHAR(30) NOT NULL
	,Streat NVARCHAR(100) NOT NULL
	,ZIP VARCHAR(20) NOT NULL
)

CREATE TABLE Clients
(
	Id INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR(30) NOT NULL
	,LastName NVARCHAR(30) NOT NULL
	,Email NVARCHAR(50) NOT NULL
	,AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)

CREATE TABLE ClientsCigars
(
	ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL
	,CigarId INT FOREIGN KEY REFERENCES Cigars(Id) NOT NULL
	,PRIMARY KEY (ClientId, CigarId)
)

GO

-- 02. Insert
	--Let us insert some sample data into the database. Write a query to add the following records into the corresponding tables. All IDs should be auto-generated.

INSERT INTO Addresses
	(Town, Country, Streat, ZIP)
VALUES
	('Sofia', 'Bulgaria', '18 Bul. Vasil levski', '1000')
	,('Athens', 'Greece', '4342 McDonald Avenue', '10435')
	,('Zagreb', 'Croatia', '4333 Lauren Drive', '10000')

INSERT INTO Cigars
	(CigarName, BrandId, TastId, SizeId, PriceForSingleCigar, ImageURL)
VALUES
	('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg')
	,('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg')
	,('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50, 'hoyo-du-maire-stick_17.jpg')
	,('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00, 'hoyo-de-san-juan-stick_20.jpg')
	,('TRINIDAD COLONIALES', 2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg')

GO

-- 03. Update
	--We've decided to increase the price of some cigars by 20%. Update the table Cigars and increase the price of all cigars, which TasteType is "Spicy" by 20%. Also add the text "New description" to every brand, which does not has BrandDescription.

UPDATE Cigars
SET PriceForSingleCigar *= 1.2
WHERE TastId = (SELECT Id FROM Tastes WHERE TasteType = 'Spicy')

UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL

-- 04. Delete
	--In table Addresses, delete every country which name starts with 'C', keep in mind that could be foreign key constraint conflicts.

DELETE FROM ClientsCigars
WHERE ClientId IN 
	(
		SELECT cc.ClientId FROM Addresses AS a
		LEFT JOIN Clients AS c ON a.Id = c.AddressId
		LEFT JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
		WHERE LEFT(a.Country, 1) = 'C'
	)

DELETE FROM Clients
WHERE Id IN 
	(
		SELECT c.Id FROM Addresses AS a
		LEFT JOIN Clients AS c ON a.Id = c.AddressId
		WHERE LEFT(a.Country, 1) = 'C'
	)

DELETE FROM Addresses
WHERE LEFT(Country, 1) = 'C'

GO

-- 05. Cigars by Price
	--Select all cigars ordered by price (ascending) then by cigar name (descending). 
	--Required columns
	--•	CigarName
	--•	PriceForSingleCigar
	--•	ImageURL

SELECT
	CigarName
	,PriceForSingleCigar
	,ImageURL
FROM Cigars
ORDER BY PriceForSingleCigar

GO

-- 06. Cigars by Taste
	--Select all cigars with "Earthy" or "Woody" tastes. Order results by PriceForSingleCigar (descending).
	--Required columns
	--•	Id
	--•	CigarName
	--•	PriceForSingleCigar
	--•	TasteType
	--•	TasteStrength

SELECT
	c.Id
	,c.CigarName
	,c.PriceForSingleCigar
	,t.TasteType
	,t.TasteStrength
FROM Cigars AS c
LEFT JOIN Tastes AS t ON c.TastId = t.Id
WHERE t.TasteType IN ('Earthy', 'Woody')
ORDER BY c.PriceForSingleCigar DESC

GO

-- 07. Clients without Cigars
	--Select all clients without cigars. Order them by name (ascending).
	--Required columns
	--•	Id
	--•	ClientName – customer's first and last name, concatenated with space
	--•	Email

SELECT
	Id
	,CONCAT_WS(' ', c.FirstName, c.LastName) AS ClientName
	,c.Email
FROM Clients AS c
LEFT JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
WHERE cc.ClientId IS NULL
ORDER BY ClientName

GO

-- 08. First 5 Cigars
	--Select the first 5 cigars that are at least 12cm long and contain "ci" in the cigar name or price for a single cigar is bigger than $50 and ring range is bigger than 2.55. Order the result by cigar name (ascending), then by price for a single cigar (descending).
	--Required columns
	--•	CigarName
	--•	PriceForSingleCigar
	--•	ImageURL

SELECT TOP 5
	c.CigarName
	,c.PriceForSingleCigar
	,c.ImageURL
FROM Cigars AS c
LEFT JOIN Sizes AS s ON c.SizeId = s.Id
WHERE s.Length >= 12
AND (c.CigarName LIKE '%ci%' OR PriceForSingleCigar > 50)
AND (s.RingRange > 2.55)
ORDER BY c.CigarName, c.PriceForSingleCigar DESC

GO

-- 09. Clients with ZIP Codes
	--Select all clients which have addresses with ZIP code that contains only digits, and display they're the most expensive cigar. Order by client full name ascending.
	--Required columns
	--•	FullName
	--•	Country
	--•	ZIP
	--•	CigarPrice – formated as "${CigarPrice}"

SELECT
	CONCAT_WS(' ', c.FirstName, c.LastName) AS FullName
	,a.Country
	,a.ZIP
	,CONCAT('$', MAX(cg.PriceForSingleCigar)) AS CigarPrice
FROM Clients AS c
JOIN Addresses AS a ON c.AddressId = a.Id
JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
JOIN Cigars AS cg ON cc.CigarId = cg.Id
WHERE PATINDEX('%[a-z]%', ZIP) = 0
GROUP BY c.FirstName,c.LastName,a.Country,a.ZIP
ORDER BY FullName

GO

-- 10. Cigars by Size
	--Select all clients which own cigars. Select their last name, average length, and ring range (rounded up to the next biggest integer) of their cigars. Order the results by average cigar length (descending).

SELECT

	c.LastName
	,AVG(s.[Length]) AS CiagrLength
	,CEILING(AVG(s.RingRange)) AS CiagrRingRange
FROM Clients AS c
JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
JOIN Cigars AS cg ON cc.CigarId = cg.Id
JOIN Sizes AS s ON cg.SizeId = s.Id
GROUP BY c.LastName
ORDER BY CiagrLength DESC

GO

-- 11. Client with Cigars
	--Create a user-defined function, named udf_ClientWithCigars(@name) that receives a client's first name.
	--The function should return the total number of cigars that the client has.

CREATE FUNCTION udf_ClientWithCigars
(	
	@name NVARCHAR(30)
)
RETURNS INT
AS
BEGIN
	DECLARE @NumberOfCigars INT

	SET @NumberOfCigars = 
		(
			SELECT
				Count(cc.ClientId)
			FROM Clients AS c
			JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
			WHERE c.FirstName = @name
		)

	RETURN @NumberOfCigars
END

SELECT dbo.udf_ClientWithCigars('Betty')

GO

-- 12. Search for Cigar with Specific Taste
	--Create a stored procedure, named usp_SearchByTaste(@taste), that receives taste type. The procedure must print full information about all cigars with the given tastes: CigarName, Price, TasteType, BrandName, CigarLength, CigarRingRange. Add '$' at the beginning of the price and "cm" at the end of both CigarLength and CigarRingRange. Order them by CigarLength (ascending), and CigarRingRange (descending).

CREATE PROC usp_SearchByTaste
	(
		@taste VARCHAR(20)
	)
AS
BEGIN
	
	SELECT
		c.CigarName
		,CONCAT('$',c.PriceForSingleCigar) AS Price
		,t.TasteType 
		,b.BrandName
		,CONCAT(s.[Length], ' cm') AS CigarLength
		,CONCAT(s.RingRange, ' cm') AS CigarRingRange
	FROM Cigars AS c
	JOIN Tastes AS t ON c.TastId = t.Id
	LEFT JOIN Brands AS b ON c.BrandId = b.Id
	LEFT JOIN Sizes AS s ON c.SizeId = s.Id
	WHERE t.TasteType = @taste
	ORDER BY CigarLength, CigarRingRange DESC

END

GO

EXEC usp_SearchByTaste 'Woody'

GO