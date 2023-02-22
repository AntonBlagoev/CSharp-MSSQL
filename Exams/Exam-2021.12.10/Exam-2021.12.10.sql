-- Retake-Exam-10-Dec-2021
-- https://judge.softuni.org/Contests/3301/Databases-MSSQL-Server-Retake-Exam-10-Dec-2021

CREATE DATABASE Airport
GO

USE Airport
GO

-- 01
	--Create a database called Airport. You need to create 7 tables:
	--•	Passengers – contains information about the passenger
	--		o	Each passenger has a full name column and an email column.
	--•	Pilots – contains information about the pilot 
	--		o	Each pilot has first and last name columns, an age column, and a rating column.
	--•	AircraftTypes – contains information about the aircraft type
	--		o	Contains the name of the type of aircraft.
	--•	Aircraft – contains information about the aircraft
	--		o	Each aircraft has a manufacturer, a model column, a year column, a flight hours column, a condition  column, and an aircraft type column.
	--•	PilotsAircraft – a many to many mapping tables between the aircraft and the pilots
	--		o	Have composite primary key from the AircraftId column and the PilotId column.
	--•	Airports – contains information about airport name and the country.
	--•	FlightDestinations – contains information about the flight destination
	--		o	Each flight destination has an airport Id column, a start column, an aircraft Id column, a passenger Id column, and a price of the ticket column.

