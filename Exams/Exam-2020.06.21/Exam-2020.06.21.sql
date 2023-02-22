-- Exam-21-Jun-2020
-- https://judge.softuni.org/Contests/2479/Databases-MSSQL-Server-Exam-21-Jun-2020

CREATE DATABASE TripService
GO

USE TripService
GO

-- 01. DDL
	--Crеate a database called TripService. You need to create 6 tables:
	--●	Cities – contains information about cities and their countries;
	--●	Hotels – contains information about the hotels in the system;
	--●	Rooms – contains information about the rooms each hotel has;
	--●	Trips – contains information about each trip;
	--●	Accounts – contains information about the trip service users;
	--●	AccountsTrips – contains information about all accounts and their trips.

	--NOTE: Please keep in mind that in case you have to work with a date, you have to use the exact same data type, described in the models tables. For example, data type Date means that you have to use Date, DateTime means that you have to use DateTime. If you don't use the correct type, the Judge system won't accept your submission as correct.
	--NOTE: Keep in mind that Judge doesn't accept "ALTER" statement and square brackets naming (when the names are not keywords).

CREATE TABLE Cities
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(20) NOT NULL
	,CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(30) NOT NULL
	,CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL
	,EmployeeCount INT NOT NULL
	,BaseRate DECIMAL(18,2)
)

