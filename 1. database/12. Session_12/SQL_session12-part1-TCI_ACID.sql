/*********************************************************
 * File name: SQL_session12-part1-TCI_ACID               *
 * Author: Youssef Khaled                                *
 * Date: 23/01/2026 | dd/mm/yyyy                         *
 * Description: Solving session_12 assignment part 1	 *
 *              TCI/ACID part                            *
 *********************************************************/

/* Use Bank DB */
USE BankDB;


CREATE TABLE AccountBalance ( 
    AccountId INT PRIMARY KEY, 
    AccountName VARCHAR(100), 
    Balance DECIMAL(18,2) CHECK (Balance >= 0), 
    LastUpdated DATETIME DEFAULT GETDATE() 
); 
 
 
CREATE TABLE TransferHistory ( 
    TransferId INT IDENTITY(1,1) PRIMARY KEY, 
    FromAccountId INT, 
    ToAccountId INT, 
    Amount DECIMAL(18,2), 
    TransferDate DATETIME DEFAULT GETDATE(), 
    Status VARCHAR(20), 
    ErrorMessage VARCHAR(500) 
); 


CREATE TABLE AuditTrail ( 
    AuditId INT IDENTITY(1,1) PRIMARY KEY, 
    TableName VARCHAR(100), 
    Operation VARCHAR(50), 
    RecordId INT, 
    OldValue VARCHAR(500), 
    NewValue VARCHAR(500), 
    AuditDate DATETIME DEFAULT GETDATE(), 
    UserName VARCHAR(100) DEFAULT SYSTEM_USER 
); 


GO -- Insert sample data 
INSERT INTO AccountBalance (AccountId, AccountName, Balance) 
VALUES  
(101, 'Checking Account', 10000.00), 
(102, 'Savings Account', 25000.00), 
(103, 'Investment Account', 50000.00), 
(104, 'Emergency Fund', 15000.00); 
GO


------------------------------------------------------------------

/****************************************************
Question 1:-									    *
Write a simple transaction that transfers $500 from *
Account 101 to Account 102. 					    *
Use BEGIN TRANSACTION and COMMIT TRANSACTION. 	    *
Display the balances before and after the transfer. *
*****************************************************/

GO 
	CREATE OR ALTER PROC USP_TransferBalance
	AS
	BEGIN
		-- TRY block
		BEGIN TRY
			-- Begin Transaction
			BEGIN TRAN

			-- Subtract from Id 101
			UPDATE AccountBalance
			SET Balance -= 500
			WHERE AccountId = 101

			-- Addd to Id 102
			UPDATE AccountBalance
			SET Balance += 500
			WHERE AccountId = 102
			
			-- COMMIT Transaction
			COMMIT
		END TRY

		-- CATCH block
		BEGIN CATCH
			-- Selecting some error info
			SELECT ERROR_NUMBER() AS ErrorNumber,
				   ERROR_MESSAGE() AS ErrorMessage,
				   ERROR_SEVERITY() AS ErrorSeverity

			-- Rollback
			ROLLBACK;
			
			-- printing message on the console
			PRINT('Procedure failed')

			-- throw error to the caller
			;THROW
		END CATCH
	END
GO

-- Selecting balance before & after the stored procedure
-- Before execution 
SELECT * FROM AccountBalance

-- Executing the stored procedure
EXEC USP_TransferBalance

-- After execution
SELECT * FROM AccountBalance


------------------------------------------------------------------

/****************************************************
Question 2:-										*
Write a transaction that attempts to transfer $1000 *
from Account 101 to Account 102, but then rolls 	*
it back using ROLLBACK TRANSACTION. 				*
Verify that the balances remain unchanged.. 		*
*****************************************************/

GO 
	CREATE OR ALTER PROC USP_TransferBalanceThenRollback
	AS
	BEGIN
		-- TRY block
		BEGIN TRY
			-- Begin Transaction
			BEGIN TRAN

			-- Subtract from Id 101
			UPDATE AccountBalance
			SET Balance -= 500
			WHERE AccountId = 101

			-- Addd to Id 102
			UPDATE AccountBalance
			SET Balance += 500
			WHERE AccountId = 102
			
			-- Rollback transaction
			ROLLBACK
		END TRY

		-- CATCH block
		BEGIN CATCH
			-- Selecting some error info
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

