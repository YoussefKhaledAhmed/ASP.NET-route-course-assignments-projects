/*********************************************************
 * File name: SQL_session11-part2-Triggers               *
 * Author: Youssef Khaled                                *
 * Date: 20/01/2026 | dd/mm/yyyy                         *
 * Description: Solving session_11 assignment part 2	 *
 *              Triggers part                            *
 *********************************************************/


/* Use StackOverFlow2010 DB */
USE StackOverflow2010;

-- Creating the AuditLogs table
CREATE TABLE dbo.AuditLogs
(
    AuditId       INT IDENTITY(1,1) NOT NULL,
    TableName     VARCHAR(100)  NULL,
    OperationType VARCHAR(20) NULL,   -- INSERT / UPDATE / DELETE
    UserId        INT NULL,
    ChangeDate    DATETIME,
    OldValue      NVARCHAR(500) NULL,
    NewValue      NVARCHAR(500) NULL,
    Details       NVARCHAR(500) NULL
);


/*************************************************************
Question 1:- 												 *
Create an AFTER INSERT trigger on the Posts table that logs  *
every new post creation into a ChangeLog table. 			 *
The log should include: 									 *
● Table name 												 *
● Action type 												 *
● User ID of the post owner 								 *
● Post title stored as new data								 *
**************************************************************/
GO
	CREATE OR ALTER TRIGGER Trg_AfterInsertPostsLog
	ON Posts
	AFTER INSERT
	AS
	BEGIN
		INSERT INTO AuditLogs(TableName, OperationType, UserId, Details)
			SELECT
				'Posts',
				'INSERT',
				I.OwnerUserId,
				'New Post added: '+ ISNULL( CAST(I.Title AS NVARCHAR(100)), '') 
			FROM inserted I
	END
GO

-- Testing the trigger
---- 1. Inserting into Posts table
INSERT INTO Posts(Body, CreationDate, LastActivityDate, PostTypeId, Score, 
                  ViewCount, OwnerUserId, Title)
VALUES('Testing body' , GETDATE() , GETDATE() , 1 , 100 , 100 , 1 , 'SQL-trigger study')

---- 2. Selecting the AuditLogs table to see the impact of the trigger:
SELECT * FROM AuditLogs


---------------------------------------------------------------------------------------------

/***********************************************************************
Question 2:-														   *
Create an AFTER UPDATE trigger on the Users table that tracks changes  *
to the Reputation column. 											   *
The trigger should: 												   *
● Log changes only when the reputation value actually changes 		   *
● Store both the old and new reputation values in the ChangeLog table  *
************************************************************************/
GO
	CREATE OR ALTER TRIGGER Trg_AfterUpdateUsersLog
	ON Users
	AFTER UPDATE
	AS
	BEGIN
		INSERT INTO AuditLogs(TableName , OperationType , UserId , 
		                      ChangeDate , OldValue , NewValue , Details)
			SELECT
				'Users',
				'UPDATE',
				I.Id,
				GETDATE(),
				D.Reputation, -- Old value
				I.Reputation, -- New value
				-- Details:
				(
				'User''s Reputation changed from '
				+ CAST(D.Reputation AS VARCHAR(50)) + ' to '
				+ CAST(I.Reputation AS VARCHAR(50))
				)
			FROM inserted I
			INNER JOIN deleted D
				ON I.Id = D.Id
	END
GO


-- Testing the trigger:
---- 1. Updating Reputation of a user in Users table
Update Users
SET Reputation += 10
WHERE Id = 1

---- 2. Selecting the AuditLogs table to see the impact of the trigger:
SELECT * FROM AuditLogs


---------------------------------------------------------------------------------------------

/***************************************************************************
Question 3:-															   *
Create an AFTER DELETE trigger on the Posts table that archives 		   *
deleted posts into a DeletedPosts table. 								   *
All relevant post information should be stored before the post is removed. *
****************************************************************************/

-- Creating the DeletedPosts table
CREATE TABLE dbo.DeletedPosts
(
	Id INT IDENTITY(1,1) NOT NULL,
	Title NVARCHAR(250),
	OwnerUserId INT NOT NULL,
	Score INT NOT NULL,
	CreationDate DATETIME
);

ALTER TABLE DeletedPosts
ADD PostID INT

