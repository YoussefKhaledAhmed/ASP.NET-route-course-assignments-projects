/*********************************************************
 * File name: SQL_StackOverFlow                          *
 * Author: Youssef Khaled                                *
 * Date: 12/16/2025 | dd/mm/yyyy                         *
 * Description: Solving session_5 assignment             *
 *********************************************************/


/* Use StackOverFlow2010 DB */
USE StackOverflow2010;


/* Question_1: Write a query to display all users *
 *             along with all post types.         */
SELECT Id, DisplayName, Age , Location FROM Users;


/* Question_2: Write a query to retrieve all posts along       *
 *             with their owner's display name and reputation. *
 *	       	   Only include posts that have an owner.          */
SELECT P.Title AS 'Post title' , 
       U.DisplayName AS 'User name' , 
	   U.Reputation AS 'User reputation' 
FROM Posts P
INNER JOIN Users U
  ON P.OwnerUserId = U.Id
WHERE P.Title IS NOT NULL; -- Include only posts not comments


/* Question_3: Write a query to show all comments with their     *
 *             associated post titles. Display the comment text, *
 *             comment score, and post title.                    */
SELECT C.Text AS 'Comment text', 
       C.Score AS 'Comment score', 
	   P.Title AS 'Post title'
FROM Comments C
INNER JOIN Posts P
  ON C.PostId = P.Id
WHERE P.PostTypeId = 1;


/* Question_4: Write a query to list all users and their badges (if any).       *
 *             Include users even if they don't have badges. Show display name, *
 *             badge name, and badge date.                                      */
SELECT u.DisplayName AS 'User name' , 
       B.Name AS 'Badge name', 
	   B.Date AS 'Badge Date'
FROM Users U
LEFT JOIN Badges B
  ON U.Id = B.UserId;


/* Question_5:  Write a query to display all posts along with their comments   *
 *             (if any). Include posts that have no comments. Show post title, *
 *             post score, comment text, and comment score.                    */
SELECT P.Title AS 'Post title' , 
       P.Score AS 'Post score' , 
	   C.Text AS 'Comment text' , 
	   C.Score AS 'comment score'
FROM Posts P
LEFT JOIN Comments C
  ON C.PostId = P.Id
WHERE P.PostTypeId = 1;


/* Question_6: Write a query to show all votes along with their corresponding    *
 *             posts. Include all votes even if the post information is missing. *
 *             Display vote type ID, creation date, and post title.              */
SELECT V.VoteTypeId AS 'Vote typeId', 
       V.CreationDate AS 'Vote creation date', 
	   P.Title AS 'Post title'
FROM Votes V
LEFT JOIN Posts P
  ON V.PostId = P.Id;


/* Question_7: Write a query to find all answers (posts with ParentId) along with  *
 *             their parent question. Show the answer title, answer score,         *
 *             question title, and question score.                                 */
SELECT A.Body AS 'Answer Body',
       A.Score AS 'Answer Score',
	   P.Title AS 'Post title',
	   P.Score AS 'Post Score'
FROM Posts A
INNER JOIN Posts P
  ON A.ParentId = P.Id;


/* Question_8: Write a query to display all related posts using the PostLinks table. *
 *             Show the original post title, related post title, and link type ID.   */
SELECT P2.Title AS 'Original post title',
	   P1.Title AS 'Related post title',
	   PLinks.Id AS 'Link Id'
FROM PostLinks PLinks
INNER JOIN Posts P1
  ON PLinks.RelatedPostId = P1.Id
INNER JOIN Posts P2
  ON PLinks.PostId = P2.Id;


/* Question_9: Write a query to show posts with their authors and the post type  *
 *             name. Display post title, author display name, author reputation, * 
 *             and post type.                                                    */
SELECT P.Title AS 'Post title',
       U.DisplayName AS 'User Name',
	   U.Reputation AS 'User Reputation',
	   PTypes.Type AS 'Post type'
