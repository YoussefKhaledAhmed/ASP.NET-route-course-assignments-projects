/*********************************************************
 * File name: SQL_StackOverflow_session7                 *
 * Author: Youssef Khaled                                *
 * Date: 12/27/2025 | dd/mm/yyyy                         *
 * Description: Solving session_7 assignment             *
 *********************************************************/


/* Use StackOverFlow2010 DB */
USE StackOverflow2010;


/* Question_1: Write a query to display all user display names in     *
 *             uppercase along with the length of their display name. */
SELECT 
	DisplayName,
	UPPER(DisplayName) AS 'DisplayName in uppercase',
	LEN(DisplayName) AS 'DisplayName length'
FROM Users


/* Question_2: Write a query to show all posts with their titles and      *
 *             calculate how many days have passed since each post was    *
 *             created.                                                   *
 *             Use DATEDIFF to calculate the difference from CreationDate *
 *             to today.                                                  */
SELECT 
	Title,
	DATEDIFF(day , CreationDate , GETDATE()) AS 'date differenece in days'
FROM Posts
WHERE PostTypeId = 1;


/* Question_3: Write a query to count the total number of posts for each user. *
 *             Display the OwnerUserId and the count of their posts.           *
 *             Only include users who have created posts.                      */
SELECT
	OwnerUserId,
	COUNT(*) AS 'total number of posts'
FROM Posts
WHERE PostTypeId = 1
GROUP BY OwnerUserId


/* Question_4: Write a query to find users whose reputation is greater than   *
 *             the average reputation of all users. Display their DisplayName * 
 *             and Reputation. Use a subquery in the WHERE clause.            */
SELECT 
	DisplayName,
	Reputation
FROM Users
WHERE Reputation > 
		(
		 SELECT 
			 AVG(Reputation)
		 FROM Users
		)


/* Question_5: Write a query to display each post title along with the first *
 *             50 characters of the title. If the title is NULL, replace it  *
 *             with 'No Title'. Use SUBSTRING and ISNULL functions.          */
SELECT 
	ISNULL(Title, 'No Title') AS Title,
	ISNULL(SUBSTRING(Title , 1 , 50), 'No Title') AS 'substring'
FROM Posts


/* Question_6: Write a query to calculate the total score and average score     *
 *             for each PostTypeId. Also show the count of posts for each type. *
 *             Only include post types that have more than 100 posts.           */
SELECT
	PostTypeId,
	SUM(Score) AS 'Total score',
	AVG(Score) AS 'Average score',
	COUNT(*) AS 'Count of posts'
FROM Posts
GROUP BY PostTypeId
HAVING COUNT(*) > 100;


/* Question_7: Write a query to show each user's DisplayName along with    *
 *             the total number of badges they have earned. Use a subquery * 
 *             in the SELECT clause to count badges for each user.         */
SELECT
	DisplayName,
	(
		SELECT
			COUNT(*)
		FROM Badges B
		GROUP BY B.UserId
		HAVING B.UserId = U.Id
	) AS 'No. of badges'
FROM Users U


/* Question_8: Write a query to find all posts where the title contains the word *
 *             'SQL'. Display the title, score, and format the CreationDate as   *
 *             'Mon DD, YYYY'. Use CHARINDEX and FORMAT functions.               */
SELECT 
	Title,
	Score,
	FORMAT(CreationDate , 'MMM dd, yyyy')
FROM Posts
WHERE CHARINDEX('SQL', Title) != 0;


/* Question_9: Write a query to group comments by PostId and calculate: *
 *             Total number of comments                                 *
 *             Sum of comment scores                                    *
 *             Average comment score                                    *
 *             Only show posts that have more than 5 comments.          */
SELECT 
	PostId,
	COUNT(*) AS 'Total no. of comments',
	SUM(Score) AS 'Sum of comment scores',
	AVG(Score) AS 'Average comment score'
FROM Comments
GROUP BY PostId
HAVING COUNT(*) > 5;


/* Question_10: Write a query to find all users whose location is not NULL.*
 *              Display their DisplayName, Location, and calculate their   *
 *              reputation level using IIF: 'High' if reputation > 5000,   *
 *              otherwise 'Normal'.                                        */
SELECT
	DisplayName,
	Location,
	IIF((Reputation > 5000),'High','Normal')
FROM Users
WHERE Location IS NOT NULL;


/* Question_11: Write a query using a derived table (subquery in FROM) to: *
 *              . First, calculate total posts and average score per user  *
 *              . Then, join with Users table to show DisplayName          *
 *              . Only include users with more than 3 posts                *
 *              The derived table must have an alias.                      */
SELECT
	DisplayName,
	PostsCount,
	AverageScore
FROM (
	SELECT 
		U.DisplayName,
		COUNT(*) AS PostsCount,
		AVG(P.Score) AS AverageScore
	FROM Posts P
	INNER JOIN Users U
	  ON P.OwnerUserId = U.Id
	GROUP BY U.Id, U.DisplayName
	HAVING COUNT(*) > 3
) AS newTable


/* Question_12: Write a query to group badges by UserId and badge Name.      *
 *              - Count how many times each user earned each specific badge. *
 *              - Display UserId, badge Name, and the count.                 *
 *              Only show combinations where a user earned the same badge    *
 *              more than once.                                              */
SELECT
	UserId,
	Name,
	COUNT(*) AS 'Count of users/badge'
FROM Badges
GROUP BY UserId, Name


/* Question_13: Write a query to display user information along with their    *
 *              account age in years. Use DATEDIFF to calculate years between *
 *              CreationDate and current date. Round the result to 2 decimal  *
 *              places.                                                       *
 *              Also show the absolute value of their DownVotes.              */
SELECT
	AboutMe,
	DATEDIFF(year ,CreationDate ,GETDATE()) AS 'Date difference',
	ABS(DownVotes) AS 'Absoulte DownVotes'
FROM Users


/* Question_14: Write a complex query that:                                     *
 *              . Uses a derived table to calculate comment statistics per post *
 *              . Joins with Posts and Users tables                             *
 *              . Shows: Post Title, Author Name, Author Reputation,            *
 *                Comment Count, and Total Comment Score                        *
 *              . Filters to only show posts with more than 3 comments          *
 *                and post score greater than 10                                *
 *              . Uses COALESCE to replace NULL author names with 'Anonymous'   */
SELECT
	P.Title,
	COALESCE(U.DisplayName , 'Anonymous') As DisplayName,
	U.Reputation,
	D.CommentCount,
	D.ScoreSummition
FROM (
		SELECT
			PostId,
			COUNT(*) AS CommentCount,
			SUM(Score) AS ScoreSummition
		FROM Comments  
		GROUP BY PostId
	) AS D
INNER JOIN Posts P
	ON D.PostId = P.Id
INNER JOIN Users U
	ON P.OwnerUserId = U.Id
GROUP BY P.Id, 
	        P.Title, 
			D.CommentCount, 
			P.PostTypeId, 
			U.DisplayName,
			U.Reputation,
			D.ScoreSummition,
			P.Score
HAVING (P.PostTypeId = 1) AND (P.Score > 10) AND (D.CommentCount > 3)