-- After delete trigger
GO
	CREATE OR ALTER TRIGGER Trg_AfterDeletePostsLog
	ON Posts
	AFTER DELETE
	AS
	BEGIN
		INSERT INTO DeletedPosts(Title, OwnerUserId, Score, CreationDate, PostID)
		SELECT 
			D.Title,
			D.OwnerUserId,
			D.Score,
			D.CreationDate,
			D.Id
		FROM deleted D
	END
GO

-- Testing the trigger:
---- 1. Deleting a record from Posts table
DELETE Posts
WHERE Id = 89

---- 2. Selecting the AuditLogs table to see the impact of the trigger:
SELECT * FROM DeletedPosts

----------------------------------------------------
-- Note: you can execute the following query to    |
--       get the Posts that can be deleted in order|
--       to test this trigger                      |
----------------------------------------------------
SELECT 
	P.Id,
	V.PostId
FROM Votes V
RIGHT JOIN Posts P
ON V.PostId = P.Id
WHERE V.PostId IS NULL
ORDER BY P.Id


---------------------------------------------------------------

/********************************************************
Question 4:-											*
Create an INSTEAD OF INSERT trigger on a view named 	*
vw_NewUsers (based on the Users table). 				*
The trigger should: 									*
● Validate incoming data 								*
● Prevent insertion if the DisplayName is NULL or empty	*
*********************************************************/

GO
	-- Create view
	CREATE VIEW VW_NewUsers
	AS
	SELECT
		*
	FROM Users
GO

GO
	-- Create trigger
	CREATE OR ALTER TRIGGER Trg_VWNewUserInsteadOfInsert
	ON VW_NewUsers
	INSTEAD OF INSERT
	AS
	BEGIN
		IF EXISTS (
			SELECT 1 
			FROM inserted 
			WHERE DisplayName IS NULL OR DisplayName = ''
		)
		BEGIN
			;THROW 50001 , 'invalid display name',1
		END

		-- if no error happened then insert into users
		INSERT INTO Users
		SELECT * FROM inserted
	END
GO

--------------------------------------------------------------------

/*************************************************************
Question 5:-												 *
Create an INSTEAD OF UPDATE trigger on the Posts table that  *
prevents updates to the Id column. 							 *
Any attempt to update the Id column should be: 				 *
● Blocked 													 *
● Logged in the ChangeLog table 							 *
**************************************************************/
GO
	CREATE OR ALTER TRIGGER Trg_InsteadOfUpdateTrigger
	ON Posts
	INSTEAD OF UPDATE
	AS
	BEGIN
		-- Try block
		BEGIN TRY
			-- checking if Id column is being updated
			IF EXISTS(
				SELECT 1
				FROM inserted i
				INNER JOIN deleted d
				  ON i.Id != d.Id
			)
			BEGIN
				
				-- save this in the log table
				INSERT INTO AuditLogs(
								       TableName, OperationType, UserId, ChangeDate,
								       OldValue, NewValue, Details
							          )
				SELECT
					'Posts',
					'UPDATE',
					I.OwnerUserId,
					GETDATE(),
					d.Id,
					I.Id,
					'Post Id changed from '+ 
					CAST(d.Id AS VARCHAR(100)) + ' to '+
					CAST(i.Id AS VARCHAR(100))
				FROM inserted I
				INNER JOIN deleted D
				  ON I.Id != D.Id
				
				-- Throw error
				;THROW 50001 , 'Id can''nt be changed' , 1
			END

			-- if no Id is being changed --> UPDATE
			UPDATE Posts
			SET 
				AcceptedAnswerId = I.AcceptedAnswerId,
				AnswerCount = I.AnswerCount,
				Body = I.Body,
				ClosedDate = I.ClosedDate,
				CommentCount = I.CommentCount,
				CommunityOwnedDate = I.CommunityOwnedDate,
				CreationDate = I.CreationDate,
				FavoriteCount = I.FavoriteCount,
				LastActivityDate = I.LastActivityDate,
				LastEditDate = I.LastEditDate,
				LastEditorDisplayName = I.LastEditorDisplayName,
				LastEditorUserId = I.LastEditorUserId,
				OwnerUserId = I.OwnerUserId,
				ParentId = I.ParentId,
				PostTypeId = I.PostTypeId,
				Score = I.Score,
				Tags = I.Tags,
				Title = I.Title,
				ViewCount = I.ViewCount,
				isDeleted = I.isDeleted
			FROM Posts P
			INNER JOIN inserted I
			  ON I.Id = P.Id

		END TRY

		-- Catch block
		BEGIN CATCH
			SELECT ERROR_MESSAGE() AS ErrorMsg,
				   ERROR_NUMBER() AS ErrorNumber,
				   ERROR_SEVERITY() AS ErrorSeverity

			;THROW
		END CATCH
	END