FROM Posts P
INNER JOIN PostTypes PTypes
  ON P.PostTypeId = PTypes.Id
INNER JOIN Users U
  ON P.OwnerUserId = U.Id
WHERE P.PostTypeId = 1; -- to assure it's Question


/* Question_10: Write a query to retrieve all comments along with the post title, *
 *              post author, and the commenter's display name.                    */
SELECT P.Title AS 'Post title',
	   U1.DisplayName AS 'post-author name',
	   U2.DisplayName AS 'commenter name'
FROM Posts P
INNER JOIN Comments C
  ON C.PostId = P.Id
INNER JOIN Users U1
  ON P.OwnerUserId = U1.Id
INNER JOIN Users U2
  ON C.UserId = U2.Id;


/* Question_11: Write a query to display all votes with post information and vote *
 *              type name. Show post title, vote type name, creation date, and    *
 *              bounty amount.                                                    */
SELECT P.Title AS 'Post Title',
       VType.Name AS 'Vote type name',
	   V.CreationDate AS 'Vote creation date',
	   V.BountyAmount AS 'Vote bounty amount'
FROM Votes V
INNER JOIN Posts P
  ON V.PostId = P.Id
INNER JOIN VoteTypes VType
  ON V.VoteTypeId = VType.Id;


/* Question_12: Write a query to show all users along with their posts and    *
 *              comments on those posts. Include users even if they have no   *
 *              posts or comments. Display user name, post title, and comment *
 *              text.                                                         */
SELECT U.Id AS 'User Id',
       U.DisplayName AS 'User name',
       P.Title AS 'Post title',
	   C.Text AS 'Comments text',
	   C.CreationDate AS 'Comments date',
	   C.Id AS 'Comment Id'
FROM Users U
LEFT JOIN Posts P
  ON U.Id = P.OwnerUserId 
LEFT JOIN Comments C
  ON P.Id = C.PostId;

/* Question_13: Write a query to retrieve posts with their authors, post types, and  *
 *              any badges the author has earned. Show post title, author name,      *
 *              post type, and badge name.                                           */

-- Note: Each user may have more than one badge name.
SELECT P.Title AS 'Post title',
       U.Id AS 'User Id',
	   U.DisplayName AS 'User name',
	   PType.Type AS 'Post type',
	   B.Name AS 'Badge name'
FROM Posts P
INNER JOIN Users U
  ON P.OwnerUserId = U.Id
INNER JOIN Badges B
  ON U.Id = B.UserId
INNER JOIN PostTypes PType
  ON P.PostTypeId = PType.Id; 


/* Question_14: Write a query to create a comprehensive report showing:         *
 *              post title, post author name, author reputation, comment text,  *
 *              commenter name, vote type, and vote creation date. Include      *
 *              posts even if they don't have comments or votes. Filter to only *
 *              show posts with a score greater than 5.                         */
SELECT P.Id AS 'Post Id',
       P.Title AS 'Post title',
       U.DisplayName AS 'author name',
	   U.Reputation AS 'author reputation',
	   C.Id AS 'Comment Id',
	   C.Text AS 'Comment text',
	   U2.DisplayName AS 'Commentor name',
	   V.Id AS 'Vote Id',
	   VType.Name AS 'Vote type name',
	   V.CreationDate AS 'Vote creation date'
FROM Posts P
INNER JOIN Users U
  ON P.OwnerUserId = U.Id -- to get post's author
LEFT JOIN Comments C
  ON P.Id = C.PostId -- to get comments on the post
LEFT JOIN Users U2
  ON U2.Id = C.UserId -- to get comments' authors
LEFT JOIN Votes V
  ON P.Id = V.PostId -- to get votes on the post
LEFT JOIN VoteTypes VType
  ON V.VoteTypeId = VType.Id -- to get the vote type
-- the AND here is to filter the Questions (Extra from me)
WHERE P.Score > 5 AND P.PostTypeId = 1; 