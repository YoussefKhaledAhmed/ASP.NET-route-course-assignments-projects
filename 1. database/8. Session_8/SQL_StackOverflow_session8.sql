/*********************************************************
 * File name: SQL_StackOverflow_session8                 *
 * Author: Youssef Khaled                                *
 * Date: 12/30/2025 | dd/mm/yyyy                         *
 * Description: Solving session_8 assignment             *
 *********************************************************/


/* Use StackOverFlow2010 DB */
USE StackOverflow2010;


/* Question_1: Retrieve a list of users who meet at least one of      *
 *             these criteria:                                        *
 *             1. Reputation greater than 8000                        *
 *             2. Created more than 15 posts                          *
 *             Display UserId, DisplayName, and Reputation.           *
 *             Ensure that each user appears only once in the results.*/
SELECT
	Id,
	DisplayName,
	Reputation,
	'ReputationLabel' AS Label
FROM Users
WHERE Reputation > 8000

UNION

SELECT
	U.Id,
	U.DisplayName,
	U.Reputation,
	'CountLabel' AS Label
FROM Users U
INNER JOIN Posts P
  ON U.Id = P.OwnerUserId
WHERE P.PostTypeId = 1
GROUP BY U.Id, U.DisplayName, U.Reputation
HAVING COUNT(P.Id) > 15


/* Question_2: Find users who satisfy BOTH of these conditions *
 *             simultaneously:                                 *
 *             1. Have reputation greater than 3000            *
 *             2. Have earned at least 5 badges                *
 *             Display UserId, DisplayName, and Reputation.    */
SELECT
	Id,
	DisplayName,
	Reputation
FROM Users
WHERE Reputation > 3000

INTERSECT

SELECT
	U.Id,
	U.DisplayName,
	U.Reputation
FROM Users U
INNER JOIN Badges B
 ON U.Id = B.UserId
GROUP BY U.Id, U.DisplayName, U.Reputation
HAVING COUNT(B.Id) >= 5


/* Question_3: Identify posts that have a score greater than 20 *
 *             but have never received any comments.            *
 *             Display PostId, Title, and Score.                */
SELECT 
	Id AS postId,
	Title AS postTitle,
	Score AS postScore
FROM Posts
WHERE Score > 20 AND PostTypeId = 1

EXCEPT

SELECT
	Id AS postId,
	Title AS postTitle,
	Score AS postScore
FROM Posts
WHERE CommentCount > 0 AND PostTypeId = 1


/* Question_4: Create a new permanent table called Posts_Backup       *
 *             that stores all posts with a score greater than 10.    *
 *             The new table should include:                          *
 *             Id, Title, Score, ViewCount, CreationDate, OwnerUserId.*/
SELECT
	Id,
	Title,
	Score,
	ViewCount,
	CreationDate,
	OwnerUserId
INTO Posts_Backup
FROM Posts
WHERE Score > 10


/* Question_5: Create a new table called ActiveUsers containing users who meet the *
 *             following criteria:                                                 *
 *             1. Reputation greater than 1000                                     *
 *             2. Have created at least one post                                   *
 *             The table should include: UserId, DisplayName, Reputation, Location,*
 *             and PostCount (calculated).                                         */
SELECT
	U.Id,
	U.DisplayName,
	U.Reputation,
	U.Location,
	COUNT(P.Id) AS PostCount
INTO ActiveUsers
FROM Users U
INNER JOIN Posts P
  ON U.Id = P.OwnerUserId
WHERE U.Reputation > 1000
GROUP BY U.Id, U.DisplayName, U.Reputation, U.Location


/* Question_6: Create a new empty table called Comments_Template *
 *            that has the exact same structure as the Comments  *
 *            table but contains no data rows.                   */
SELECT
	*
INTO Comments_Template
FROM Comments
WHERE 1 = 0;


/* Question_7: Create a summary table called PostEngagementSummary        *
 *             that combines data from Posts, Users, and Comments tables. *
 *             The table should include:                                  *
 *             PostId, Title, AuthorName, Score, ViewCount                *
 *             CommentCount (calculated), TotalCommentScore (calculated)  *
 *             Include only posts that have received at least 3 comments. */