GO


-------------------------------------------------------------------------

/*****************************************************
Question 6:-										 *
Create an INSTEAD OF DELETE trigger on the Comments  *
table that implements a soft delete mechanism. 		 *
Instead of deleting records:						 *
● Add an IsDeleted flag 							 *
● Mark records as deleted 							 *
● Log the soft delete operation 					 *
******************************************************/

GO
	CREATE OR ALTER PROC USP_addIsDeletedColumn
	AS
	BEGIN
		-- 1. Add an IsDeleted flag 
		-- Check if the IsDeleted column exists or not
		IF NOT EXISTS(
			SELECT 1 
			FROM sys.columns
			WHERE name = 'IsDeleted' 
				  AND
				  object_id = OBJECT_ID('dbo.Comments')
		)
		BEGIN
			
			-- Adding the IsDeleted column
			ALTER TABLE dbo.Comments
			ADD IsDeleted BIT NOT NULL
				CONSTRAINT DF_Posts_IsDeleted DEFAULT (0);

		END
	END
GO

-- adding the IsDeleted column
EXEC USP_addIsDeletedColumn

GO
	CREATE OR ALTER TRIGGER Trg_InsteadOfDeleteTrigger
	ON Comments
	INSTEAD OF DELETE
	AS
	BEGIN
		
		PRINT('Soft delete will be performed instead of hard delete')

		-- Soft delete the record
		UPDATE Comments
		SET IsDeleted = 1
		WHERE Id IN (SELECT Id FROM deleted);

	END
GO

-- testing the trigger
DELETE Comments
WHERE Id = 2

-- DLL Triggers:
-- Create ChangeLog table
CREATE TABLE ChangeLog
(
    LogId        INT IDENTITY PRIMARY KEY,
    EventType    NVARCHAR(100),
    ObjectName   NVARCHAR(256),
    SchemaName   NVARCHAR(256),
    LoginName    NVARCHAR(256),
    HostName     NVARCHAR(256),
    CommandText  NVARCHAR(MAX),
    EventTime    DATETIME DEFAULT GETDATE()
);


/****************************************************************
Question 7:-													*
Create a DDL trigger that prevents any table from being dropped *
in the database. Log all drop attempts to ChangeLog. 			*
*****************************************************************/
GO
	CREATE OR ALTER TRIGGER Trg_preventDropTable
	ON DATABASE
	FOR DROP_TABLE
	AS
	BEGIN
	DECLARE @LogData XML = EVENTDATA()
		-- LoginName --> SYSTEM_USER
		INSERT INTO ChangeLog(EventType, ObjectName, SchemaName, LoginName, HostName, CommandText)
		VALUES(
			'CREATE_TABLE',
			@LogData.value('(/EVENT_INSTANCE/ObjectName)[1]' , 'NVARCHAR(256)'),
			@LogData.value('(/EVENT_INSTANCE/SchemaName)[1]' , 'NVARCHAR(256)'),
			SYSTEM_USER,
			@LogData.value('(/EVENT_INSTANCE/LoginName)[1]' , 'NVARCHAR(256)'),
			@LogData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]' , 'NVARCHAR(MAX)')
		)
		PRINT ('dropping any table from this database is prevented')
		--ROLLBACK
	END
GO

-- Testing this DLL trigger
CREATE TABLE Test_PreventDropDLL(id INT IDENTITY)

DROP TABLE Test_PreventDropDLL

SELECT * FROM ChangeLog

--------------------------------------------------------------------------

/***********************************************************
Question 8:-											   *
Create a DDL trigger that logs all CREATE TABLE statements *
to the ChangeLog table, including the full SQL command.    *
************************************************************/

