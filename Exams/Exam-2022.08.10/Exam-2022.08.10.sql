-- Retake-Exam-10-Aug-2022
-- https://judge.softuni.org/Contests/3570/Databases-MSSQL-Server-Retake-Exam-10-Aug-2022

CREATE DATABASE NationalTouristSitesOfBulgaria
GO

USE NationalTouristSitesOfBulgaria
GO

-- 01. DDL

--Create a database called NationalTouristSitesOfBulgaria. You need to create 7 tables:
--•	Categories – contains information about the different categories of the tourist sites;
--•	Locations – contains information about the locations of the tourist sites;
--•	Sites – contains information about the tourist sites;
--•	Tourists – contains information about the tourists, who are visiting the tourist sites;
--•	SitesTourists – a many to many mapping table between the sites and the tourists;
--•	BonusPrizes – contains information about the bonus prizes, which are given to an annual raffle;
--•	TouristsBonusPrizes – a many to many mapping table between the tourists and the bonus prizes.

--NOTE: Keep in mind that Judge doesn't accept "ALTER" statement and square brackets naming (when the names are not keywords).
--NOTE: Use VARCHAR for strings, not NVARCHAR.

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(50) NOT NULL 
)

CREATE TABLE Locations
	(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(50) NOT NULL
	,Municipality VARCHAR(50)
	,Province VARCHAR(50)
)

CREATE TABLE Sites
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(100) NOT NULL
	,LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL
	,CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
	,Establishment VARCHAR(15)
)

CREATE TABLE Tourists
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(50) NOT NULL
	,Age INT CHECK (Age BETWEEN 0 AND 120) NOT NULL
	,PhoneNumber VARCHAR(20) NOT NULL
	,Nationality VARCHAR(30) NOT NULL
	,Reward VARCHAR(20)
)

CREATE TABLE SitesTourists
(
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL
	,SiteId INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL
	,PRIMARY KEY (TouristId, SiteId)
)

CREATE TABLE BonusPrizes
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes
(
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL
	,BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL
	,PRIMARY KEY (TouristId, BonusPrizeId)
)

GO

-- 02. Insert

INSERT INTO Tourists ([Name], Age, PhoneNumber, Nationality, Reward)
VALUES
	('Borislava Kazakova', 52, '+359896354244', 'Bulgaria', NULL)
	,('Peter Bosh', 48, '+447911844141', 'UK', NULL)
	,('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge')
	,('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge')
	,('Kremena Popova', 38, '+359893298604', 'Bulgaria', NULL)

INSERT INTO Sites ([Name], LocationId, CategoryId, Establishment)
VALUES
	('Ustra fortress', 90, 7, 'X')
	,('Karlanovo Pyramids', 65, 7, NULL)
	,('The Tomb of Tsar Sevt', 63, 8, 'V BC')
	,('Sinite Kamani Natural Park', 17, 1, NULL)
	,('St. Petka of Bulgaria – Rupite', 92, 6, '1994')

GO

-- 03. Update
	--For some of the tourist sites there are no clear records when they were established, so you need to update the column 'Establishment' for those records by putting the text '(not defined)'.

UPDATE Sites
SET Establishment = '(not defined)'
WHERE Establishment IS NULL

GO

-- 04. Delete
	--For this year's raffle it was decided to remove the Sleeping bag from the bonus prizes.

DELETE FROM TouristsBonusPrizes
WHERE BonusPrizeId = (SELECT Id FROM BonusPrizes WHERE [Name] = 'Sleeping bag')

DELETE FROM BonusPrizes
WHERE [Name] = 'Sleeping bag'

GO

-- 05. Tourists
	--Extract information about all the Tourists – name, age, phone number and nationality. Order the result by nationality (ascending), then by age (descending), and then by tourist name (ascending).

SELECT
	[Name]
	,Age
	,PhoneNumber
	,Nationality
FROM Tourists
ORDER BY Nationality, Age DESC, [Name]

GO

-- 06. Sites with Their Location and Category
	-- Select all sites and find their location and category. Select the name of the tourist site, name of the location,  establishment year/ century and name of the category. Order the result by name of the category (descending), then by name of the location (ascending) and then by name of the site itself (ascending).

SELECT
	s.[Name]
	,l.[Name]
	,s.Establishment
	,c.[Name]
FROM Sites AS s
LEFT JOIN Locations AS l ON s.LocationId = l.Id
LEFT JOIN Categories AS c ON s.CategoryId = c.Id
ORDER BY c.Name DESC, l.[Name], s.[Name]

GO

-- 07. Count of Sites in Sofia Province
	--Extract all locations which are in Sofia province. Find the count of sites in every location. Select the name of the province, name of the municipality, name of the location and count of the tourist sites in it. Order the result by count of tourist sites (descending) and then by name of the location (ascending).

SELECT
	l.Province
	,l.Municipality
	,l.[Name] AS [Location]
	,COUNT(s.Name) AS CountOfSites
FROM Locations AS l
JOIN Sites AS s ON l.Id = s.LocationId
WHERE l.Province = 'Sofia'
GROUP BY l.Province, l.Municipality,l .[Name], s.LocationId
ORDER BY CountOfSites DESC, [Location]

