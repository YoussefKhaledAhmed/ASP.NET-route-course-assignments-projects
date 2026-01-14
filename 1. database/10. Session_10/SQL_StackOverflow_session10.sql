/*********************************************************
 * File name: SQL_StackOverflow_session10                *
 * Author: Youssef Khaled                                *
 * Date: 13/01/2026 | dd/mm/yyyy                         *
 * Description: Solving session_10 assignment            *
 *********************************************************/


/* Use StackOverFlow2010 DB */
USE StackOverflow2010;


/***********************************************************************
Question 01 :-                                						   *
- Create a view that displays basic user information including. 	   *
- their display name, reputation, location, and account creation date. *
- Name the view: vw_BasicUserInfo. 									   *
- Test the view by selecting all records from it					   *
************************************************************************/
GO
	CREATE OR ALTER VIEW vw_BasicUserInfo
	AS
		SELECT
			DisplayName,
			Reputation,
			Location,
			CreationDate
		FROM Users
GO

-- Testing the view
SELECT * FROM vw_BasicUserInfo

-----------------------------------------------------------------------


/**********************************************************************
Question 02 :-														  *
- Create a view that shows all posts with their titles, scores, 	  *
- view counts, and creation dates where the score is greater than 10. *
- Name the view: vw_HighScoringPosts 								  *
- Test by querying posts from this view. 							  *
***********************************************************************/
GO
	CREATE OR ALTER VIEW vw_HighScoringPosts
	AS
		SELECT
			Title,
			Score,
			ViewCount,
			CreationDate
		FROM Posts
		WHERE Score > 10
GO

-- Testing the view
SELECT * FROM vw_HighScoringPosts

------------------------------------------------------------------------

/***********************************************************************
Question 03 :-														   *
- Create a view that combines data from Users and Posts tables. 	   *
- Show the post title, post score, author name, and author reputation. *
- Name the view: vw_PostsWithAuthors 								   *
- This is a complex view involving joins							   *
************************************************************************/
GO
	CREATE OR ALTER VIEW vw_PostsWithAuthors
	AS
		SELECT
			P.Title AS PostTitle,
			P.Score AS PostScore,
			U.DisplayName AS UserName,
			U.Reputation AS UserReputation
		FROM Posts P
		INNER JOIN Users U
		ON P.OwnerUserId = U.Id
GO

-- Testing the view
SELECT * FROM vw_PostsWithAuthors

------------------------------------------------------------------------

/***************************************************************
Question 04 :-									   			   *
- Create a view that aggregates comment statistics per post.   *
- Include: PostId, total comment count, sum of comment scores, *
- and average comment score. 								   *
- Name the view: vw_PostCommentStats 						   *
- This is a complex view with aggregation. 					   *
****************************************************************/
GO
	CREATE OR ALTER VIEW vw_PostCommentStats
	AS
		SELECT
			P.Id AS PostId,
			COUNT(*) AS CommentCount,
			SUM(C.Score) AS TotalCommentScore,
			AVG(C.Score) AS AverageCommentScore
		FROM Comments C
		INNER JOIN Posts P
		ON C.PostId = P.Id
		GROUP BY P.Id
GO


-- Testing the view
SELECT * FROM vw_PostCommentStats

------------------------------------------------------------------------

/********************************************************************
Question 05 :- 														*
- Create an indexed view that shows user activity summaries. 		*
- Include: UserId, DisplayName, Reputation, total posts count. 		*
- Name the view: vw_UserActivityIndexed 							*
- Make it an indexed view with a unique clustered index on UserId 	*
*********************************************************************/
GO
	CREATE OR ALTER VIEW vw_UserActivityIndexed
	WITH SCHEMABINDING
	AS
		SELECT
			U.Id AS UserId,
			U.DisplayName AS UserName,
			U.Reputation AS UserReputation,
			COUNT_BIG(*) AS TotalPostsCount
		FROM dbo.Users U
		INNER JOIN dbo.Posts P
		ON P.OwnerUserId = U.Id
		GROUP BY U.Id, U.DisplayName, U.Reputation
GO

CREATE UNIQUE CLUSTERED INDEX x_UserActivityIndexed
ON dbo.vw_UserActivityIndexed(UserId)

-- Testing the view
SELECT * FROM vw_UserActivityIndexed


------------------------------------------------------------------------

/********************************************************************
Question 06 :-														*
- Create a partitioned view that combines high reputation users 	*
- (reputation > 5000) and low reputation users (reputation <= 5000) *
- from the same Users table using UNION ALL. 						*
- Name the view: vw_UsersPartitioned								*
*********************************************************************/
GO
	CREATE OR ALTER VIEW vw_UsersPartitioned
	AS
		SELECT 
			Id,
			CreationDate,
			DisplayName,
			Location,
			Reputation
		FROM Users
		WHERE Reputation > 5000

		UNION ALL

		SELECT 
			Id,
			CreationDate,
			DisplayName,
			Location,
			Reputation
		FROM Users
		WHERE Reputation <= 5000
GO

-- Testing the view
SELECT * FROM vw_UsersPartitioned


------------------------------------------------------------------------

/****************************************************************
Question 07 : 													*
- Create an updatable view on the Users table that shows 		*
- UserId, DisplayName, and Location. 							*
- Test the view by updating a user's location through the view. *
- Name the view: vw_EditableUsers 								*
*****************************************************************/
GO
	CREATE OR ALTER VIEW vw_EditableUsers
	AS
		SELECT
			Id AS UserId,
			DisplayName,
			Location
		FROM Users
GO

UPDATE vw_EditableUsers
SET Location = 'US'
WHERE UserId = 1