GO
	CREATE OR ALTER TRIGGER Trg_logAllCreateTableQueries
	ON DATABASE
	FOR CREATE_TABLE
	AS
	BEGIN
		DECLARE @LogData XML = EVENTDATA()
		-- LoginName --> SYSTEM_USER
		INSERT INTO ChangeLog(EventType, ObjectName, SchemaName, LoginName, HostName, CommandText)
		VALUES(
			'CREATE_TABLE',
			@LogData.value('(/EVENT_INSTANCE/ObjectName)[1]' , 'NVARCHAR(256)'),
			@LogData.value('(/EVENT_INSTANCE/SchemaName)[1]' , 'NVARCHAR(256)'),
			SYSTEM_USER,
			@LogData.value('(/EVENT_INSTANCE/LoginName)[1]' , 'NVARCHAR(256)'),
			@LogData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]' , 'NVARCHAR(MAX)')
		)
	END
GO

-- Test the DLL trigger
CREATE TABLE Test_DLL(id INT IDENTITY)

-- SELECT the ChangeLog table
SELECT * FROM ChangeLog

--------------------------------------------------------------------------

/*************************************************************
Question 9:-												 *
Create a DDL trigger that prevents any ALTER TABLE statement *
that attempts to drop a column from any table. 				 *
**************************************************************/

GO
	CREATE OR ALTER TRIGGER Trg_logAllUpdateTableQueries
	ON DATABASE 
	FOR ALTER_TABLE
	AS
	BEGIN
		SET NOCOUNT ON;

		-- Extract the Command
		DECLARE @SQLCommand NVARCHAR(MAX) = 
		EVENTDATA().value(
		'(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','NVARCHAR(MAX)'
		);

		IF @SQLCommand LIKE '%DROP%COLUMN%'
		BEGIN

			DECLARE @LogData XML = EVENTDATA()
			-- LoginName --> SYSTEM_USER
			INSERT INTO ChangeLog(EventType, ObjectName, SchemaName, LoginName, HostName, CommandText)
			VALUES(
				'DROP_COLUMN',
				@LogData.value('(/EVENT_INSTANCE/ObjectName)[1]' ,
							   'NVARCHAR(256)'),
				@LogData.value('(/EVENT_INSTANCE/SchemaName)[1]' ,
							   'NVARCHAR(256)'),
				SYSTEM_USER,
				@LogData.value('(/EVENT_INSTANCE/LoginName)[1]' ,
							   'NVARCHAR(256)'),
				@LogData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]' ,
							   'NVARCHAR(MAX)')
			)
			ROLLBACK;

			;THROW 50001 , 'Dropping column isn''t permitted', 1
		END
	END
GO

-- Test this trigger
---- Trying to drop a column in ChangeLog table
ALTER TABLE AuditLogs 
DROP COLUMN AuditId

SELECT * FROM ChangeLog


--------------------------------------------------------------------------

/**************************************************************
Question 10:-												  *
Create a single trigger on the Badges table that tracks 	  *
INSERT, UPDATE, and DELETE operations. 						  *
The trigger should: 										  *
● Detect the operation type using INSERTED and DELETED tables *
● Log the action appropriately in the ChangeLog table 		  *
***************************************************************/