CREATE TABLE Rooms
(
	Id INT PRIMARY KEY IDENTITY
	,Price DECIMAL(18,2) NOT NULL
	,[Type] VARCHAR(20) NOT NULL
	,Beds INT NOT NULL
	,HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips
(
	Id INT PRIMARY KEY IDENTITY
	,RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL
	,BookDate DATE NOT NULL --CHECK(BookDate < ArrivalDate)
	,ArrivalDate DATE NOT NULL --CHECK(ArrivalDate < ReturnDate)
	,ReturnDate DATE NOT NULL
	,CancelDate DATE
)

CREATE TABLE Accounts
(
	Id INT PRIMARY KEY IDENTITY
	,FirstName VARCHAR(50) NOT NULL
	,MiddleName VARCHAR(20)
	,LastName VARCHAR(50) NOT NULL
	,CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL
	,BirthDate DATE NOT NULL
	,Email VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE AccountsTrips
(
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL
	,TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL
	,PRIMARY KEY (AccountId, TripId)
	,Luggage INT CHECK(Luggage >= 0) NOT NULL
)

ALTER TABLE Trips
ADD CHECK(ArrivalDate < ReturnDate)

ALTER TABLE Trips
ADD CHECK(BookDate < ArrivalDate)

GO

-- 02. Insert
	-- Insert some sample data into the database. Write a query to add the following records into the corresponding tables. All Ids should be auto-generated.

INSERT INTO Accounts
VALUES
	('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com')
	,('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com')
	,('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg')
	,('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips
VALUES
	( 101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02')
	,( 102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29')
	,( 103, '2013-07-17', '2013-07-23', '2013-07-24', NULL)
	,( 104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10')
	,( 109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)

GO

-- 03. Update
	-- Make all rooms’ prices 14% more expensive where the hotel ID is either 5, 7 or 9.

UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN (5, 7, 9)

GO

-- 04. Delete
	-- Delete all of Account ID 47's account's trips from the mapping table.

DELETE FROM AccountsTrips
WHERE AccountId = 47

DELETE FROM Accounts
WHERE Id = 47

GO

-- 05. EEE-Mails
	-- Select accounts whose emails start with the letter 'e'. Select their first and last name, their birthdate in the format "MM-dd-yyyy", their city name, and their Email.
	-- Order them by city name (ascending)

SELECT
	a.FirstName
	,a.LastName
	,FORMAT(a.BirthDate, 'MM-dd-yyyy')
	,c.[Name]
	,a.Email
FROM Accounts AS a
LEFT JOIN Cities AS c ON a.CityId = c.Id
WHERE LEFT(Email, 1) = 'e'
ORDER BY c.[Name]

GO

-- 06. City Statistics
	-- Select all cities with the count of hotels in them. Order them by the hotel count (descending), then by city name. Do not include cities, which have no hotels in them.

SELECT 
	c.[Name] AS City
	,COUNT(c.[Name]) AS Hotels
FROM Cities AS c
JOIN Hotels AS h ON c.Id = h.CityId
GROUP BY c.[Name]
ORDER BY Hotels DESC, City

-- 07. Longest and Shortest Trips
	--Find the longest and shortest trip for each account, in days. Filter the results to accounts with no middle name and trips, which are not cancelled (CancelDate is null).
	--Order the results by Longest Trip days (descending), then by Shortest Trip (ascending).

SELECT
	a.Id AS AccountId
	,CONCAT_WS(' ', a.FirstName, a.LastName) AS FullName
	,MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS LongestTrip
	,MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip
FROM Accounts AS a
JOIN AccountsTrips AS act ON a.Id = act.AccountId
JOIN Trips AS t ON act.TripId = t.Id
WHERE t.CancelDate IS NULL
AND a.MiddleName IS NULL
GROUP BY a.Id, a.FirstName, a.LastName
ORDER BY LongestTrip DESC, ShortestTrip

GO

-- 08. Metropolis
	-- Find the top 10 cities, which have the most registered accounts in them. Order them by the count of accounts (descending).

SELECT TOP(10)
	c.Id
	,c.[Name] AS City
	,c.CountryCode AS Country
	,COUNT(a.Id) AS Accounts
FROM Cities AS c
JOIN Accounts AS a ON c.Id = a.CityId
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY Accounts DESC

GO

-- 09. Romantic Getaways
	--Find all accounts, which have had one or more trips to a hotel in their hometown.
	--Order them by the trips count (descending), then by Account ID.

SELECT 
	a.Id
	,a.Email
	,c.[Name] AS City
	,COUNT(a.Id) AS Trips
FROM Accounts AS a
LEFT JOIN AccountsTrips AS act ON a.Id = act.AccountId
LEFT JOIN Trips AS t ON act.TripId = t.Id
LEFT JOIN Rooms AS r ON t.RoomId = r.Id
LEFT JOIN Hotels AS h ON r.HotelId = h.Id
LEFT JOIN Cities AS c ON a.CityId = c.Id
WHERE a.CityId = h.CityId
GROUP BY a.Id, a.Email, c.[Name]
HAVING COUNT(a.Id) > 0
ORDER BY Trips DESC, a.Id

GO

-- 10. GDPR Violation
	--Retrieve the following information about each trip:
	--•	Trip ID
	--•	Account Full Name
	--•	From – Account hometown
	--•	To – Hotel city
	--•	Duration – the duration between the arrival date and return date in days. If a trip is cancelled, the value is "Canceled"
	--Order the results by full name, then by Trip ID.

SELECT
	t.Id
	,CONCAT_WS(' ', a.FirstName, a.MiddleName, a.LastName) AS [Full Name]
	,c.[Name] AS [From]
	,ch.[Name] AS [To]
	,CASE
		WHEN t.CancelDate IS NULL THEN CONCAT(DATEDIFF(DAY,t.ArrivalDate, t.ReturnDate), ' days')
		ELSE 'Canceled'
	END 
	AS Duration
FROM Trips AS t
JOIN AccountsTrips AS act ON t.Id = act.TripId
LEFT JOIN Accounts AS a ON act.AccountId = a.Id
LEFT JOIN Cities AS c ON a.CityId = c.Id
LEFT JOIN Rooms AS r ON t.RoomId = r.Id
LEFT JOIN Hotels AS h ON r.HotelId = h.Id
LEFT JOIN Cities AS ch ON h.CityId = ch.Id
ORDER BY [Full Name], t.Id

GO

-- 11. Available Room

CREATE FUNCTION udf_GetAvailableRoom
	(
		@HotelId INT
		,@Date DATE
		,@People INT
	)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @Result VARCHAR(255) = 
	(
		SELECT 
		'Room ' + CAST(tmp.RoomId AS VARCHAR) + ': ' + tmp.RoomType + ' (' + CAST(tmp.Beds AS VARCHAR) + ' beds) - $' + CAST(tmp.TotalPrice AS VARCHAR)
		FROM
			(
				SELECT TOP(1) 
					r.Id AS RoomId, 
					r.[Type] AS RoomType,
					r.Beds AS Beds,
					(r.Price + h.BaseRate) * @People AS TotalPrice
				FROM Rooms AS r
				JOIN Trips AS t ON r.Id = t.RoomId
				JOIN Hotels AS h ON r.HotelId = h.Id
				WHERE         
					HotelId = @HotelId 
					AND Beds >= @People
					AND r.Id NOT IN
					(
						SELECT RoomId FROM Trips
						WHERE @Date BETWEEN ArrivalDate AND ReturnDate 
						AND CancelDate IS NULL
					)
				ORDER BY TotalPrice DESC
			) AS tmp
	)


	RETURN ISNULL(@Result, 'No rooms available')
END

GO

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2) -- Room 211: First Class (5 beds) - $202.80
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3) -- No rooms available

GO

-- 12. Switch Room
	--Create a user defined stored procedure, named usp_SwitchRoom(@TripId, @TargetRoomId), that receives a trip and a target room and attempts to move the trip to the target room. A room will only be switched if all of these conditions are true:
	--•	If the target room ID is in a different hotel, than the trip is in, raise an exception with the message "Target room is in another hotel!".
	--•	If the target room doesn't have enough beds for all the trip's accounts, raise an exception with the message "Not enough beds in target room!".
	--If all the above conditions pass, change the trip's room ID to the target room ID.

CREATE PROC usp_SwitchRoom
	(
		@TripId INT
		,@TargetRoomId INT
	)
AS
BEGIN
	DECLARE @CurrentHotelId INT = 
		(
			SELECT r.HotelId 
			FROM Trips AS t 
			JOIN Rooms AS r ON t.RoomId = r.Id 
			WHERE t.Id = @TripId
		)
	DECLARE @TargetHotelId INT = 
		(
			SELECT HotelId 
			FROM Rooms 
			WHERE Id = @TargetRoomId
		)

	DECLARE @NeededBedsCount INT = 
		(
			SELECT COUNT(*) 
			FROM Accounts AS a
			JOIN AccountsTrips AS at ON a.Id = at.AccountId
			JOIN Trips AS t ON at.TripId = t.Id
			WHERE t.Id = @TripId
		)

	--IF (@CurrentHotelId <> @TargetHotelId) THROW 50001, 'Target room is in another hotel!', 1
	--IF ((SELECT Beds FROM Rooms WHERE Id = @TargetRoomId) < @NeededBedsCount) THROW 50002, 'Not enough beds in target room!', 1

	IF  (@CurrentHotelId <> @TargetHotelId)
	BEGIN
		SELECT 'Target room is in another hotel!'
		RETURN
	END
	
	IF ((SELECT Beds FROM Rooms WHERE Id = @TargetRoomId) < @NeededBedsCount)
	BEGIN
		SELECT 'Not enough beds in target room!'
		RETURN
	END

	UPDATE Trips
	SET RoomId = @TargetRoomId
	WHERE Id = @TripId

END

GO

EXEC usp_SwitchRoom 10, 11 SELECT RoomId FROM Trips WHERE Id = 10 -- 11
EXEC usp_SwitchRoom 10, 7 -- Target room is in another hotel!
EXEC usp_SwitchRoom 10, 8 -- Not enough beds in target room!

GO