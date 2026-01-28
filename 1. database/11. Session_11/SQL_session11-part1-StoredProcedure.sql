/*********************************************************
 * File name: SQL_session11-part1-StoredProcedure        *
 * Author: Youssef Khaled                                *
 * Date: 18/01/2026 | dd/mm/yyyy                         *
 * Description: Solving session_11 assignment part 1	 *
 *              Stored procedure part                    *
 *********************************************************/


/* Use StackOverFlow2010 DB */
USE StackOverflow2010;


/********************************************************************
Question_1:- 														*
- Create a stored procedure named sp_GetRecentBadges that retrieves *
all badges earned by users within the last N days. 					*
- The procedure should accept one input parameter @DaysBack (INT) 	*
to determine how many days back to search. 							*
- Test the procedure using different values for the number of days.	*
*********************************************************************/

GO
	CREATE OR ALTER PROC USP_GetRecentBadges 
						 @DaysBack INT
	AS
	BEGIN
		SELECT
			Id,
			Name,
			UserId
		FROM Badges
		WHERE DATEDIFF(DAY, Date , GETDATE()) <= @DaysBack
	END
GO

-- testing th procedure
EXEC USP_GetRecentBadges 10000


-------------------------------------------------------------------

/************************************************************
Question 2:-												*
- Create a stored procedure named sp_GetUserSummary that 	*
  retrieves summary statistics for a specific user. 		*
- The procedure should accept @UserId as an input parameter *
  and return the following values as output parameters: 	*
● Total number of posts created by the user 				*
● Total number of badges earned by the user 				*
● Average score of the user’s posts 						*
*************************************************************/

GO
	CREATE OR ALTER PROC USP_GetUserSummary 
						 @UserId INT,
						 @TotalPostCount INT OUTPUT,
						 @TotalBadgeCount INT OUTPUT,
						 @AvgScore FLOAT OUTPUT
	AS
	BEGIN
		SELECT
			@TotalPostCount = COUNT(*) 
		FROM Posts
		WHERE OwnerUserId = @UserId

		SELECT
			@TotalBadgeCount = COUNT(*)
		FROM Badges
		WHERE UserId = @UserId

		SELECT
			@AvgScore = AVG(Score)
		FROM Posts
		WHERE OwnerUserId = @UserId
	END

GO

-- Testing the procedure
DECLARE @Testing_TotalPostCount INT;
DECLARE @Testing_TotalBadgeCount INT;
DECLARE @Testing_AvgScore FLOAT;

EXEC USP_GetUserSummary 
	 @UserId = 1, 
	 @TotalPostCount = @Testing_TotalPostCount OUTPUT,
	 @TotalBadgeCount = @Testing_TotalBadgeCount OUTPUT,
	 @AvgScore = @Testing_AvgScore OUTPUT


SELECT @Testing_TotalPostCount AS TotalPostCount,
	   @Testing_TotalBadgeCount AS TotalBadgeCount,
	   @Testing_AvgScore AS AvgScore

------------------------------------------------------------

/*************************************************************
Question 3:-												 *
- Create a stored procedure named sp_SearchPosts that 		 *
  searches for posts based on: 								 *
  ● A keyword found in the post title       				 *
  ● A minimum post score 									 *
- The procedure should accept @Keyword as an input parameter *
  and @MinScore as an optional parameter with a default 	 *
  value of 0.												 *
- The result should display matching posts ordered by score. *
**************************************************************/

GO
	CREATE OR ALTER PROC USP_SearchPosts
						 @Keyword VARCHAR(50),
						 @MinScore INT = 0
	AS
	BEGIN
		SELECT
			Id,
			Title,
			CreationDate,
			Score
		FROM Posts
		WHERE Title LIKE '%' + @Keyword + '%'
			  AND
			  Score >= @MinScore
		ORDER BY Score DESC
	END
GO

-- Testing the procedure
EXEC USP_SearchPosts @Keyword = 'Java'

------------------------------------------------------------

/******************************************************
Question 4:-										  *
- Create a stored procedure named sp_GetUserOrError   *
  that retrieves user details by user ID. 			  *
- If the specified user does not exist, the procedure *
  should raise a meaningful error. 					  *
- Use TRY…CATCH for proper error handling.			  *
*******************************************************/