-- Selecting balance before & after the stored procedure
-- Before execution 
SELECT * FROM AccountBalance

-- Executing the stored procedure
EXEC USP_TransferBalanceThenRollback

-- After execution
SELECT * FROM AccountBalance


------------------------------------------------------------------

/**************************************************************
Question 3:-												  *
Write a transaction that checks if Account 101 has sufficient *
balance before transferring $2000 to Account 102. 			  *
If insufficient, rollback the transaction. 					  *
If sufficient, commit the transaction. 						  *
***************************************************************/

GO 
	CREATE OR ALTER PROC USP_TransferBalanceAfterCheck
						 @User_id INT,
						 @TransferedBalance INT
	AS
	BEGIN
		-- TRY block
		BEGIN TRY
			-- Begin Transaction
			BEGIN TRAN

			-- Declare a variable to save the current 
			-- balanace of a specific user
			DECLARE @CurrentBalance INT = (
				SELECT Balance
				FROM AccountBalance
				WHERE AccountId = @User_id
			);

			-- check if balance is sufficient
			IF (@CurrentBalance < @TransferedBalance)
				BEGIN
					PRINT('The total balance is insufficient')
					;THROW 50001 , 'balance is insufficient' , 1
				END
			ELSE
				BEGIN 
					
					-- Subtract from 101 account
					UPDATE AccountBalance
					SET Balance -= @TransferedBalance
					WHERE AccountId = 101

					-- Add to Id 102 account
					UPDATE AccountBalance
					SET Balance += @TransferedBalance
					WHERE AccountId = 102

					-- commit
					COMMIT;
				END			
		END TRY

		-- CATCH block
		BEGIN CATCH
			-- Selecting some error info
			SELECT ERROR_NUMBER() AS ErrorNumber,
				   ERROR_MESSAGE() AS ErrorMessage,
				   ERROR_SEVERITY() AS ErrorSeverity
			
			-- Check if there transaction
			IF(@@TRANCOUNT > 0)
			BEGIN
				-- Rollback if error happened
				ROLLBACK
			
			END

			-- printing message on the console
			PRINT('Procedure failed')

			-- throw error to the caller
			;THROW
		END CATCH
	END
GO

-- Selecting balance before & after the stored procedure
-- Before execution 
SELECT * FROM AccountBalance

-- Executing the stored procedure
EXEC USP_TransferBalanceAfterCheck 
     @User_id = 101,
	 @TransferedBalance = 11000

-- After execution
SELECT * FROM AccountBalance

------------------------------------------------------------------

/************************************************************
Question 4:-												*
Write a transaction using TRY...CATCH that transfers money 	*
from Account 101 to Account 102. If any error occurs, 		*
rollback the transaction and display the error message. 	*
*************************************************************/

GO
	CREATE OR ALTER PROC USP_TransferBalanceAfterCheckQuestion4
						 @Account_id INT,
						 @TransferedBalance INT
	AS
	BEGIN
		-- TRY block
		BEGIN TRY
			
			-- Checking if the accountId doesn't exist
			IF NOT EXISTS(SELECT 1 FROM AccountBalance WHERE AccountId = @Account_id)
			BEGIN 
				;THROW 50001, 'Account does''t exist', 1
			END

			-- Begin Transaction
			BEGIN TRAN

			-- Declare a variable to save the current 
			-- balanace of a specific user
			DECLARE @CurrentBalance INT = (
				SELECT Balance
				FROM AccountBalance
				WHERE AccountId = @Account_id
			);

			-- check if balance is sufficient
			IF (@CurrentBalance < @TransferedBalance)
				BEGIN
					PRINT('The total balance is insufficient')
					;THROW 50001 , 'balance is insufficient' , 1
				END
			ELSE
				BEGIN 
					-- Subtract from 101 account
					UPDATE AccountBalance
					SET Balance -= @TransferedBalance
					WHERE AccountId = 101

					-- Add to Id 102 account
					UPDATE AccountBalance
					SET Balance += @TransferedBalance
					WHERE AccountId = 102

					-- commit
					COMMIT;
				END			
		END TRY

		-- CATCH block
		BEGIN CATCH
			-- Selecting some error info
			SELECT ERROR_NUMBER() AS ErrorNumber,
				   ERROR_MESSAGE() AS ErrorMessage,
				   ERROR_SEVERITY() AS ErrorSeverity
			
			-- Check if there transaction
			IF(@@TRANCOUNT > 0)
			BEGIN
				-- Rollback if error happened
				ROLLBACK
			
			END

			-- printing message on the console
			PRINT('Procedure failed')

			-- throw error to the caller
			;THROW
		END CATCH
	END
