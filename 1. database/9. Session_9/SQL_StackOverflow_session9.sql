/*********************************************************
 * File name: SQL_StackOverflow_session9                 *
 * Author: Youssef Khaled                                *
 * Date: 13/01/2026 | dd/mm/yyyy                         *
 * Description: Solving session_9 assignment             *
 *********************************************************/


/* Use StackOverFlow2010 DB */
USE StackOverflow2010;


-- Question 01 :
--=====================================================
-- a) Design and implement an appropriate index structure
Create NonClustered Index Idx_PostsOfUser
On Posts (OwnerUserId, Score DESC)
Include (Id, Title, Body)


-- b) Ensure the index covers all columns needed by the query
--== The Index fully covered all columns needed by the query


-- c) Write a test query that demonstrates the optimization
Select 
	OwnerUserId As UserId,
	Id As PostId,
	Title,
	Score,
	Body 
From Posts 
Where OwnerUserId = 5 And Score > 50
Order By Score DESC


-- d) Verify the index was created successfully
Select 
    name As IndexName,
    type_desc,
    is_disabled
From sys.indexes
Where object_id = OBJECT_ID('Posts') And name = 'Idx_PostsOfUser';



-- Question 02 :
--=====================================================
-- a) Design an index that only includes posts meeting these criteria
Create NonClustered Index Idx_PostsWithHighValue
On Posts (Score DESC)
Include (Id, Title, Body, CreationDate)
Where Score > 100 And Title is Not Null


-- b) Include relevant columns in the index
--== All relevant needed cloumns are included in the index


-- c) Write a query that demonstrates the optimization
Select Id, Title, Body, CreationDate, Score
From Posts
Where Score > 100 And Title Is Not Null
Order By Score DESC;


-- d) Explain why this specialized index design is beneficial
--== It is beneficial as it reduces index size, speed up query execution for targeted queries and avoids table scans and key lookups