GO
	CREATE OR ALTER PROC USP_GetUserOrError @UserId INT
	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			IF NOT EXISTS(SELECT 1 FROM Users WHERE Id = @UserId)
			BEGIN
				;THROW 50001 , 'User not found' , 1
			END

			-- selecting the user since it passed the IF condition
			SELECT
				Id,
				DisplayName,
				Reputation,
				Location
			FROM Users
			
		END TRY

		BEGIN CATCH
			SELECT ERROR_NUMBER() AS ErrorNumber,
				   ERROR_MESSAGE() AS ErrorMessage,
				   ERROR_SEVERITY() AS ErrorSeverity

			-- printing message on the console
			PRINT('Procedure failed')

			-- throw error to the caller
			;THROW
		END CATCH
	END
GO

-- Testing the procedure:-
-- Should fail
EXEC USP_GetUserOrError @UserId = 100011100

-- Should success
EXEC USP_GetUserOrError @UserId = 1


----------------------------------------------------------------------

/***************************************************************
Question 5:-												   *
Create a stored procedure named sp_AnalyzeUserActivity that:   *
● Calculates an Activity Score for a user using the formula:   *
  Reputation + (Number of Posts × 10) 						   *
● Returns the calculated Activity Score as an output parameter *
● Returns a result set showing the user’s top 5 posts ordered  *
  by score.													   *
****************************************************************/

GO
	CREATE OR ALTER PROC USP_AnalyzeUserActivity
						 @UserId INT,
						 @ActivityScore INT OUTPUT
	AS
	BEGIN
		SELECT
			@ActivityScore = Reputation + (
				SELECT COUNT(*) 
				FROM Posts
				WHERE OwnerUserId = @UserId
			) * 10
		FROM Posts P
		INNER JOIN Users U
		ON P.OwnerUserId = U.Id

		SELECT TOP(5)
			Id,
			Title,
			Score
		FROM Posts
		WHERE OwnerUserId = @UserId
		ORDER BY Score DESC
	END
GO

-- Testing the procedure
DECLARE @Testing_ActivityScore INT;

EXEC USP_AnalyzeUserActivity
	 @UserId = 1,
	 @ActivityScore = @Testing_ActivityScore


----------------------------------------------------------------------

/*********************************************************
Question 6:-											 *
Create a stored procedure named sp_GetReputationInOut 	 *
that uses a single input/output parameter. 				 *
The parameter should initially contain a UserId as input *
and return the corresponding user reputation as output.	 *
**********************************************************/

GO
	CREATE OR ALTER PROC USP_GetReputationInOut
						 -- stores Id and returns reputation
						 @UserInfo INT OUTPUT
	AS
	BEGIN
		SELECT @UserInfo AS UserId

		SELECT
			@UserInfo = Reputation
		FROM Users
		WHERE Id = @UserInfo
	END
GO

-- Testing the procedure
DECLARE @Testing_UserReputation INT = 1;

EXEC USP_GetReputationInOut 
	 @UserInfo = @Testing_UserReputation OUTPUT

SELECT @Testing_UserReputation AS UserReputation


----------------------------------------------------------------------

/****************************************************************
Question 7:-													*
Create a stored procedure named sp_UpdatePostScore that updates *
the score of a post. 											*
The procedure should: 											*
● Accept a post ID and a new score as input 					*
● Validate that the post exists 								*
● Use transactions and TRY…CATCH to ensure safe updates 		*
● Roll back changes if an error occurs 							*
*****************************************************************/

GO
	CREATE OR ALTER PROC USP_UpdatePostScore
						 @PostId INT,
						 @NewScore INT
	AS
	BEGIN
		-- Try:
		BEGIN TRY
			-- if post doesn't exist --> throw error
			IF NOT EXISTS(SELECT 1 FROM Posts WHERE Id = @PostId)
			BEGIN
				;THROW 50001 , 'Post not found' , 1
			END

			BEGIN TRAN;

			-- else (i.e., post exists) --> Update the score
			UPDATE Posts
				SET Score = @NewScore
				WHERE Id = @PostId

			COMMIT TRAN;
			SELECT 'Rows updated successfully' AS Result, @@ROWCOUNT AS NumOfAffectedRows
		END TRY

		-- Catch:
		BEGIN CATCH
			-- 1. print error info
			SELECT ERROR_NUMBER(),
				   ERROR_MESSAGE(),
				   ERROR_SEVERITY()
			-- 2. rollback the done proccesses
			IF(@@TRANCOUNT > 0)
				ROLLBACK;
			-- 3. Throw exception
			THROW;
		END CATCH
		
	END