GO

-- Selecting balance before & after the stored procedure
-- Before execution 
SELECT * FROM AccountBalance

-- Executing the stored procedure
EXEC USP_TransferBalanceAfterCheckQuestion4 
     @Account_id = 101,
	 @TransferedBalance = 11000

-- After execution
SELECT * FROM AccountBalance


------------------------------------------------------------------

/***********************************************************
Question 5:- 											   *
Write a transaction that uses SAVE TRANSACTION to create   *
a savepoint after the first update. Then perform a second  *
update and rollback to the savepoint if an error occurs.   *
************************************************************/

GO
	CREATE OR ALTER PROC USP_TransferBalanceWithSavePoint
						 @Account_id INT,
						 @TransferedBalance INT
	AS
	BEGIN
		-- TRY block
		BEGIN TRY
			
			-- Checking if the accountId doesn't exist
			IF NOT EXISTS(SELECT 1 FROM AccountBalance WHERE AccountId = @Account_id)
			BEGIN 
				;THROW 50001, 'Account does''t exist', 1
			END

			-- Begin Transaction
			BEGIN TRAN

			-- Declare a variable to save the current 
			-- balanace of a specific user
			DECLARE @CurrentBalance INT = (
				SELECT Balance
				FROM AccountBalance
				WHERE AccountId = @Account_id
			);

			-- check if balance is sufficient
			IF (@CurrentBalance < @TransferedBalance)
				BEGIN
					PRINT('The total balance is insufficient')
					;THROW 50001 , 'balance is insufficient' , 1
				END
			ELSE
				BEGIN 
					-- Subtract from 101 account
					UPDATE AccountBalance
					SET Balance -= @TransferedBalance
					WHERE AccountId = 101

					-- Save point 1
					SAVE TRANSACTION SavePoint_1

					-- Second try catch
					BEGIN TRY
						-- Add to Id 102 account
						UPDATE AccountBalance
						SET Balance += @TransferedBalance
						WHERE AccountId = 102
					END TRY

					BEGIN CATCH
						
						-- printing an error msg
						PRINT('there is an error occured with the second update')

						-- if error happened ROLLBACK to SavePoint_1
						ROLLBACK TRANSACTION SavePoint_1

						;THROW
					END CATCH

					-- commit
					COMMIT;
				END			
		END TRY

		-- CATCH block
		BEGIN CATCH
			-- Selecting some error info
			SELECT ERROR_NUMBER() AS ErrorNumber,
				   ERROR_MESSAGE() AS ErrorMessage,
				   ERROR_SEVERITY() AS ErrorSeverity
			
			-- Check if there transaction
			IF(@@TRANCOUNT > 0)
			BEGIN
				-- Rollback if error happened
				ROLLBACK
			
			END

			-- printing message on the console
			PRINT('Procedure failed')

			-- throw error to the caller
			;THROW
		END CATCH
	END
GO

-- Selecting balance before & after the stored procedure
-- Before execution 
SELECT * FROM AccountBalance

-- Executing the stored procedure
EXEC USP_TransferBalanceWithSavePoint 
     @Account_id = 101,
	 @TransferedBalance = 11000

-- After execution
SELECT * FROM AccountBalance


------------------------------------------------------------------

/****************************************************************
Question 6:-													*
Write a transaction with nested BEGIN TRANSACTION statements. 	*
Display @@TRANCOUNT at each level to demonstrate how it changes.*
*****************************************************************/