SELECT
	P.Id AS PostId,
	P.Title AS PostTitle,
	U.DisplayName AS AuthorName,
	P.Score AS PostScore,
	P.ViewCount,
	COUNT(C.Id) AS CommentCount,
	SUM(C.Score) AS TotalCommentScore 
INTO PostEngagementSummary
FROM Posts P
INNER JOIN Comments C
  ON C.PostId = P.Id
INNER JOIN Users U
  ON P.OwnerUserId = U.Id
GROUP BY P.Id, P.Title, U.DisplayName, P.Score, P.ViewCount
HAVING COUNT(C.Id) >= 3


/* Question_8: Develop a reusable calculation that determines       *
 *             the age of a post in days based on its creation date.*
 *             Input: CreationDate (DATETIME)                       *
 *             Output: Age in days (INTEGER)                        *
 *             Test your solution by displaying posts with their    *
 *             calculated ages.                                     */
GO

CREATE FUNCTION dbo.AgeInDays ( @CreationDate DATETIME )
RETURNS INT
AS
BEGIN
	RETURN DATEDIFF(DAY , @CreationDate, GETDATE())
END

GO

SELECT
	Id,
	CreationDate,
	dbo.AgeInDays(CreationDate) AS Age
FROM Users


/* Question_9: Develop a reusable calculation that assigns a badge level *
 *             to users based on their reputation and post activity.     *
 *             Inputs: Reputation (INT), PostCount (INT)                 *
 *             Output: Badge level (VARCHAR)                             *
 *             Logic:                                                    *
 *             'Gold' if reputation > 10000 AND posts > 50               *
 *             'Silver' if reputation > 5000 AND posts > 20              *
 *             'Bronze' if reputation > 1000 AND posts > 5               *
 *             'None' otherwise                                          */
GO

CREATE FUNCTION dbo.badgeLevel (@Reputation INT , @PostCount INT)
RETURNS VARCHAR(10)
AS
BEGIN
	-- Local variable to be returned at the end of the function
	DECLARE @LocalVariable VARCHAR(10) = 'None'
	IF(@Reputation > 10000 AND @PostCount > 50)
		SET @LocalVariable = 'Gold'
	ELSE IF(@Reputation > 5000 AND @PostCount > 20)
		SET @LocalVariable = 'Silver'
	ELSE IF(@Reputation > 1000 AND @PostCount > 5)
		SET @LocalVariable = 'Bronze'
	RETURN @LocalVariable
END

GO

SELECT
	U.Id,
	dbo.badgeLevel(U.Reputation , COUNT(P.Id)) AS badgeLevel
FROM Users U
INNER JOIN Posts P
  ON P.OwnerUserId = U.Id
GROUP BY U.Id, U.Reputation


/* Question_10: Develop a reusable query that retrieves posts created           *
 *              within a specified number of days from today.                   *  
 *              Input: @DaysBack (INT) - number of days to look back            *
 *              Output: Table with PostId, Title, Score, ViewCount, CreationDate*
 *              Test with different day ranges (e.g., 30 days, 90 days).        */
GO

CREATE FUNCTION getPostsByAge(@DaysBack INT)
RETURNS TABLE
AS
	RETURN(
		SELECT
			Id AS PostId,
			Title,
			Score,
			ViewCount,
			CreationDate
		FROM Posts
		WHERE DATEDIFF(DAY , CreationDate, GETDATE()) <= @DaysBack
	);

GO

-- posts from 20 years (7300 days)
-- as posts from 30 days won't work because this is a 2010 DB
-- no recent records
SELECT * FROM dbo.getPostsByAge(7300) 


/* Question_11: Develop a reusable query that finds top users from a specific * 
 *              location or all locations based on reputation threshold.      *
 *              Inputs: @MinReputation (INT), @Location (VARCHAR)             *
 *              Output: Table with UserId, DisplayName, Reputation, Location, *
 *              CreationDate                                                  *
 *              If @Location is NULL, return users from all locations.        *
 *              Test with different parameters.                               */
GO

CREATE FUNCTION dbo.TopUsers(@MinReputation INT , @Location VARCHAR(100))
RETURNS TABLE
	RETURN(
		SELECT
			Id AS UserId,
			DisplayName,
			Reputation,
			Location,
			CreationDate
		FROM Users
		WHERE (Reputation > @MinReputation) 
			  AND
			  (@Location IS NULL OR @Location = Location)
	)