GO

-- Testing the procedure
---- 1. before the procedure:
SELECT Score
FROM Posts
WHERE Id = 12

---- 2. Executing the procedure
EXEC USP_UpdatePostScore 
	 @PostId = 12,
	 @NewScore = 101

---- 3. After the procedure
SELECT Score
FROM Posts
WHERE Id = 12

----------------------------------------------------------------------

/****************************************************************
Question 8:-												    *
- Create a stored procedure named sp_GetTopUsersByReputation    *
  that retrieves the top N users whose reputation is above a    *
  specified minimum value. 									    *
- Then create a permanent table named TopUsersArchive and 	    *
  insert the results returned by the procedure into this table. *
*****************************************************************/
-- creating the permenant table:
CREATE TABlE TopUsersArchive(
	Id INT,
	DisplayName NVARCHAR(40),
	Reputation INT,
	Location NVARCHAR(100)
)

-- implementing the procedure
GO
	CREATE OR ALTER PROC USP_GetTopUsersByReputation
						 @NumberOfTopUsers INT,
						 @MinimumReputation INT
	AS
	BEGIN
		INSERT INTO TopUsersArchive
			SELECT TOP(@NumberOfTopUsers)
				Id,
				DisplayName,
				Reputation,
				Location
			FROM Users
			WHERE Reputation >= @MinimumReputation
			ORDER BY Reputation DESC
	END
GO

-- Testing the procedure
EXEC USP_GetTopUsersByReputation
	 @NumberOfTopUsers = 5,
	 @MinimumReputation = 1000

SELECT * FROM TopUsersArchive

----------------------------------------------------------------------

/*************************************************************
Question 9:-												 *
Create a stored procedure named sp_InsertUserLog that 		 *
inserts a new record into a UserLog table. 					 *
The procedure should: 										 *
 ● Accept user ID, action, and details as input.		     *
 ● Return the newly created log ID using an output parameter.*
**************************************************************/
-- Create UserLog table:
CREATE TABLE UserLog(
	LogId INT IDENTITY,
	UserId INT,
	DisplayName VARCHAR(40),
	Action VARCHAR(30),
	LogDate DATE,
	LogDetails VARCHAR(100)
)

GO
	CREATE OR ALTER PROC USP_InsertUserLog
						 @UserId INT,
						 @Action VARCHAR(30),
						 @Details VARCHAR(100),
						 @LogId INT OUTPUT
	AS
	BEGIN
		BEGIN TRY
			IF NOT EXISTS(SELECT 1 FROM Users WHERE Id = @UserId)
			BEGIN 
				;THROW 50001 , 'User not found' , 1
			END

			-- passes the IF test
			INSERT INTO UserLog(UserId, Action, LogDate, LogDetails, DisplayName)
			VALUES(@UserId , @Action, GETDATE(), @Details, 
				   (
					SELECT DisplayName FROM Users WHERE Id = @UserId
			       ))

			-- assigning the @LogId output parameter with last value 
			-- added to the UserLog table
			SET @LogId = SCOPE_IDENTITY()
		END TRY

		BEGIN CATCH
			-- printing some info about the error
			SELECT ERROR_NUMBER(),
				   ERROR_MESSAGE(),
				   ERROR_SEVERITY()
			-- Throw exception
			;THROW
		END CATCH
	END
GO

-- Testing the procedure
DECLARE @Testing_LogId INT;

EXEC USP_InsertUserLog 
	 @UserId = 2,
	 @Action = 'adding comment',
	 @Details = 'adding post created be specific user',
	 @LogId = @Testing_LogId

SELECT * FROM UserLog

----------------------------------------------------------------------