GO
	CREATE OR ALTER PROC USP_multipleTransactions
	AS
	BEGIN
		-- first transaction
		BEGIN TRAN 
			
			-- selecting transactions count
			SELECT @@TRANCOUNT AS FirstSelect

			-- Second transaction
			BEGIN TRAN

				-- selecting transactions count
				SELECT @@TRANCOUNT AS SecondSelect

			COMMIT -- subtracting one from @@TRANCOUNT

			-- selecting transactions count
			SELECT @@TRANCOUNT AS ThirdSelect

		COMMIT -- Subtracting one from @@TRANCOUNT
	END
GO

-- executing the stored procedure
EXEC USP_multipleTransactions


------------------------------------------------------------------

/**************************************************************
Question 7:-												  *
Demonstrate ATOMICITY by writing a transaction that performs  *
multiple updates. 											  *
Show that if one fails, all are rolled back. 				  *
***************************************************************/

GO
	CREATE OR ALTER PROC USP_DemonstrateATOMICITY
	AS
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				-- Subtract from 101 account
				UPDATE AccountBalance
				SET Balance -= 500
				WHERE AccountId = 101

				-- Add to Id 102 account
				UPDATE AccountBalance
				SET Balance += 500
				WHERE AccountId = 102
			COMMIT
		END TRY


		BEGIN CATCH 
			IF(@@TRANCOUNT > 0)
			BEGIN
				-- here is the line that guarantees
				-- the AUTOMICITY concept
				ROLLBACK;
				THROW
			END
		END CATCH
	END
GO

-- Testing the stored procedure
EXEC USP_DemonstrateATOMICITY

------------------------------------------------------------------

/**************************************************************
Question 8:-												  *
Demonstrate CONSISTENCY by writing a transaction that ensures *
the total balance across all accounts remains constant. 	  *
Calculate total before and after transfer.					  *
***************************************************************/

GO
	CREATE OR ALTER PROC USP_DemonstrateCONSISTENCY
	AS
	BEGIN
		BEGIN TRY
			-- Calculate total BEFORE transfer
			DECLARE @TotalBefore INT = (SELECT SUM(Balance) FROM AccountBalance);
		
			PRINT 'BEFORE TRANSFER:'
			PRINT 'TOTAL: ' + CAST(@TotalBefore AS VARCHAR)
		
			-- Begin transaction
			BEGIN TRAN
		
			-- Transfer money
			UPDATE AccountBalance 
			SET Balance = Balance - 500 
			WHERE AccountId = 101
			
			UPDATE AccountBalance 
			SET Balance = Balance + 500 
			WHERE AccountId = 102
		
			COMMIT
		
			-- Calculate total AFTER transfer
			DECLARE @TotalAfter INT = (SELECT SUM(Balance) FROM AccountBalance);
		
			PRINT 'AFTER TRANSFER:'
			PRINT 'TOTAL: ' + CAST(@TotalAfter AS VARCHAR)
		
			IF @TotalBefore = @TotalAfter
			BEGIN
				PRINT ' CONSISTENCY PROVEN'
			END
		
		END TRY
		BEGIN CATCH
			IF(@@TRANCOUNT > 0) 
			ROLLBACK
			SELECT ERROR_MESSAGE(),
				   ERROR_NUMBER(),
				   ERROR_SEVERITY()
		END CATCH
	END
GO

-- Testing the procedure: 
EXEC USP_DemonstrateCONSISTENCY 


------------------------------------------------------------------

/************************************************************
Question 9:-												*
Demonstrate ISOLATION by setting different isolation levels *
and explaining their effects. Use READ UNCOMMITTED, READ 	*
COMMITTED, and SERIALIZABLE. 								*
*************************************************************/

-- Create a test table
CREATE TABLE Accounts (
    AccountId INT PRIMARY KEY,
    Balance DECIMAL(10, 2)
);

-- Insert sample data
INSERT INTO Accounts VALUES (1, 1000.00);
INSERT INTO Accounts VALUES (2, 500.00);

GO


-- SCENARIO 1: READ UNCOMMITTED
-- Effect: Dirty Reads allowed 
--         (reading uncommitted changes)
-- Risk: You can read data that another 
--       transaction hasn't committed yet

-- SESSION 1: Start a transaction and update without committing
BEGIN TRANSACTION;
	UPDATE Accounts 
	SET 
		Balance = Balance - 100 
	WHERE AccountId = 1;

