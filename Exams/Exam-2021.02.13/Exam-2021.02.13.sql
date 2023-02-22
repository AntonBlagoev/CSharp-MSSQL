-- Exam-13-February-2021
-- https://judge.softuni.org/Contests/2820/Databases-MSSQL-Server-Exam-13-February-2021


CREATE DATABASE Bitbucket
GO

USE Bitbucket
GO

-- 01. DDL
-- Cråate a database called Bitbucket. You need to create 6 tables:
	--•	Users – contains information about the users
	--•	Repositories – contains information about the repositories
	--•	RepositoriesContributors – a many to many mapping table between the repositories and the users
	--•	Issues – contains information about the issues
		--o	Each issue has a repository
		--o	Each issue has an assignee (user)
	--•	Commits – contains information about the commits
		--o	Each commit MAY have an issue
		--o	Each commit has a repository
		--o	Each commit has a contributor (user)
	--•	Files – contains information about the files.
		--o	Each file MAY have a parent (file)
		--o	Each file has a commit
	--NOTE: Keep in mind that Judge doesn't accept "ALTER" statement and square brackets naming (when the names are not keywords).
	--NOTE: Use VARCHAR for strings, not NVARCHAR.

CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY
	,Username VARCHAR(30) NOT NULL
	,[Password] VARCHAR(30) NOT NULL
	,Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL
	,ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
	PRIMARY KEY(RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
	Id INT PRIMARY KEY IDENTITY
	,Title VARCHAR(255) NOT NULL
	,IssueStatus CHAR(6) NOT NULL
	,RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL
	,AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Commits
(
	Id INT PRIMARY KEY IDENTITY
	,[Message] VARCHAR(255) NOT NULL
	,IssueId INT FOREIGN KEY REFERENCES Issues(Id)
	,RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL
	,ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE tABLE Files
(
	Id INT PRIMARY KEY IDENTITY
	,[Name] VARCHAR(100) NOT NULL
	,Size DECIMAL(18,2) NOT NULL
	,ParentId INT FOREIGN KEY REFERENCES Files(Id)
	,CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL
)

GO

-- 02. Insert
	-- Insert some sample data into the database. Write a query to add the following records into the corresponding tables. All Ids should be auto-generated.

INSERT INTO Files
VALUES 
	('Trade.idk', 2598.0, 1, 1)
	,('menu.net', 9238.31, 2, 2)
	,('Administrate.soshy', 1246.93, 3, 3)
	,('Controller.php', 7353.15, 4, 4)
	,('Find.java', 9957.86, 5, 5)
	,('Controller.json', 14034.87, 3, 6)
	,('Operate.xix', 7662.92, 7, 7)

INSERT INTO Issues
VALUES
	('Critical Problem with HomeController.cs file', 'open', 1, 4)
	,('Typo fix in Judge.html', 'open', 4, 3)
	,('Implement documentation for UsersService.cs', 'closed', 8, 2)
	,('Unreachable code in Index.cs', 'open', 9, 8)

GO

-- 03. Update
	-- Make issue status 'closed' where Assignee Id is 6.

UPDATE Issues
SET IssueStatus = 'closed'
WHERE Id = 6

-- 04. Delete
	-- Delete repository "Softuni-Teamwork" in repository contributors and issues.

DELETE
FROM RepositoriesContributors
WHERE RepositoryId = (SELECT Id FROM Repositories WHERE [Name] = 'Softuni-Teamwork')

DELETE
FROM Issues
WHERE RepositoryId = (SELECT Id FROM Repositories WHERE [Name] = 'Softuni-Teamwork')

GO

--	05. Commits

	-- Select all commits from the database. Order them by id (ascending), message (ascending), repository id (ascending) and contributor id (ascending).

SELECT
	Id
	,[Message]
	,RepositoryId
	,ContributorId
FROM Commits
ORDER BY Id, [Message], RepositoryId, ContributorId

GO

-- 06. Front-end
	-- Select all of the files, which have size, greater than 1000, and a name containing "html". Order them by size (descending), id (ascending) and by file name (ascending).

SELECT
	Id
	,[Name]
	,Size
FROM Files
WHERE  Size > 1000 AND [Name] LIKE '%html%'
ORDER BY Size DESC, Id, [Name]

GO

-- 07. Issue Assignment
	-- Select all of the issues, and the users that are assigned to them, so that they end up in the following format: {username} : {issueTitle}. Order them by issue id (descending) and issue assignee (ascending).

SELECT
	i.Id
	,CONCAT_WS(' : ', u.Username, i.Title) AS IssueAssignee
FROM Issues AS i
JOIN Users AS u ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, i.AssigneeId

GO

-- 08. Single Files
	-- Select all of the files, which are NOT a parent to any other file. Select their size of the file and add "KB" to the end of it. Order them file id (ascending), file name (ascending) and file size (descending).

SELECT 
	f1.Id
	,f1.[Name]
	,CONCAT(f1.Size,'KB') AS Size
FROM Files AS f1
LEFT JOIN Files AS f2 ON f1.Id = f2.ParentId
WHERE f2.Id IS NULL
ORDER BY f1.Id, f1.[Name], f1.Size DESC

GO

-- 09. Commits in Repositories
	-- Select the top 5 repositories in terms of count of commits. Order them by commits count (descending), repository id (ascending) then by repository name (ascending).

SELECT TOP(5)
	c.RepositoryId AS Id
	,r.[Name]
	,COUNT(rc.RepositoryId) AS Commits
FROM Commits AS c
LEFT JOIN Repositories AS r ON c.RepositoryId = r.Id
LEFT JOIN RepositoriesContributors AS rc ON c.RepositoryId = rc.RepositoryId
GROUP BY c.RepositoryId, r.[Name]
ORDER BY COUNT(rc.RepositoryId) DESC, c.RepositoryId, r.[Name]

GO

-- 10. Average Size
	-- Select all users which have commits. Select their username and average size of the file, which were uploaded by them. Order the results by average upload size (descending) and by username (ascending).

SELECT
	u.Username 
	,AVG(f.Size) AS Size
FROM Commits AS c
JOIN Users AS u ON c.ContributorId = u.Id
JOIN Files AS f ON c.Id = f.CommitId
GROUP BY u.Username
ORDER BY Size DESC, u.Username

GO

-- 11. All User Commits
	-- Create a user defined function, named udf_AllUserCommits(@username) that receives a username.
	-- The function must return count of all commits for the user.

CREATE FUNCTION udf_AllUserCommits 
	(
		@username VARCHAR(30)
	)
RETURNS INT
AS
BEGIN
	DECLARE @CountOfCommits INT

	SET @CountOfCommits =
	(
		SELECT
			COUNT(u.Username)
		FROM Commits AS c
		JOIN Users AS u ON c.ContributorId = u.Id
		WHERE u.Username = @username
		GROUP BY c.ContributorId
	)

	RETURN ISNULL(@CountOfCommits, 0)
END

GO

SELECT dbo.udf_AllUserCommits('UnderSinduxrein') -- 6
SELECT dbo.udf_AllUserCommits('AryaDenotehow') -- 3
SELECT dbo.udf_AllUserCommits('Pesho') -- 0

GO

-- 12. Search for Files
	-- Create a user defined stored procedure, named usp_SearchForFiles(@fileExtension), that receives files extensions.
	-- The procedure must print the id, name and size of the file. Add "KB" in the end of the size. Order them by id (ascending), file name (ascending) and file size (descending).

CREATE PROC usp_SearchForFiles
(
	@fileExtension VARCHAR(100)
)
AS
BEGIN
	SELECT 
		Id
		,[Name]
		,CONCAT(Size, 'KB')
	FROM Files
	WHERE (SUBSTRING([Name], CHARINDEX('.', [Name]) + 1, LEN([Name]))) = @fileExtension
	ORDER BY Id, [Name], Size DESC
END

GO

EXEC usp_SearchForFiles 'txt'
GO