GO


SELECT * FROM dbo.TopUsers(5000, NULL) ORDER BY UserId;
SELECT * FROM dbo.TopUsers(3000, 'New York') ORDER BY UserId;

-- Testing if @Location = NULL works or not
-- both should generate the same number of records
SELECT * FROM dbo.TopUsers(0 , NULL) ORDER BY UserId;
SELECT * FROM Users ORDER BY Id


/* Question_12: Write a query to find the top 3 highest scoring posts for each *
 *              PostTypeId.													   *
 *              Use a subquery or CTE with ROW_NUMBER() and PARTITION BY.	   *
 *              Display PostTypeId, Title, Score, and the rank.                */
WITH CTE_highestScoringPosts (PostTypeId , Title, Score, rank)
AS(
	SELECT
		PostTypeId,
		Title,
		Score,
		ROW_NUMBER() OVER(PARTITION BY PostTypeId ORDER BY Score DESC)
	FROM Posts
)
SELECT * FROM CTE_highestScoringPosts
WHERE rank <= 3
ORDER BY PostTypeId


/* Question_13: Write a query using a CTE to find all users whose reputation   *
 *              is above the average reputation. The CTE should calculate  	   *
 *				1. the average reputation first. 							   *
 *				2. Display DisplayName, Reputation, and the average reputation.*/
WITH CTE_averageReputation
AS(
	SELECT 
		AVG(Reputation) AS AverageReputation
	FROM Users
)
SELECT 
	DisplayName,
	Reputation,
	AverageReputation
FROM Users
CROSS JOIN CTE_averageReputation
WHERE Reputation > AverageReputation


/* Question_14: Write a query using a CTE to calculate the total number of * 
 *              posts and average score for each user. Then join with the  *
 *              Users table to display: 								   *
 *              DisplayName, Reputation, TotalPosts, and AvgScore. 		   *
 *              Only include users with more than 5 posts.                 */
WITH CTE_UserPostStatistics(UserId, AverageScore, TotalNumOfPosts)
AS(
	SELECT 
		U.Id,
		AVG(P.Score),
		COUNT(P.Id)
	FROM Users U
	INNER JOIN Posts P
	  ON U.Id = P.OwnerUserId
	GROUP BY U.Id
	HAVING COUNT(P.Id) > 5
)
SELECT
	U.DisplayName,
	U.Reputation,
	C.AverageScore,
	C.TotalNumOfPosts
FROM Users U
INNER JOIN CTE_UserPostStatistics C
  ON U.Id = C.UserId


/* Question_15: Write a query using multiple CTEs: 					*
 *				First CTE: Calculate post count per user 			*
 *				Second CTE: Calculate badge count per user 			*
 *				Then join both CTEs with Users table to show: 		*
 *				DisplayName, Reputation, PostCount, and BadgeCount. *
 *				Handle NULL values by replacing them with 0.        */
WITH CTE1_postCount(UserId, PostCount)
AS(
	SELECT 
		U.Id,
		COUNT(P.Id)
	FROM Users U
	INNER JOIN Posts P
	  ON U.Id = P.OwnerUserId
	WHERE P.PostTypeId = 1
	GROUP BY U.Id
),
CTE2_badgeCount(UserId, badgeCount)
AS(
	SELECT
		U.Id,
		COUNT(B.Id)
	FROM Users U
	INNER JOIN Badges B
	  ON U.Id = B.UserId
	GROUP BY U.Id
)
SELECT 
	U.DisplayName,
	U.Reputation,
	ISNULL(C1.PostCount , 0),
	ISNULL(C2.badgeCount, 0)
FROM Users U
LEFT JOIN CTE1_postCount C1
  ON U.Id = C1.UserId
LEFT JOIN CTE2_badgeCount C2
  ON U.Id = C2.UserId


/* Question_16: Write a recursive CTE to generate a sequence of numbers from *
 *              1 to 20.                                                     *
 *              Display the generated numbers.                               */
WITH CTE_recursive 
AS(
	-- Anchor
	SELECT 0 AS n
	
	UNION ALL
	
	-- Recursive part
	SELECT n+1
	-- referencing itself
	FROM CTE_recursive

	-- stopping condition
	WHERE n<20

)
SELECT * FROM CTE_recursive;