GO
	CREATE OR ALTER TRIGGER Trg_BadgesAudit
	ON Badges
	AFTER UPDATE, INSERT, DELETE
	AS
	BEGIN
	
		---------------|
		-- 1. Update:  |
		---------------|
		IF EXISTS (SELECT 1 FROM inserted)
		AND EXISTS (SELECT 1 FROM deleted)
		BEGIN
			INSERT INTO ChangeLog(
				EventType,
				ObjectName,
				SchemaName,
				LoginName,
				HostName,
				CommandText,
				EventTime
			)
			SELECT
				'UPDATE',
				'Badges',
				'dbo',
				ORIGINAL_LOGIN(),
				HOST_NAME(),
				APP_NAME(),
				GETDATE() 

			INSERT INTO AuditLogs(
				TableName,
				OperationType,
				UserId,
				ChangeDate,
				OldValue,
				NewValue,
				Details
			)
			SELECT
				'Badges',
				'UPDATE',
				I.UserId,
				GETDATE(),
				D.Name,
				I.Name,
				'Badge name changed'
				FROM inserted I
				INNER JOIN deleted D
				  ON I.Id = D.Id
		END

		---------------|
		-- 2. INSERT:  |
		---------------|
		ELSE IF EXISTS (SELECT 1 FROM inserted)
		AND NOT EXISTS (SELECT 1 FROM deleted)
		BEGIN
			INSERT INTO ChangeLog(
				EventType,
				ObjectName,
				SchemaName,
				LoginName,
				HostName,
				CommandText,
				EventTime
			)
			SELECT
				'INSERT',
				'Badges',
				'dbo',
				ORIGINAL_LOGIN(),
				HOST_NAME(),
				APP_NAME(),
				GETDATE() 

			INSERT INTO AuditLogs(
				TableName,
				OperationType,
				UserId,
				ChangeDate,
				OldValue,
				NewValue,
				Details
			)
			SELECT
				'Badges',
				'INSERT',
				UserId,
				GETDATE(),
				Name,
				Name,
				'New badge inserted'
				FROM inserted I
		END

		---------------|
		-- 3. DELETE:  |
		---------------|
		ELSE IF NOT EXISTS (SELECT 1 FROM inserted)
		AND EXISTS (SELECT 1 FROM deleted)
		BEGIN
			INSERT INTO ChangeLog(
				EventType,
				ObjectName,
				SchemaName,
				LoginName,
				HostName,
				CommandText,
				EventTime
			)
			SELECT
				'DELETE',
				'Badges',
				'dbo',
				ORIGINAL_LOGIN(),
				HOST_NAME(),
				APP_NAME(),
				GETDATE() 

			INSERT INTO AuditLogs(
				TableName,
				OperationType,
				UserId,
				ChangeDate,
				OldValue,
				NewValue,
				Details
			)
			SELECT
				'Badges',
				'DELETE',
				UserId,
				GETDATE(),
				Name,
				Name,
				'a badge is deleted'
				FROM deleted
		END
	END
GO

-- Testing the trigger
---- 1. testing the UPDATE
UPDATE Badges
SET Name = 'teacher'
WHERE Id = 82946

-- Selecting the AuditLogs table and the ChangeLog
SELECT * FROM AuditLogs
SELECT * FROM ChangeLog

-----------------------------------------------------------------

/*********************************************************
Question 11:-											 *
Create a trigger that maintains summary statistics in a  *
PostStatistics table whenever posts are 				 *
inserted, updated, or deleted. 							 *
The trigger should update: 								 *
● Total number of posts 								 *
● Total score 											 *
● Average score for the affected users. 				 *
**********************************************************/

----------------------------------------------------------|
-- NOTE: here there was an easy solution that is to		  |
--       recalculate the statistics of the post			  |
--       from posts table again at every time the trigger |
--       fires, but here I chose another way to be better |
--       in performance.                                  | 
----------------------------------------------------------|

-- Create the postStatistics table
CREATE TABLE postStatistics(
	UserId INT,
	totalNumberOfPosts INT,
	totalScore INT,
	AvgScore FLOAT
)

-- adding basic records in the postStatistics table 
-- where these records should be edited later.
INSERT INTO postStatistics( UserId , totalNumberOfPosts , totalScore , AvgScore)
SELECT 
	OwnerUserId, 
	COUNT(*),
	SUM(Score),
	AVG(Score)
FROM Posts
GROUP BY OwnerUserId


