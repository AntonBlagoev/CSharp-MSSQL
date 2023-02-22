-- 
--

CREATE DATABASE Boardgames
GO

USE Boardgames
GO

-- 01. DDL

	--Create a database called Boardgames. You need to create 7 tables:
	--•	Categories  – contains information about the boardgame's category name;
	--•	Addresses – contains information about the addresses of the boardgames' publishers;
	--•	Publishers – contains information about the boardgames' publishers;
	--•	PlayersRanges – contains information about the min and max count of players for each game;
	--•	Creators – contains information about the creators of the boardgames;
	--•	Boardgames – contains information about each boardgame;
	--•	CreatorsBoardgames – mapping table between creators and boardgames.

	--NOTE: Keep in mind that Judge doesn't accept "ALTER" statement and square brackets naming (when the names are not keywords).

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY
	,StreetName NVARCHAR(100) NOT NULL
	,StreetNumber INT NOT NULL
	,Town VARCHAR(30) NOT NULL
	,Country VARCHAR(50) NOT NULL
	,ZIP INT NOT NULL
)

CREATE TABLE Publishers
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(30) UNIQUE NOT NULL
	,AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
	,Website NVARCHAR(40)
	,Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges
(
	Id INT PRIMARY KEY IDENTITY
	,PlayersMin INT NOT NULL
	,PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(30) NOT NULL
	,YearPublished INT NOT NULL
	,Rating DECIMAL(18,2) NOT NULL
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
	,PublisherId INT FOREIGN KEY REFERENCES Publishers(Id) NOT NULL
	,PlayersRangeId INT FOREIGN KEY REFERENCES PlayersRanges(Id) NOT NULL
	
)