-- SESSION 2 (in another query window): Read uncommitted data
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
	SELECT 
		'READ UNCOMMITTED' AS IsolationLevel, 
		AccountId, 
		Balance 
	FROM Accounts 
	WHERE AccountId = 1;
-- Result: should be 900 
COMMIT;

-- SESSION 1: Rollback the transaction
ROLLBACK;

-- SESSION 2: Read again
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
	SELECT 
		'READ UNCOMMITTED (After Rollback)' AS IsolationLevel, 
		AccountId, 
		Balance 
	FROM Accounts 
	WHERE AccountId = 1;
-- Result: Now shows Balance = 1000 (the original value)
--         You read dirty data that was rolled back!
COMMIT;

GO


-- SCENARIO 2: READ COMMITTED (DEFAULT in SQL Server)
-- Effect: Prevents Dirty Reads but allows Non-repeatable Reads
-- Risk: Another transaction can modify data between your reads

-- SESSION 1: Start a transaction
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
	SELECT 
		'READ COMMITTED (First Read)' AS IsolationLevel, 
		AccountId, 
		Balance 
	FROM Accounts 
	WHERE AccountId = 1;
-- Result: Balance = 1000


-- SESSION 2 (in another query window): Update and commit
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
	UPDATE Accounts 
	SET Balance = Balance + 200 
	WHERE AccountId = 1;
COMMIT;

-- SESSION 1: Read the same row again
	SELECT 
		'READ COMMITTED (Second Read)' AS IsolationLevel, 
		AccountId, 
		Balance 
	FROM Accounts 
	WHERE AccountId = 1;
-- Result: Balance = 1200 (DIFFERENT from first read!)
-- Non-repeatable read occurred
COMMIT;

GO


-- SCENARIO 3: SERIALIZABLE
-- Effect: Prevents Dirty Reads, Non-repeatable Reads, and Phantom Reads
-- Risk: Highest isolation but causes significant locking and slower performance

-- SESSION 1: Start a serializable transaction
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
	SELECT 
		'SERIALIZABLE (First Read)' AS IsolationLevel,
		* 
	FROM Accounts 
	WHERE AccountId = 1;
-- Result: Balance = 1200


-- SESSION 2 (in another query window): Try to update
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
-- This will WAIT because Session 1 has a lock
	UPDATE Accounts 
	SET 
		Balance = Balance - 50 
	WHERE AccountId = 1;

-- SESSION 1: Read again (without any changes from Session 2)
	SELECT 
		'SERIALIZABLE (Second Read)' AS IsolationLevel, 
		* 
	FROM Accounts 
	WHERE AccountId = 1;
-- Result: Balance = 1200 (SAME as first read - guaranteed!)
COMMIT;

-- SESSION 2: Now the update proceeds since Session 1 released the lock
-- Result: Balance = 1150
COMMIT;

GO


------------------------------------------------------------------

/********************************************************
Question 10:-											*
Demonstrate DURABILITY by committing a transaction and 	*
explaining that the changes will persist even after 	*
system restart or failure. 								*
*********************************************************/

GO
	CREATE OR ALTER PROC USP_DemonstrateDURABILITY
	AS
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				-- Subtract from 101 account
				UPDATE AccountBalance
				SET Balance -= 500
				WHERE AccountId = 101

				-- Add to Id 102 account
				UPDATE AccountBalance
				SET Balance += 500
				WHERE AccountId = 102
			COMMIT
		END TRY


		BEGIN CATCH 
			IF(@@TRANCOUNT > 0)
			BEGIN
				ROLLBACK;
				THROW
			END
		END CATCH
	END
GO


-- Answer:
-- Here once COMMIT line is executed and the transaction is 
-- commited then it will be stored in the transaction log file 
-- which contains all the commited transactions, which means
-- which record is changed, in which table, what is the 
-- new values and so on, then this should be stored on the disk
-- I mean the log file not the pages as storing log file is much
-- easier (very low cost), but if pages r saved each time this 
-- will cost alot.
-- and if for some reason the power is cut what will happend is 
-- that it's known from the log file that is stored in the disk
-- what change should happen on the real pages.

--------------------------------------------------------------------