GO
	CREATE OR ALTER TRIGGER Trg_PostStats
	ON Posts
	AFTER UPDATE, INSERT, DELETE
	AS
	BEGIN
	
		---------------|
		-- 1. UPDATE:  |
		---------------|
		IF EXISTS (SELECT 1 FROM inserted)
		AND EXISTS (SELECT 1 FROM deleted)
		BEGIN
			-- typing in the result window that UPDATE 
			-- happened.
			SELECT 'UPDATE here';

			-- a CTE to do the following:
			-- 1. calculate the total score difference 
			--    (new value - old value) this will be 
			--    subtracted from the totalScore column 
			--    in the postStatistics
			-- 2. group the inserted table by the ownerUserId
			WITH UpdateStats AS (
				SELECT 
					I.OwnerUserId,
					SUM(I.Score - D.Score) AS TotalScoreDifference
				FROM inserted I
				INNER JOIN deleted D 
				  ON I.Id = D.Id
				GROUP BY I.OwnerUserId
			)
			-- Updating the postStatistics table 
			-- the column of the user who wrote the 
			-- post only.
			UPDATE postStatistics
			
			SET 
				-- update the totalScore by adding the new calculated value 
				-- from the CTE
				totalScore = totalScore + u.TotalScoreDifference,
				
				-- update the AvgScore of the user in the postStatistics table
				-- by dividing the totalScore after updating it with the new value
				-- over the totalNumberOfPosts which shouldn't be changed as this isn't 
				-- INSERT or DELETE operation it's just update from the Score column
				AvgScore = CAST((totalScore + u.TotalScoreDifference) AS FLOAT) / totalNumberOfPosts
			FROM UpdateStats u
			WHERE UserId = u.OwnerUserId;

		END
		---------------|
		-- 2. INSERT:  |
		---------------|
		ELSE IF EXISTS (SELECT 1 FROM inserted)
		AND NOT EXISTS (SELECT 1 FROM deleted)
		BEGIN
			SELECT 'INSERT here';

			-- a CTE to do the following:
			-- 1. Summing all the Score of all inserted posts 
			--    that are related to each specific user
			-- 2. counting the number of posts inserted by each 
			--    user
			-- 3. group the inserted table by the ownerUserId
			WITH InsertStats AS (
				SELECT 
					I.OwnerUserId,
					SUM(I.Score) AS TotalInsertScore,
					COUNT(I.Id) AS InsertCount
				FROM inserted I
				GROUP BY I.OwnerUserId
			)
			
			-- Updating the postStatistics table 
			-- the column of the user who wrote the 
			-- post only.
			UPDATE postStatistics
			SET	
				-- updating the totalScore with the totalInsertScore
				-- value that's calculated by CTE
				totalScore = totalScore + I.TotalInsertScore,

				-- updating the average score as we did in the UPDATE
				-- operation
				AvgScore = (totalScore + I.TotalInsertScore)
						  /(totalNumberOfPosts + I.InsertCount)
			FROM InsertStats I
			WHERE UserId = I.OwnerUserId
		END

		---------------|
		-- 3. DELETE:  |
		---------------|
		ELSE IF NOT EXISTS (SELECT 1 FROM inserted)
		AND EXISTS (SELECT 1 FROM deleted)
		BEGIN
			SELECT 'DELETE here';

			-- a CTE to do the following:
			-- 1. Summing all the Score of all deleted posts 
			--    that are related to each specific user
			-- 2. counting the number of posts deleted by each 
			--    user
			-- 3. group the deleted table by the ownerUserId
			WITH DeleteStats AS (
				SELECT 
					D.OwnerUserId,
					SUM(D.Score) AS TotalDeleteScore,
					COUNT(D.Id) AS DeleteCount
				FROM deleted D
				GROUP BY D.OwnerUserId
			)
			-- Updating the postStatistics table 
			-- the column of the user who wrote the 
			-- post only.
			UPDATE postStatistics

			
			SET	
				-- updating the totalScore be subtracting the 
				-- totalDeletedScore value calculated by the CTE
				-- from the old totalScore value
				totalScore = totalScore - D.TotalDeleteScore,

				-- updating the AvgScore as we did in the UPDATE operation
				-- but, with one extra thing which is to check when we 
				-- subtract the number of the deleted posts from the 
				-- total number of existing posts that this won't be 0
				-- to prevent divide by zero
				AvgScore = CASE 
						   WHEN (totalNumberOfPosts - D.DeleteCount) > 0
						   THEN (totalScore - D.TotalDeleteScore) 
								/(totalNumberOfPosts - D.DeleteCount)
						   ELSE 0
						   END
			FROM DeleteStats D
			WHERE UserId = D.OwnerUserId
		END
		
	END
GO

-- Test the trigger:
---- 1. Update the score of a specific post
UPDATE Posts
SET Score = 700
WHERE Id = 25663

---- 2. get the id of the owner and some info about this specific post
SELECT OwnerUserId ,Id ,Score FROM Posts
WHERE Id = 25663

---- 3. SELECT all columns of postStatistics table of this user
SELECT * FROM postStatistics
WHERE UserId = 9

---- 4. optional for more investigation
SELECT OwnerUserId ,Id ,Score FROM Posts
WHERE OwnerUserId = 9


-----------------------------------------------------------------