CREATE TABLE Creators
(
	Id INT PRIMARY KEY IDENTITY
	,FirstName NVARCHAR(30) NOT NULL
	,LastName NVARCHAR(30) NOT NULL
	,Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames
(
	CreatorId INT FOREIGN KEY REFERENCES Creators(Id) NOT NULL
	,BoardgameId INT FOREIGN KEY REFERENCES Boardgames(Id) NOT NULL
	,PRIMARY KEY (CreatorId, BoardgameId)
)

GO

-- 02. Insert
	-- Let's insert some sample data into the database. Write a query to add the following records into the corresponding tables. All IDs should be auto-generated.

INSERT INTO Publishers
VALUES
	('Agman Games', 5, 'www.agmangames.com', '+16546135542')
	,('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992')
	,('BattleBooks', 13, 'www.battlebooks.com', '+12345678907')

INSERT INTO Boardgames
VALUES
	('Deep Blue', '2019', 5.67, 1, 15, 7)
	,('Paris', '2016', 9.78, 7, 1, 5)
	,('Catan: Starfarers', '2021', 9.87, 7, 13, 6)
	,('Bleeding Kansas', '2020', 3.25, 3, 7, 4)
	,('One Small Step', '2019', 5.75, 5, 9, 2)

GO

-- 03. Update
	--We've decided to increase the maximum count of players for the boardgames with 1. Update the table PlayersRanges and increase the maximum players of the boardgames, which have a range of players [2,2].
	--Also, you have to change the name of the boardgames that were issued after 2020 inclusive. You have to add "V2" to the end of their names.

SELECT * FROM PlayersRanges 
SELECT * FROM Boardgames 

UPDATE PlayersRanges
SET PlayersMax += 1
WHERE PlayersMin = 2
AND PlayersMax = 2

UPDATE Boardgames
SET [Name] = CONCAT([Name], 'V2')
WHERE YearPublished >= '2020'

GO

-- 04. Delete
	-- In table Addresses, delete every country, which has a Town, starting with the letter 'L'. Keep in mind that there could be foreign key constraint conflicts.

DELETE FROM CreatorsBoardgames
WHERE BoardgameId IN 
(
	SELECT
		cb.BoardgameId
	FROM CreatorsBoardgames AS cb
	LEFT JOIN Boardgames AS bg ON cb.BoardgameId = bg.Id
	LEFT JOIN Publishers AS p ON bg.PublisherId = p.Id
	LEFT JOIN Addresses AS a ON p.AddressId = a.Id
	WHERE LEFT(a.Town,1) = 'L'
)

DELETE FROM Boardgames
WHERE Id IN 
(
	SELECT
		bg.Id
	FROM Boardgames AS bg
	LEFT JOIN Publishers AS p ON bg.PublisherId = p.Id
	LEFT JOIN Addresses AS a ON p.AddressId = a.Id
	WHERE LEFT(a.Town,1) = 'L'
)


DELETE FROM Publishers
WHERE AddressId IN (SELECT Id FROM Addresses WHERE LEFT(Town,1) = 'L')

DELETE FROM Addresses
WHERE LEFT(Town,1) = 'L'

GO

-- 05. Boardgames by Year of Publication

SELECT
	[Name]
	,Rating
FROM Boardgames
ORDER BY YearPublished, [Name] DESC

-- 06. Boardgames by Category

SELECT
	b.Id
	,b.[Name]
	,b.YearPublished
	,c.[Name] AS CategoryName
FROM Boardgames AS b
LEFT JOIN Categories AS c ON b.CategoryId = c.Id
WHERE c.[Name] IN ('Strategy Games', 'Wargames')
ORDER BY b.YearPublished DESC

GO

-- 07. Creators without Boardgames
	--Select all creators without boardgames. Order them by name (ascending).
	--Required columns:
	--•	Id
	--•	CreatorName (creators's first and last name, concatenated with space)
	--•	Email

SELECT
	c.Id
	,CONCAT_WS(' ', c.FirstName, c.LastName) AS CreatorName
	,c.Email
FROM Creators AS c
LEFT JOIN CreatorsBoardgames AS cb ON c.Id = cb.CreatorId
WHERE cb.CreatorId IS NULL
ORDER BY CreatorName

GO

-- 08. First 5 Boardgames

	--Select the first 5 boardgames that have rating, bigger than 7.00 and containing the letter 'a' in the boardgame name or the rating of a boardgame is bigger than 7.50 and the range of the min and max count of players is [2;5]. Order the result by boardgames name (ascending), then by rating (descending).
	--Required columns:
	--•	Name
	--•	Rating
	--•	CategoryName


SELECT TOP(5)
	b.[Name]
	,b.Rating
	,c.[Name] AS CategoryName
FROM Boardgames AS b 
LEFT JOIN Categories AS c ON b.CategoryId = c.Id
LEFT JOIN PlayersRanges AS pr ON b.PlayersRangeId = pr.Id
WHERE (b.Rating > 7 AND b.[Name] LIKE '%a%')
OR (b.Rating > 7.5 AND (pr.PlayersMin = 2 AND pr.PlayersMax = 5))
ORDER BY b.[Name], b.Rating DESC

GO

-- 09. Creators with Emails

	--Select all of the creators that have emails, ending in ".com", and display their most highly rated boardgame. Order by creator full name (ascending).
	--Required columns:
	--•	FullName
	--•	Email
	--•	Rating

SELECT
	CONCAT_WS(' ', c.FirstName, c.LastName) AS FullName
	,c.Email
	,MAX(b.Rating)
FROM Creators AS c
JOIN CreatorsBoardgames AS cb ON c.Id = cb.CreatorId
JOIN Boardgames AS b ON cb.BoardgameId = b.Id
WHERE SUBSTRING(c.Email,CHARINDEX('.', c.Email), LEN(c.Email)) = '.com'
GROUP BY c.FirstName, c.LastName, c.Email
ORDER BY FullName

GO

-- 10. Creators by Rating

	--Select all creators, who have created a boardgame. Select their last name, average rating (rounded up to the next biggest integer) and publisher's name. Show only the results for creators, whose games are published by "Stonemaier Games". Order the results by average rating (descending).

SELECT
	j.LastName
	,CEILING(j.AverageRating)
	,j.PublisherName
FROM
(
	SELECT
		c.LastName AS LastName
		,AVG(b.Rating) AS AverageRating
		,p.[Name] AS PublisherName
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb ON c.Id = cb.CreatorId
	JOIN Boardgames AS b ON cb.BoardgameId = b.Id
	JOIN Publishers AS p ON b.PublisherId = p.Id
	WHERE p.[Name] = 'Stonemaier Games'
	GROUP BY c.LastName, p.[Name]
) AS j
ORDER BY AverageRating DESC

GO

-- 11. Creator with Boardgames

	--Create a user-defined function, named udf_CreatorWithBoardgames(@name) that receives a creator's first name.
	--The function should return the total number of boardgames that the creator has created.

CREATE FUNCTION udf_CreatorWithBoardgames 
	(
		@name NVARCHAR(30)
	)
RETURNS INT
AS
BEGIN
	DECLARE @TotalNumberOfBoardgames INT

	SET @TotalNumberOfBoardgames = 
		(
			SELECT
				COUNT(cb.BoardgameId)
			FROM Creators AS c
			LEFT JOIN CreatorsBoardgames AS cb ON c.Id = cb.CreatorId
			WHERE c.FirstName = @name
			GROUP BY c.Id
		)
	RETURN ISNULL(@TotalNumberOfBoardgames, 0)
END

GO

SELECT dbo.udf_CreatorWithBoardgames('Bruno')
SELECT dbo.udf_CreatorWithBoardgames('Pesho')

GO

-- 12. Search for Boardgame with Specific Category

	--Create a stored procedure, named usp_SearchByCategory(@category) that receives category. The procedure must print full information about all boardgames with the given category: Name, YearPublished, Rating, CategoryName, PublisherName, MinPlayers and MaxPlayers. Add " people" at the end of the min and max count of people. Order them by PublisherName (ascending) and YearPublished (descending).

CREATE PROC usp_SearchByCategory
	(
		@category VARCHAR(50)
	)
AS
BEGIN
	
	SELECT
		bg.[Name]
		,bg.YearPublished
		,bg.Rating
		,c.[Name] AS CategoryName
		,p.[Name] AS PublisherName
		,CONCAT(pr.PlayersMin, ' people') AS MinPlayers
		,CONCAT(pr.PlayersMax, ' people') AS MaxPlayers
	FROM Boardgames AS bg
	LEFT JOIN Categories AS c ON bg.CategoryId = c.Id
	LEFT JOIN PlayersRanges AS pr ON bg.PlayersRangeId = pr.Id
	LEFT JOIN Publishers AS p ON bg.PublisherId = p.Id
	WHERE c.Name = @category
	ORDER BY p.[Name], bg.YearPublished DESC

END

GO

EXEC usp_SearchByCategory 'Wargames'
GO