CREATE TABLE Passengers
(
	Id INT PRIMARY KEY IDENTITY
	,FullName VARCHAR(100) NOT NULL UNIQUE
	,Email VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Pilots
(
	Id INT PRIMARY KEY IDENTITY
	,FirstName VARCHAR(30) NOT NULL UNIQUE
	,LastName VARCHAR(30) NOT NULL UNIQUE
	,Age TINYINT NOT NULL CHECK(Age BETWEEN 21 AND 62)
	,Rating FLOAT CHECK(Rating BETWEEN 0.0 AND 10.0)
)
CREATE TABLE AircraftTypes
(
	Id INT PRIMARY KEY IDENTITY
	,TypeName VARCHAR(30) NOT NULL UNIQUE
)

CREATE TABLE Aircraft
(
	Id INT PRIMARY KEY IDENTITY
	,Manufacturer VARCHAR(25) NOT NULL
	,Model VARCHAR(30) NOT NULL
	,[Year] INT NOT NULL
	,FlightHours INT
	,Condition CHAR NOT NULL
	,TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL

)

CREATE TABLE PilotsAircraft
(
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL
	,PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL
	,PRIMARY KEY (AircraftId,PilotId)
)

CREATE TABLE Airports
(
	Id INT PRIMARY KEY IDENTITY
	,AirportName VARCHAR(70) UNIQUE NOT NULL
	,Country VARCHAR(100) UNIQUE NOT NULL
)


CREATE TABLE FlightDestinations
(
	Id INT PRIMARY KEY IDENTITY
	,AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL
	,[Start] DATETIME NOT NULL
	,AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL
	,PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
	,TicketPrice DECIMAL(18,2) DEFAULT 15 NOT NULL
)

GO

-- 02
	--Write a query to insert data into the Passengers table, based on the Pilots table. For all Pilots with an id between 5 and 15 (both inclusive), insert data in the Passengers table with the following values:
	--•	FullName  –  get the first and last name of the pilot separated by a single space
	--	o	Example – 'Lois Leidle'
	--•	Email – set it to start with full name with no space and add '@gmail.com' - 'FullName@gmail.com'
	--	o	 Example – 'LoisLeidle@gmail.com'


INSERT INTO Passengers (FullName, Email)
SELECT 
	CONCAT(p.FirstName, ' ', p.LastName)
	,CONCAT(p.FirstName, p.LastName,'@gmail.com' )
FROM Pilots AS p
WHERE p.Id BETWEEN 5 AND 15

GO

-- 03
	--Update all Aircraft, which:
	--•	Have a condition of 'C' or 'B' 
	--•	Have FlightHours Null or up to 100 (inclusive)
	--•	Have Year after 2013 (inclusive)
	-- By setting their condition to 'A'.

UPDATE Aircraft
SET Condition = 'A'
WHERE 
	(
	Condition IN ('C', 'B')
	AND [Year] >= '2013'
	AND (FlightHours IS NULL OR FlightHours <= 100)
	)
	

GO

-- 04
	-- Delete every passenger whose FullName is up to 10 characters (inclusive) long.

DELETE FROM Passengers
WHERE LEN(FullName) <= 10;

GO

-- 05
	--Extract information about all the Aircraft. Order the results by aircraft's FlightHours descending.
	--Required columns:
	--•	Manufacturer
	--•	Model
	--•	FlightHours
	--•	Condition

SELECT 
	Manufacturer
	,Model
	,FlightHours
	,Condition
FROM Aircraft
ORDER BY FlightHours DESC

GO

-- 06
	--Select pilots and aircraft that they operate. Extract the pilot's First, Last names, aircraft's Manufacturer, Model, and FlightHours. Skip all plains with NULLs and up to 304 FlightHours. Order the result by the FlightHours in descending order, then by the pilot's FirstName alphabetically. 
	--Required columns:
	--•	FirstName
	--•	LastName
	--•	Manufacturer
	--•	Model
	--•	FlightHours

SELECT
	p.FirstName
	,p.LastName
	,a.Manufacturer
	,a.Model
	,a.FlightHours
FROM Pilots AS p
LEFT JOIN PilotsAircraft AS pa ON p.Id = pa.PilotId
LEFT JOIN Aircraft AS a ON pa.AircraftId = a.Id
WHERE a.FlightHours IS NOT NULL AND a.FlightHours < 304
ORDER BY a.FlightHours DESC, p.FirstName

GO

-- 07
	--Select top 20  flight destinations, where Start day is an even number. Extract DestinationId, Start date, passenger's FullName, AirportName, and TicketPrice. Order the result by TicketPrice descending, then by AirportName ascending.
	--Required columns:
	--•	DestinationId
	--•	Start
	--•	FullName (passenger)
	--•	AirportName
	--•	TicketPrice

SELECT TOP 20
	fd.Id AS DestinationId
	,fd.[Start]
	,p.FullName
	,a.AirportName
	,fd.TicketPrice
FROM FlightDestinations AS fd
LEFT JOIN Airports AS a ON fd.AirportId = a.Id
LEFT JOIN Passengers AS p ON fd.PassengerId = p.Id
WHERE DATEPART(DAY,fd.[Start]) % 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName

GO

-- 08
	--Extract information about all the Aircraft and the count of their FlightDestinations. Display average ticket price (AvgPrice) of each flight destination by the Aircraft, rounded to the second digit. Take only the aircraft with at least 2  FlightDestinations. Order the results by count of flight destinations descending, then by the aircraft's id ascending. 
	--Required columns:
	--•	AircraftId
	--•	Manufacturer
	--•	FlightHours
	--•	FlightDestinationsCount
	--•	AvgPrice

SELECT
	a.Id
	,a.Manufacturer
	,fh.SumFlightHours AS FlightHours
	,fd.CountAirportId AS FlightDestinationsCount
	,fd.AvgTicketPrice AS AvgPrice
FROM Aircraft AS a
LEFT JOIN 
	(	
		SELECT
			AircraftId
			,COUNT(AirportId) AS CountAirportId
			,ROUND(AVG(TicketPrice),2) AS AvgTicketPrice
		FROM FlightDestinations
		GROUP BY AircraftId
	) AS fd	ON a.Id = fd.AircraftId
LEFT JOIN
	(
		SELECT
			Id
			,SUM(FlightHours) AS SumFlightHours
		FROM Aircraft
		GROUP BY Id
	) AS fh ON a.Id = fh.Id
WHERE fd.CountAirportId >= 2
ORDER BY fd.CountAirportId DESC, a.Id

GO

-- v.2

SELECT
	a.Id AS AircraftId
	,a.Manufacturer
	,a.FlightHours
	,COUNT(fd.AirportId) AS FlightDestinationsCount
	,ROUND(AVG(fd.TicketPrice),2) AS AvgPrice
FROM Aircraft AS a
LEFT JOIN FlightDestinations AS fd	ON a.Id = fd.AircraftId
GROUP BY a.Id, a.Manufacturer, a.FlightHours
HAVING COUNT(fd.Id) >= 2
ORDER BY COUNT(fd.AirportId) DESC, a.Id

-- 09
	--Extract all passengers, who have flown in more than one aircraft and have an 'a' as the second letter of their full name. Select the full name, the count of aircraft that he/she traveled, and the total sum which was paid.
	--Order the result by passenger's FullName.
	--Required columns:
	--•	FullName
	--•	CountOfAircraft
	--•	TotalPayed

SELECT
	FullName
	,fd.CountOfAircraft
	,fd.TotalPayed
FROM Passengers AS p
LEFT JOIN 
	(	
		SELECT
			PassengerId
			,COUNT(AircraftId) AS CountOfAircraft
			,SUM(TicketPrice) AS TotalPayed
		FROM FlightDestinations
		GROUP BY PassengerId
	) AS fd	ON p.Id = fd.PassengerId
WHERE SUBSTRING(p.FullName, 2, 1) = 'a'
AND fd.CountOfAircraft > 1
ORDER BY p.FullName;

GO

-- v.2

SELECT
	p.FullName
	,COUNT(fd.AircraftId) AS CountOfAircraft
	,SUM(fd.TicketPrice) AS TotalPayed
FROM Passengers AS p
LEFT JOIN FlightDestinations AS fd	ON p.Id = fd.PassengerId
GROUP BY p.FullName
HAVING SUBSTRING(p.FullName, 2, 1) = 'a'
AND COUNT(fd.AircraftId) > 1
ORDER BY p.FullName;

-- 10
	--Extract information about all flight destinations which Start between hours: 6:00 and 20:00 (both inclusive) and have ticket prices higher than 2500. Select the airport's name, time of the day,  price of the ticket, passenger's full name, aircraft manufacturer, and aircraft model. Order the result by aircraft model ascending.
	--Required columns:
	--•	AirportName 
	--•	DayTime
	--•	TicketPrice
	--•	FullName (passenger)
	--•	Manufacturer
	--•	Model

SELECT
	ap.AirportName
	,fd.[Start] AS DayTime
	,fd.TicketPrice
	,p.FullName
	,a.Manufacturer
	,a.Model
FROM FlightDestinations AS fd
LEFT JOIN Airports AS ap ON fd.AirportId = ap.Id
LEFT JOIN Passengers AS p ON fd.PassengerId = p.Id
LEFT JOIN Aircraft AS a ON fd.AircraftId = a.Id
WHERE CAST(fd.[Start] AS TIME) BETWEEN '06:00' AND '19:59'
AND fd.TicketPrice > 2500
--AND DATEPART(HOUR,fd.[Start]) >= 6
--AND DATEPART(HOUR,fd.[Start]) <= 19
--AND DATEPART(MINUTE, fd.[Start]) >= 0
--AND DATEPART(MINUTE, fd.[Start]) <= 59
ORDER BY a.Model;

GO

-- 11
	--Create a user-defined function named udf_FlightDestinationsByEmail(@email) that receives a passenger's email address and returns the number of flight destinations that the passenger has in the database.

CREATE FUNCTION udf_FlightDestinationsByEmail
	(
		@email VARCHAR(50)
	)
RETURNS INT
AS
BEGIN
	DECLARE @NumberOfFlightDestinations INT

	SET @NumberOfFlightDestinations =
	(
		SELECT
			COUNT(fd.PassengerId) AS CountOfPassengers
		FROM Passengers AS p
		LEFT JOIN FlightDestinations AS fd ON p.Id = fd.PassengerId
		WHERE p.Email = @email
		GROUP BY fd.PassengerId
	)

	RETURN @NumberOfFlightDestinations
END

GO

SELECT dbo.udf_FlightDestinationsByEmail ('PierretteDunmuir@gmail.com')
SELECT dbo.udf_FlightDestinationsByEmail('Montacute@gmail.com')
SELECT dbo.udf_FlightDestinationsByEmail('MerisShale@gmail.com')

GO

-- 12
	--	Create a stored procedure, named usp_SearchByAirportName, which accepts the following parameters:
	--•	airportName(with max length 70)
	--Extract information about the airport locations with the given airport name. The needed data is the name of the airport, full name of the passenger, level of the ticket price (depends on flight destination's ticket price: 'Low'– lower than 400 (inclusive), 'Medium' – between 401 and 1500 (inclusive), and 'High' – more than 1501), manufacturer and condition of the aircraft, and the name of the aircraft type.
	--Order the result by Manufacturer, then by passenger's full name.
	--Required columns:
	--•	AirportName
	--•	FullName (passenger)
	--•	LevelOfTickerPrice 
	--•	Manifacturer
	--•	Condition
	--•	TypeName (aircraft type)

CREATE PROC usp_SearchByAirportName
	@airportName VARCHAR(70)
AS
BEGIN
	SELECT
		ap.AirportName
		,p.FullName
		,CASE
			WHEN fd.TicketPrice <= 400 THEN 'Low'
			WHEN fd.TicketPrice > 1500 THEN 'High'
			ELSE 'Medium'
		END
		,ac.Manufacturer
		,ac.Condition
		,act.TypeName
	FROM Airports AS ap
	LEFT JOIN FlightDestinations AS fd ON ap.Id = fd.AirportId
	LEFT JOIN Passengers AS p ON fd.PassengerId = p.Id
	LEFT JOIN Aircraft AS ac ON fd.AircraftId = ac.Id
	LEFT JOIN AircraftTypes AS act ON ac.TypeId = act.Id
	WHERE ap.AirportName = @airportName
	ORDER BY ac.Manufacturer, p.FullName
END

GO

EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'

GO