/***********************************************************
Question 11:-											   *
Write a query to check the current transaction count       *
(@@TRANCOUNT) 											   *
and demonstrate how it changes within nested transactions. *
************************************************************/

GO
	CREATE OR ALTER PROC USP_multipleTransactionsEffectOnTranCount
	AS
	BEGIN
		-- first transaction
		BEGIN TRAN 
			
			-- selecting transactions count
			SELECT @@TRANCOUNT AS FirstSelect

			-- Second transaction
			BEGIN TRAN

				-- selecting transactions count
				SELECT @@TRANCOUNT AS SecondSelect

			COMMIT -- subtracting one from @@TRANCOUNT

			-- selecting transactions count
			SELECT @@TRANCOUNT AS ThirdSelect

		COMMIT -- Subtracting one from @@TRANCOUNT
	END
GO

-- Testing the procedure
EXEC USP_multipleTransactionsEffectOnTranCount


--------------------------------------------------------------------

/*******************************************************************
Question 12:-													   *
Write a transaction that logs all changes to the AuditTrail table. *
Include before and after values for updates.					   *
********************************************************************/

GO
	CREATE OR ALTER TRIGGER Trg_Log
	ON AccountBalance
	AFTER UPDATE
	AS
	BEGIN
		INSERT INTO AuditTrail(TableName, Operation, OldValue, NewValue, AuditDate, UserName)
		SELECT
			'AccountBalance',
			'TransferBalance',
			D.Balance,
			I.Balance,
			GETDATE(),
			D.AccountName
		FROM inserted I
		INNER JOIN deleted D
		ON I.AccountId = D.AccountId
	END
GO

-- Testing the procedure
-- Executing the stored procedure of 1st question
EXEC USP_TransferBalance

-- select the AuditTrail table
SELECT * FROM AuditTrail


--------------------------------------------------------------------

/*************************************************************
Question 13:-												 *
Write a transaction that demonstrates the difference between *
COMMIT and ROLLBACK by creating two identical transactions,  *
committing one and rolling back the other. 					 *
**************************************************************/

-- Effect of COMMIT on transaction
GO
	CREATE OR ALTER PROC USP_EffectOfCOMMITOnTransaction
	AS
	BEGIN
		
		-- Printing a label for this procedure
		SELECT('This procedure shows the effect of commit on transaction')

		-- first transaction
		BEGIN TRAN 
			
			-- selecting transactions count
			SELECT @@TRANCOUNT AS TRANCOUNT_afterFirstTransaction

			-- Second transaction
			BEGIN TRAN

				-- selecting transactions count
				SELECT @@TRANCOUNT AS TRANCOUNT_afterSecondTransaction

			COMMIT -- subtracting one from @@TRANCOUNT

			-- selecting transactions count
			SELECT @@TRANCOUNT AS TRANCOUNT_afterFirstCommit

		COMMIT -- Subtracting one from @@TRANCOUNT

		-- selecting transactions count
		SELECT @@TRANCOUNT AS TRANCOUNT_afterSecondCommit
	END
GO

-- effect of ROLLBACK on transaction
GO
	CREATE OR ALTER PROC USP_EffectOfROLLBACKOnTransaction
	AS
	BEGIN
		
		-- Printing a label for this procedure
		SELECT('This procedure shows the effect of rollback on transaction')

		-- first transaction
		BEGIN TRAN 
			
			-- selecting transactions count
			SELECT @@TRANCOUNT AS TRANCOUNT_afterFirstTransaction

			-- Second transaction
			BEGIN TRAN

				-- selecting transactions count
				SELECT @@TRANCOUNT AS TRANCOUNT_afterSecondTransaction

			-- ROLLBACK
			ROLLBACK -- here TRANCOUNT will be 0

			-- selecting transactions count
			SELECT @@TRANCOUNT AS TRANCOUNT_afterROLLBACK
	END
GO


-- Testing the stored procedures

-- 1. Showing the effect of COMMIT on Transaction
EXEC USP_EffectOfCOMMITOnTransaction

-- 2. Showing the effect of ROLLBACK on Transaction
EXEC USP_EffectOfROLLBACKOnTransaction


--------------------------------------------------------------------

