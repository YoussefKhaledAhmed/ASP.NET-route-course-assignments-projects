/*********************************************************
 * File name: SQL_session12-part2-DDL_trigger            *
 * Author: Youssef Khaled                                *
 * Date: 24/01/2026 | dd/mm/yyyy                         *
 * Description: Solving session_12 assignment part 2	 *
 *              DDL trigger part                         *
 *********************************************************/

/* Use StackOverFlow DB */
USE StackOverflow2010;

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
Question 1:-													*
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
		ROLLBACK
	END
GO

-- Testing this DLL trigger
CREATE TABLE Test_PreventDropDLL(id INT IDENTITY)

DROP TABLE Test_PreventDropDLL

SELECT * FROM ChangeLog

--------------------------------------------------------------------------

/***********************************************************
Question 2:-											   *
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
Question 3:-												 *
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
				@LogData.value('(/EVENT_INSTANCE/ObjectName)[1]' , 'NVARCHAR(256)'),
				@LogData.value('(/EVENT_INSTANCE/SchemaName)[1]' , 'NVARCHAR(256)'),
				SYSTEM_USER,
				@LogData.value('(/EVENT_INSTANCE/LoginName)[1]' , 'NVARCHAR(256)'),
				@LogData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]' , 'NVARCHAR(MAX)')
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
