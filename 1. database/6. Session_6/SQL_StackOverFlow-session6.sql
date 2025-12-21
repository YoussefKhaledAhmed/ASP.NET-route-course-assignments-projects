/*********************************************************
 * File name: SQL_StackOverFlow-session6                 *
 * Author: Youssef Khaled                                *
 * Date: 12/20/2025 | dd/mm/yyyy                         *
 * Description: Solving session_6 assignment             *
 *********************************************************/


/* Use StackOverFlow2010 DB */
USE StackOverflow2010;

/* Question_1:                                                   *
 * ● Write a query to retrieve the top 15 users with the highest *
 *   reputation.                                                 *
 * ● Display their DisplayName, Reputation, and Location.        *
 * ● Order the results by Reputation in descending order         */
 
SELECT TOP 15 
  DisplayName AS 'Name', 
  Reputation AS Reputation ,
  Location AS 'User location'
FROM Users
ORDER BY Reputation DESC 


/* Question_2:                                                    *
 * ● Write a query to get the top 10 posts by score, but include  *
 * ● all posts that have the same score as the 10th post.         *
 * ● Use TOP WITH TIES. Display Title, Score, and ViewCount.      */

SELECT TOP 10 WITH TIES 
  Title AS 'Post title',
  Score AS 'Post score',
  ViewCount AS 'Post view count'
FROM Posts 
ORDER BY Score DESC


/* Question_3:                                                      *
 * ● Write a query to implement pagination: skip the first 20 users *
 * ● and retrieve the next 10 users when ordered by reputation.     *
 * ● Use OFFSET and FETCH. Display DisplayName and Reputation.      */

SELECT DisplayName AS 'User name',
       Reputation AS 'User reputation'
FROM Users
ORDER BY Reputation
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY


/* Question_4:                                                   *
 * ● Write a query to assign a unique row number to each post    *
 * ● ordered by Score in descending order.                       *
 * ● Use ROW_NUMBER(). Display the row number, Title, and Score. *
 * ● Only include posts with non-null titles.                    */

SELECT 
  ROW_NUMBER() OVER(ORDER BY Score DESC) AS 'Row number',
  Title AS 'Post title',
  Score AS 'Post score'
FROM Posts
WHERE Title IS NOT NULL; -- to show questions only can be:
                         -- WHERE PostTypeId = 1


/* Question_5:                                                      *
 * ● Write a query to rank users by their reputation using RANK().  *
 * ● Display the rank, DisplayName, and Reputation.                 *
 * ● Explain what happens when two users have the same reputation.  */

SELECT 
  RANK() OVER(ORDER BY Reputation) AS 'User rank',
  DisplayName AS 'User name',
  Reputation AS 'User reputation'
FROM Users

-- Explanation: when 2 users having the same reputation will have 
--              the same rank.
-- Example:
--            User rank    | user name | reputation
--                1        | Yousef    |    1
--                1        | Adham     |    1
--                1        | Mohamed   |    1
--                4        | Ahmed     |    2
--------------------------------------------------------------------


/* Question_6:                                                *
 * ● Write a query to rank posts by score using DENSE_RANK(). *
 * ● Display the dense rank, Title, and Score.                *
 * ● Explain how DENSE_RANK differs from RANK.                */

SELECT 
  DENSE_RANK() OVER(ORDER BY Score) AS 'Post rank',
  Title AS 'Post title',
  Score AS 'Post score'
FROM Posts

-- Explanation: 
--              RANK --> Assigns same rank to tied rows but 
--                       leaves gaps in the ranking sequence
-- Example:
--            User rank    | user name | reputation
--                1        | Yousef    |    1
--                1        | Adham     |    1
--                1        | Mohamed   |    1
--                4        | Ahmed     |    2
-- ****************************************************************
--              DESNSE_RANK --> also assign same rank to tied rows but 
--                              does NOT leave gaps
-- Example:
--            User rank    | user name | reputation
--                1        | Yousef    |    1
--                1        | Adham     |    1
--                1        | Mohamed   |    1
--                2        | Ahmed     |    2
----------------------------------------------------------------------------


/* Question_7:
 * ● Write a query to divide all users into 5 equal groups (quintiles) *
 * ● based on their reputation. Use NTILE(5).                          *
 * ● Display the quintile number, DisplayName, and Reputation.         */

SELECT 
  NTILE(5) OVER(ORDER BY Reputation) AS 'Quintile number',
  DisplayName AS 'User name',
  Reputation AS 'User reputation'
FROM Users


/* Question_8:                                                      *
 * ● Write a query to rank posts within each PostTypeId separately. *
 * ● Use ROW_NUMBER() with PARTITION BY.                            *
 * ● Display PostTypeId, rank within type, Title, and Score.        *
 * ● Order by Score descending within each partition.               */

SELECT 
  PostTypeId AS 'Post type ID',
  ROW_NUMBER() 
    OVER (
	  PARTITION BY PostTypeId
	  ORDER BY Score DESC
	  ) AS 'Rank with type',
	  title AS 'Post title',
	  Score AS 'Post score'
FROM Posts