/**********************************************************
Question 14:-											  *
Write a transaction that enforces a business rule: "Total *
withdrawals in a single transaction cannot exceed $5000". *
If violated, rollback the transaction. 					  *
***********************************************************/

GO 
	CREATE OR ALTER PROC USP_WithdrawalWithBusinessRule
						 @TransferedBalance INT
	AS
	BEGIN
		-- TRY block
		BEGIN TRY
			-- Begin Transaction
			BEGIN TRAN

			-- Declare a variable to save the current 
			-- balanace of account 101
			DECLARE @CurrentBalance INT = (
				SELECT Balance
				FROM AccountBalance
				WHERE AccountId = 101
			);

			-- check if balance is sufficient
			IF (@CurrentBalance < @TransferedBalance) 
				BEGIN
					PRINT('The total balance is insufficient')
					;THROW 50001 , 'balance is insufficient' , 1
				END
			ELSE IF(@TransferedBalance > 5000)
				BEGIN
					PRINT('Total withdrawals in a single transaction cannot exceed $5000')
					;THROW 50002 , 'a single transaction cannot exceed $5000' , 1
				END
			ELSE
				BEGIN 
					
					-- Subtract from 101 account
					UPDATE AccountBalance
					SET Balance -= @TransferedBalance
					WHERE AccountId = 101

					-- Add to Id 102 account
					UPDATE AccountBalance
					SET Balance += @TransferedBalance
					WHERE AccountId = 102

					-- commit
					COMMIT;
				END			
		END TRY

		-- CATCH block
		BEGIN CATCH
			-- Selecting some error info
			SELECT ERROR_NUMBER() AS ErrorNumber,
				   ERROR_MESSAGE() AS ErrorMessage,
				   ERROR_SEVERITY() AS ErrorSeverity
			
			-- Check if there transaction
			IF(@@TRANCOUNT > 0)
			BEGIN
				-- Rollback if error happened
				ROLLBACK
			
			END

			-- printing message on the console
			PRINT('Procedure failed')

			-- throw error to the caller
			;THROW
		END CATCH
	END
GO

-- Testing the procedure
-- 1. business rule 1: a withdrawal can't withdraw more than 5000$
EXEC USP_WithdrawalWithBusinessRule 
	 @TransferedBalance = 5001

-- 2. business rule 2: transfer balance is more than the current balance
EXEC USP_WithdrawalWithBusinessRule 
	 @TransferedBalance = 11000


--------------------------------------------------------------------------

/***********************************************************************
Question 15:-														   *
Write a transaction that uses explicit locking hints (WITH (UPDLOCK))  *
to prevent concurrent modifications during a transfer. 				   *
************************************************************************/

GO 
	CREATE OR ALTER PROC USP_TransferWithUpdateLock
						 @TransferedBalance INT
	AS
	BEGIN
		-- TRY block
		BEGIN TRY
			-- Begin Transaction
			BEGIN TRAN

			-- Declare a variable to save the current 
			-- balanace of account 101
			DECLARE @CurrentBalance INT = (
				SELECT Balance
				FROM AccountBalance
				WHERE AccountId = 101
			);

			-- check if balance is sufficient
			IF (@CurrentBalance < @TransferedBalance) 
				BEGIN
					PRINT('The total balance is insufficient')
					;THROW 50001 , 'balance is insufficient' , 1
				END
			ELSE IF(@TransferedBalance > 5000)
				BEGIN
					PRINT('Total withdrawals in a single transaction cannot exceed $5000')
					;THROW 50002 , 'a single transaction cannot exceed $5000' , 1
				END
			ELSE
				BEGIN 
					-- Lock the rows in the AccountBalance

					-- account 101
					SELECT 
						Balance
					FROM AccountBalance WITH(UPDLOCK , ROWLOCK)
					WHERE AccountId = 101

					-- account 102
					SELECT 
						Balance
					FROM AccountBalance WITH(UPDLOCK , ROWLOCK)
					WHERE AccountId = 102


					-- Subtract from 101 account
					UPDATE AccountBalance
					SET Balance -= @TransferedBalance
					WHERE AccountId = 101

					-- Add to Id 102 account
					UPDATE AccountBalance
					SET Balance += @TransferedBalance
					WHERE AccountId = 102

					-- commit
					COMMIT;
				END			
		END TRY

		-- CATCH block
		BEGIN CATCH
			-- Selecting some error info
			SELECT ERROR_NUMBER() AS ErrorNumber,
				   ERROR_MESSAGE() AS ErrorMessage,
				   ERROR_SEVERITY() AS ErrorSeverity
			
			-- Check if there transaction
			IF(@@TRANCOUNT > 0)
			BEGIN
				-- Rollback if error happened
				ROLLBACK
			
			END

			-- printing message on the console
			PRINT('Procedure failed')

			-- throw error to the caller
			;THROW
		END CATCH
	END