-- Testing the view
SELECT * FROM vw_EditableUsers
WHERE UserId = 1


------------------------------------------------------------------------

/**********************************************************************
Question 08 : 														  *
- Create a view with CHECK OPTION that only shows posts with 		  *
- score greater than or equal to 20. 								  *
- Name the view: vw_QualityPosts 									  *
- Ensure that any updates through this view maintain the score >= 20  *
- condition . 														  *
***********************************************************************/
GO
	CREATE OR ALTER VIEW vw_QualityPosts
	AS
		SELECT
			Title,
			Score
		FROM Posts
		WHERE Score >= 20
		WITH CHECK OPTION
GO

------------------------------------------------------------------------

/******************************************************************
Question 09 : 													  *
- Create a complex view that shows comprehensive post information *
- including post details, author information, and comment count.  *
- Include: PostId, Title, Score, AuthorName, AuthorReputation, 	  *
- CommentCount. 												  *
*******************************************************************/
GO
	CREATE OR ALTER VIEW VW_PostInfo
	AS
		SELECT
			P.Id AS PostId,
			P.Title AS PostTitle,
			P.Score AS PostScore,
			U.DisplayName AS AuthorName,
			U.Reputation AS AuthorReputation,
			P.CommentCount
		FROM dbo.Posts P
		INNER JOIN dbo.Users U
		ON P.OwnerUserId = U.Id
GO

-- Testing the view
SELECT * FROM VW_PostInfo

------------------------------------------------------------------------

/******************************************************************
Question 10 :- 													  *
- Create a view that shows badge statistics per user. 			  *
- Include: UserId, DisplayName, Reputation, total badge count, 	  *
- and a list of unique badge names (comma-separated if possible,  *
- or just the count for simplicity). 							  *
- Name the view: vw_UserBadgeStats .							  *
*******************************************************************/
GO
	CREATE OR ALTER VIEW vw_UserBadgeStats
	AS
		SELECT 
			U.Id AS UserId,
			U.DisplayName AS UserName,
			U.Reputation AS UserReputation,
			COUNT(B.Id) AS TotalBadgeCount
			--STRING_AGG(DISTINCT B.Name, ', ') AS BadgeNames
		FROM dbo.Users U
		INNER JOIN dbo.Badges B
		ON B.UserId = U.Id
		GROUP BY U.Id, U.DisplayName, U.Reputation
GO

-- Testing the view
SELECT * FROM vw_UserBadgeStats


------------------------------------------------------------------------

/************************************************************************
Question 11 : 															*
- Create a view that shows only active users (those who have 			*
- posted in the last 365 days from today, or have a reputation > 1000). *
- Include: UserId, DisplayName, Reputation, LastActivityDate 			*
- Name the view: vw_ActiveUsers.										*
*************************************************************************/
GO
	CREATE OR ALTER VIEW vw_ActiveUsers
	AS
		SELECT 
			U.Id AS UserId,
			U.DisplayName,
			U.Reputation,
			MAX(P.CreationDate) AS LastActivityDate,
			U.LastAccessDate
		FROM dbo.Users U
		INNER JOIN dbo.Posts P
		ON U.Id = P.OwnerUserId
		Where DATEDIFF(DAY , P.CreationDate, GETDATE()) <= 365
			  OR
			  U.Reputation > 1000
		GROUP BY U.Id, U.DisplayName, U.Reputation,U.LastAccessDate
GO

-- Testing the view
SELECT * FROM vw_ActiveUsers
WHERE UserId = 383


------------------------------------------------------------------------

/*****************************************************************
Question 12 :-													 *
- Create an indexed view that calculates total views and average *
- score per user from their posts. 								 *
- Include: UserId, TotalPosts, TotalViews, AvgScore 			 *
- Name the view: vw_UserPostMetrics 							 *
- Create a unique clustered index on UserId. 					 *
******************************************************************/
GO
	CREATE OR ALTER VIEW dbo.vw_UserPostMetrics
	WITH SCHEMABINDING
	AS
		SELECT	
			OwnerUserId As UserId,
			COUNT_BIG(*) As TotalPosts,
			SUM(ViewCount) As TotalViews,
			SUM(Score) As TotalScore,
			COUNT_BIG(*) As ScoreCount
		FROM dbo.Posts
		GROUP BY OwnerUserId
GO 

CREATE UNIQUE CLUSTERED INDEX Idx_UserPostMetrics
ON dbo.vw_UserPostMetrics(UserId)


SELECT
	UserId,
	TotalPosts,
	TotalViews,
	TotalScore / CAST(ScoreCount AS FLOAT) AS AvgScore
FROM dbo.vw_UserPostMetrics


------------------------------------------------------------------------

/********************************************************************
Question 13 : 														*
- Create a view that categorizes posts based on their score ranges. *
- Categories: 'Excellent' (>= 100), 'Good' (50-99), 				*
-             'Average' (10-49), 'Low' (< 10) 						*
- Include: PostId, Title, Score, Category 							*
- Name the view: vw_PostsByCategory									*
*********************************************************************/
GO
	CREATE OR ALTER VIEW vw_PostsByCategory
	AS
		SELECT
			Id AS PostId,
			Title,
			Score,
			(
			CASE
				WHEN Score >= 100 THEN 'Excellent'
				WHEN (Score >= 50) AND (Score <= 99) THEN 'Good'
				WHEN (Score >= 10) AND (Score <= 49) THEN 'Average'
				WHEN Score < 10 THEN 'Low'
			END
			) AS Category
		FROM Posts
GO

-- Testing the view
SELECT * FROM vw_PostsByCategory