/**********************************************************
Question 10:-											  *
Create a stored procedure named sp_UpdateUserReputation   *
that updates a user’s reputation. 						  *
The procedure should: 									  *
 ● Validate that the reputation value is not negative 	  *
 ● Validate that the user exists 						  *
 ● Return the number of rows affected 					  *
 ● Handle errors appropriately 							  *
***********************************************************/
GO
	CREATE OR ALTER PROC USP_UpdateUserReputation
						 @UserId INT,
						 @NewReputation INT,
						 @NumberOfAffectedRows INT OUTPUT
	AS
	BEGIN
		-- Try block
		BEGIN TRY
			-- Check if user doesn't exists
			IF NOT EXISTS(SELECT 1 FROM Users WHERE Id = @UserId) 
			   AND ( @NewReputation > 0 )
			BEGIN
				-- Throw error as user not found
				;THROW 50001, 'User not found', 1
			END

			-- Update reputation value
			UPDATE Users
			SET Reputation = @NewReputation
			WHERE Id = @UserId

			-- getting the number of affected rows
			SET @NumberOfAffectedRows = @@ROWCOUNT

		END TRY

		-- Catch block
		BEGIN CATCH
			-- printing some info about the error
			SELECT ERROR_NUMBER(),
				   ERROR_MESSAGE(),
				   ERROR_SEVERITY()
			-- Throw exception
			;THROW
		END CATCH
	END
GO

-- Testing the procedure
DECLARE @Testing_NumberOfAffectedRows INT;

EXEC USP_UpdateUserReputation 
	 @UserId = 11,
	 @NewReputation = 22,
	 @NumberOfAffectedRows = @Testing_NumberOfAffectedRows OUTPUT

SELECT @Testing_NumberOfAffectedRows


----------------------------------------------------------------------

/**************************************************************
Question 11:-												  *
Create a stored procedure named sp_DeleteLowScorePosts 		  *
that deletes all posts with a score less than or equal 		  *
to a given value. 											  *
The procedure should: 										  *
● Use transactions 											  *
● Return the number of deleted records as an output parameter *
● Roll back changes if an error occurs						  *
***************************************************************/
----------------------------------------------------------*
-- Note: Adding isDeleted column in posts DB to prevent  |*
--       permenant deletion of posts					 |*
----------------------------------------------------------*
ALTER TABLE Posts
ADD isDeleted BIT DEFAULT 0

GO
	CREATE OR ALTER PROC USP_DeleteLowScorePosts
					 @MinimumScore INT
	AS
	BEGIN
		BEGIN TRY
			-- Check if @MinimumScore is null 
			IF @MinimumScore IS NULL
			BEGIN
				;THROW 50001, 'no minimumScore passed', 1
			END

			-- begin transaction
			BEGIN TRAN

				-- Delete
				-- DELETE FROM Posts
				-- WHERE Score < @MinimumScore

				-- Soft delete
				UPDATE Posts
				SET isDeleted = 1
				WHERE Score < @MinimumScore

			-- Commit transaction
			COMMIT TRAN
		END TRY

		BEGIN CATCH
			-- printing some info about the error
			SELECT ERROR_NUMBER(),
				   ERROR_MESSAGE(),
				   ERROR_SEVERITY()

			--rollback if transaction happened
			IF(@@TRANCOUNT > 0)
				ROLLBACK
			
			-- Throw exception
			;THROW
		END CATCH
	END
GO

-- Testing the stored procedure
EXEC USP_DeleteLowScorePosts @MinimumScore = -50

-- Checking if the stored procedure works or not
SELECT TOP(8)
	Score,
	isDeleted
FROM Posts
ORDER BY Score 

----------------------------------------------------------------------

/*************************************************************
Question 12:-												 *
Create a stored procedure named sp_BulkInsertBadges that 	 *
inserts multiple badge records for a user. 					 *
The procedure should: 										 *
● Accept a user ID.											 *
● Accept a badge count indicating how many badges to insert. *
● Insert multiple related records in a single operation.	 *
**************************************************************/