GO

-- Testing the procedure
EXEC USP_TransferWithUpdateLock
	 @TransferedBalance = 500


--------------------------------------------------------------------------

/**************************************************************
Question 16:-												  *
Write a comprehensive error handling transaction that catches *
specific error numbers and handles them differently. 		  *
Handle: Constraint violations, insufficient funds, 			  *
        and general errors. 								  *
***************************************************************/

GO 
	CREATE OR ALTER PROC USP_HandlingError
						 @TransferedBalance INT
	AS
	BEGIN
		-- TRY block
		BEGIN TRY
			-- Begin Transaction
			BEGIN TRAN

			-- Declare a variable to save the current 
			-- balanace of account 101
			DECLARE @CurrentBalance INT = (
				SELECT Balance
				FROM AccountBalance
				WHERE AccountId = 101
			);

			-- check if balance is sufficient
			IF (@CurrentBalance < @TransferedBalance) 
				BEGIN
					PRINT('The total balance is insufficient')
					;THROW 50001 , 'balance is insufficient' , 1
				END
			ELSE IF(@TransferedBalance > 5000)
				BEGIN
					PRINT('Total withdrawals in a single transaction cannot exceed $5000')
					;THROW 50002 , 'a single transaction cannot exceed $5000' , 1
				END
			ELSE
				BEGIN 
					
					-- Subtract from 101 account
					UPDATE AccountBalance
					SET Balance -= @TransferedBalance
					WHERE AccountId = 101

					-- Add to Id 102 account
					UPDATE AccountBalance
					SET Balance += @TransferedBalance
					WHERE AccountId = 102

					-- commit
					COMMIT;
				END			
		END TRY

		-- CATCH block
		BEGIN CATCH
			-- Selecting some error info
			SELECT ERROR_NUMBER() AS ErrorNumber,
				   ERROR_MESSAGE() AS ErrorMessage,
				   ERROR_SEVERITY() AS ErrorSeverity
			
			-- Check if there transaction
			IF(@@TRANCOUNT > 0)
			BEGIN
				-- Rollback if error happened
				ROLLBACK
			
			END

			-- printing message on the console
			PRINT('Procedure failed')

			-- Handle each error independently
			DECLARE @Message VARCHAR(100);
			--*-- 1. Constraint violation
			IF (ERROR_NUMBER() = 547)
			BEGIN 
				SET @Message = 'this is constraint violation error';
			END
			ELSE IF(ERROR_NUMBER() = 50002)
			BEGIN
				SET @Message = 'this is transaction limit exceeded error';
			END
			ELSE IF(ERROR_NUMBER() = 50001)
			BEGIN
				SET @Message = 'this is insufficient balance error';
			END

			SELECT @Message AS ErrorMsg

			-- throw error to the caller
			;THROW
		END CATCH
	END
GO

-- Testing the procedure
EXEC USP_HandlingError
	 @TransferedBalance = 50001

EXEC USP_HandlingError
	 @TransferedBalance = 11000


--------------------------------------------------------------------------

/***********************************************************
Question 17:-											   *
Write a transaction monitoring query that shows all active *
transactions in the database, including their status, 	   *
start time, and session information. 					   *
************************************************************/

SELECT 
	a.transaction_status,
	a.transaction_begin_time,
	s1.session_id,
	s2.login_time,
	s2.login_name
	
FROM sys.dm_tran_active_transactions a
INNER JOIN sys.dm_tran_session_transactions s1
  ON a.transaction_id = s1.transaction_id
INNER JOIN sys.dm_exec_sessions s2
  ON s1.session_id = s2.session_id