GO

-- 08. Tourist Sites established BC
	--Extract information about the tourist sites, which have a location name that does NOT start with the letters 'B', 'M' or 'D' and which are established Before Christ (BC). Select the site name, location name, municipality, province and establishment. Order the result by name of the site (ascending).
	--NOTE: If the establishment century is Before Christ (BC), it will always be in the following format: 'RomanNumeral BC'.

SELECT
	s.[Name]
	,l.Name AS [Location]
	,l.Municipality
	,l.Province
	,s.Establishment
FROM Sites AS s
JOIN Locations AS l ON s.LocationId = l.Id
WHERE LEFT(l.Name, 1) NOT IN ('B', 'M', 'D')
AND RIGHT(s.Establishment, 2) = 'BC' -- LIKE '%BC'
ORDER BY s.[Name]

GO

-- 09. Tourists with their Bonus Prizes
	--Extract information about the tourists, along with their bonus prizes. If there is no data for the bonus prize put '(no bonus prize)'. Select tourist's name, age, phone number, nationality and bonus prize. Order the result by the name of the tourist (ascending).
	--NOTE: There will never be a tourist with more than one prize.

SELECT 
	t.[Name]
	,t.Age
	,t.PhoneNumber
	,t.Nationality
	,ISNULL(bp.[Name], '(no bonus prize)') AS Reward
FROM Tourists AS t
LEFT JOIN TouristsBonusPrizes AS tbp ON t.Id = tbp.TouristId
LEFT JOIN BonusPrizes AS bp ON tbp.BonusPrizeId = bp.Id
ORDER BY t.[Name]

GO

-- 10. Tourists visiting History & Archaeology sites
	--Extract all tourists, who have visited sites from category 'History and archaeology'. Select their last name, nationality, age and phone number. Order the result by their last name (ascending).
	--NOTE: The name of the tourists will always be in the following format: 'FirstName LastName'.

SELECT
	SUBSTRING(t.[Name], CHARINDEX(' ', t.[Name]) + 1, LEN(t.[Name])) AS LastName
	,t.Nationality
	,t.Age
	,t.PhoneNumber
FROM Tourists AS t
LEFT JOIN SitesTourists AS st ON t.Id = st.TouristId
LEFT JOIN Sites AS s ON st.SiteId = s.Id
LEFT JOIN Categories AS c ON s.CategoryId = c.Id
WHERE c.[Name] = 'History and archaeology'
GROUP BY t.[Name], t.Nationality, t.Age, t.PhoneNumber
ORDER BY LastName

GO

-- 11. Tourists Count on a Tourist Site
	-- Create a user-defined function named udf_GetTouristsCountOnATouristSite (@Site) which receives a tourist site and returns the count of tourists, who have visited it.

CREATE FUNCTION udf_GetTouristsCountOnATouristSite 
	(
		@Site VARCHAR(50)
	)
RETURNS INT
BEGIN
	DECLARE @CountOfTourists INT

	SET @CountOfTourists =
	(
		SELECT 
			COUNT(s.[Name])
		FROM Tourists AS t
		LEFT JOIN SitesTourists AS st ON t.Id = st.TouristId
		LEFT JOIN Sites AS s ON st.SiteId = s.Id
		WHERE s.[Name] = @Site
		GROUP BY s.[Name]
	)

	RETURN @CountOfTourists
END

GO

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Regional History Museum – Vratsa')
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Samuil’s Fortress')
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Gorge of Erma River')

GO

-- 12. Annual Reward Lottery
	--A reward scheme has been developed to encourage collection of as many stamps as possible. Depending on the number of stamps collected, participants may receive bronze, silver or gold badges. 
	--Create a stored procedure, named usp_AnnualRewardLottery(@TouristName). Update the reward of the given tourist according to the count of the sites he have visited:
	--	>= 100 receives 'Gold badge'
	--	>= 50 receives 'Silver badge'
	--	>= 25 receives 'Bronze badge'
	--Extract the name of the tourist and the reward he has.

CREATE PROC usp_AnnualRewardLottery
	@TouristName VARCHAR(50)
AS
BEGIN
	DECLARE @TouristId INT
	SET @TouristId = (SELECT Id FROM Tourists WHERE [Name] = @TouristName)

	SELECT 
		t.[Name]
		,CASE
			WHEN COUNT(t.[Name]) >= 100 THEN 'Gold badge'
			WHEN COUNT(t.[Name]) >= 50 THEN 'Silver badge'
			WHEN COUNT(t.[Name]) >= 25 THEN 'Bronze badge'
		END AS Reward
	FROM Tourists AS t
	LEFT JOIN SitesTourists AS st ON t.Id = st.TouristId
	WHERE t.Id = @TouristId
	GROUP BY t.[Name]
END

EXEC usp_AnnualRewardLottery 'Gerhild Lutgard'
EXEC usp_AnnualRewardLottery 'Teodor Petrov'
EXEC usp_AnnualRewardLottery 'Zac Walsh'