GO
	CREATE OR ALTER PROC USP_BulkInsertBadges
						 @UserId INT,
						 @BadgeCount INT
	AS
	BEGIN
		BEGIN TRY
			IF NOT EXISTS ( SELECT 1 FROM Users WHERE Id = @UserId)
			BEGIN -- if
				;THROW 50001, 'User not found' , 1
			END --if

			-- Begin transaction to insert the badges
			BEGIN TRAN

			-- looping using while loop
			-- 1. declaring the iterator
			DECLARE @i INT = 0

			-- 2. getting username from 
			--    Users table and setting it into
			--    @UserName variable
			DECLARE @UserName NVARCHAR(40) = (
					SELECT
						DisplayName
					FROM Users
					WHERE Id = @UserId
				)

			-- 3. While loop
			WHILE @i < @BadgeCount
			BEGIN -- while

				-- inserting new badge into the Badges table
				INSERT INTO Badges
				VALUES(@UserName , @UserId , GETDATE())

				-- incrementing the iterator
				SET @i += 1
			END -- while

			-- commit transaction
			COMMIT
		END TRY

		BEGIN CATCH
			-- printing some info about the error
			SELECT ERROR_NUMBER(),
				   ERROR_MESSAGE(),
				   ERROR_SEVERITY()

			--rollback if transaction happened
			IF(@@TRANCOUNT > 0)
				ROLLBACK
			
			-- Throw exception
			;THROW
		END CATCH
	END
GO

-- Testing the stored procedure
-- 1. Declaring @Testing_BadgeCount 
--    and @Testing_UserId
DECLARE @Testing_BadgeCount INT = 5;

-- Executing the stored procedure
EXEC USP_BulkInsertBadges 
	 @UserId = 1,
	 @BadgeCount = @Testing_BadgeCount

-- SELECT the new inserted badges
SELECT TOP (@Testing_BadgeCount)
	*
FROM Badges
ORDER BY Id DESC

----------------------------------------------------------------------

/***************************************************************
Question 13:-											   	   *
Create a stored procedure named sp_GenerateUserReport that 	   *
generates a complete user report. 					    	   *
The procedure should: 										   *
➢ Call another stored procedure internally to retrieve user   *
   statistics.            	                                   *
➢ Combine user profile data and statistics 					   *
➢ Return a formatted report including a calculated user level *
****************************************************************/
-- Outer stored procedure
GO
	CREATE OR ALTER PROC USP_GenerateUserReport
						 @Outer_UserId INT,
						 @Outer_UserLevel VARCHAR(20) OUTPUT
	AS
	BEGIN
		-- Try block
		BEGIN TRY
			-- Checking if the user exists or not
			IF NOT EXISTS(SELECT 1 FROM Users WHERE Id = @Outer_UserId)
			BEGIN
				;THROW 50001, 'User not found' , 1
			END

			-- Declaring output parameters to hold userInfo
			DECLARE @Testing_TotalPostCount INT;
			DECLARE @Testing_TotalBadgeCount INT;
			DECLARE @Testing_AvgScore FLOAT;
			
			-- Executing the USP_GetUserSummary procedure
			EXEC USP_GetUserSummary 
				 @UserId = @Outer_UserId,
				 @TotalPostCount = @Testing_TotalPostCount OUTPUT,
				 @TotalBadgeCount = @Testing_TotalBadgeCount OUTPUT,
				 @AvgScore = @Testing_AvgScore OUTPUT

			-- Setting the userLevel
			SET @Outer_UserLevel = (
					SELECT
						(
							CASE 
							WHEN Reputation > 55000 THEN 'Spectacular'
							WHEN Reputation < 55000 AND Reputation > 40000 
								THEN 'Excellent'
							WHEN Reputation < 40000 AND Reputation > 10000 
								THEN 'Good'
							WHEN Reputation < 1000 THEN 'Fair'
							END
						)
					FROM Users
					WHERE Id = @Outer_UserId
				)

			-- Selecting user stats
			SELECT
				Id,
				DisplayName,
				Reputation,
				@Testing_TotalPostCount AS TotalPostCount,
				@Testing_TotalBadgeCount AS TotalBadgeCount,
				@Testing_AvgScore AS AverageScore,
				@Outer_UserLevel AS userLevel
			FROM Users
			WHERE Id = @Outer_UserId
		END TRY

		-- Catch block
		BEGIN CATCH
			-- printing some info about the error
			SELECT ERROR_NUMBER(),
				   ERROR_MESSAGE(),
				   ERROR_SEVERITY()
			
			-- Throw exception
			;THROW
		END CATCH
	END
GO

-- Testing the procedure
DECLARE @UserLevel VARCHAR(20);

EXEC USP_GenerateUserReport 
	 @Outer_UserId = 11,
	 @Outer_UserLevel = @UserLevel OUTPUT

SELECT @UserLevel AS UserLevelOutsideTheProcedure