/**************************************************************
Question 12:-												  *
Create an INSTEAD OF DELETE trigger on the Posts table 		  *
that prevents deletion of posts with a score greater than 100.* 
Any prevented deletion should be logged.					  *
***************************************************************/

-- First, create a log table for deletion attempts
CREATE TABLE DeleteAttemptLog (
    LogId INT PRIMARY KEY IDENTITY(1,1),
    PostId INT,
    PostScore INT,
    OwnerUserId INT,
    PostTitle NVARCHAR(MAX),
    AttemptedDeleteTime DATETIME DEFAULT GETDATE()
);


GO
	CREATE OR ALTER TRIGGER Trg_InsteadOfDeleteBasedOnScore
	ON Posts
	INSTEAD OF DELETE
	AS
	BEGIN
		SELECT 'Inside instead of delete trigger based on score' AS debuggingInfo
		
		-- logging the delete operation of posts with score
		-- higher than 100
		INSERT INTO DeleteAttemptLog(
			PostId,
			PostScore,
			OwnerUserId,
			PostTitle
		)
		SELECT 
			Id,
			Score,
			OwnerUserId,
			Title
		FROM deleted
		WHERE Score > 100


		-- DELETE posts with score less than 100
		DELETE FROM Posts
		WHERE Id IN (SELECT Id FROM deleted WHERE Score <= 100)
	END
GO


-- testing the trigger
---- 1. getting Ids of posts with score > 100
----    and no foreign keys
SELECT TOP(1)
    'Posts with score > 100',
	P.Id, P.Score 
FROM Posts P
LEFT JOIN Comments C
  ON P.Id = C.PostId
LEFT JOIN Votes V
  ON P.Id = V.PostId
WHERE P.Score > 100 AND 
	  C.Id IS NULL AND
	  V.Id IS NULL

---- 2. getting Ids of posts with score <= 100
----    and no foreign keys
SELECT TOP(1)
	'Posts with score <= 100',
	P.Id, P.Score 
FROM Posts P
LEFT JOIN Comments C
  ON P.Id = C.PostId
LEFT JOIN Votes V
  ON P.Id = V.PostId
WHERE P.Score <= 100 AND 
	  C.Id IS NULL AND
	  V.Id IS NULL

---- 3. attempting to delete both of them to test
----    the behavior of the trigger
DELETE FROM Posts
WHERE Id IN (4509854 , 2434)

---- 4. selecting the log table
SELECT * FROM DeleteAttemptLog

---- 5. Selecting posts that we tried to delete before
SELECT
	Id , Score
FROM Posts
WHERE Id IN (4509854 , 2434)

-----------------------------------------------------------------

/****************************************************
Question 13:-										*
Write the SQL commands required to: 				*
1. Disable a specific trigger on the Posts table 	*
2. Enable the same trigger again 					*
3. Check whether the trigger is currently enabled 	*
   or disabled. 									*
*****************************************************/

-- Selecting from sys.triggers to get some info about
-- the triggers that are on the Posts table
SELECT 
	name AS TrgName,
	(CASE 
		WHEN is_disabled = 0 THEN 'Enabled'
		WHEN is_disabled = 1 THEN 'Disabled'
	 END) AS TrgStatus
FROM sys.triggers
WHERE parent_id = OBJECT_ID('dbo.Posts');

-- Disable Trg_PostStats
DISABLE TRIGGER Trg_PostStats ON Posts

-- Selecting from sys.triggers to see the effect of 
-- disabling Trg_PostStats trigger
SELECT 
	name AS TrgName,
	(CASE 
		WHEN is_disabled = 0 THEN 'Enabled'
		WHEN is_disabled = 1 THEN 'Disabled'
	 END) AS TrgStatus
FROM sys.triggers
WHERE parent_id = OBJECT_ID('dbo.Posts');

-- ENABLE the trigger that we disabled
ENABLE TRIGGER Trg_PostStats ON Posts

-- Selecting from sys.triggers to see the effect of 
-- enabling again Trg_PostStats trigger
SELECT 
	name AS TrgName,
	(CASE 
		WHEN is_disabled = 0 THEN 'Enabled'
		WHEN is_disabled = 1 THEN 'Disabled'
	 END) AS TrgStatus
FROM sys.triggers
WHERE parent_id = OBJECT_ID('dbo.Posts');