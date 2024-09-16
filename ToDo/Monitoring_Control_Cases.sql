/*
When you create a test case in tSQLt, you add it to a test class.
Before you create a test case, you should first create the test class where the test case will be located. 

Technically, a test class is a schema  with an extended property of being a tSQLt a test class object. 

To create the test class, you use the NewTestClass stored procedure (in the tSQLt schema) as shown below. 

View the existing test classes in:

SELECT *
FROM [tSQLt].[TestClasses]
*/

EXEC tSQLt.NewTestClass 'testMonitor';
--EXEC tSQLt.DropClass 'testMonitor';

/*
Tests are Stored Procedure added to the designated class (schema).
They refer to tSQLt functions and procedure to assert outcomes.

The tests can be viewed in:

SELECT *
FROM [900_Testing_Framework].[tSQLt].[Tests]
*/


/* 
TEST - Assert if Module Exceptions are occuring.
The outcome should be 0.
*/

IF OBJECT_ID('testMonitor.testModuleExceptions', 'P') IS NOT NULL
DROP PROCEDURE testMonitor.testModuleExceptions;
GO
CREATE PROCEDURE testMonitor.testModuleExceptions
AS
BEGIN
	SET ANSI_WARNINGS OFF; -- Suppress NULL elimination warning within SET operation.

    DECLARE @expected INT = 0;

    DECLARE @actual INT = 
	(
	   SELECT COALESCE(MAX(IssueCount),0) as IssueCount 
	   FROM
	   (
	     SELECT COUNT(*) as IssueCount FROM [900_Direct_Framework].[omd_reporting].[vw_EXCEPTIONS_MODULE]
	     HAVING COUNT(*)>1
	     UNION SELECT NULL
	   ) sub
    )

    --Assertion
   EXEC tSQLt.AssertEquals @expected, @actual;
END

/* 
TEST RUN
EXEC tSQLt.Run 'testMonitor.testModuleExceptions';
*/


/*
TEST - long running queries in OMD
The outcome should be 0
*/

IF OBJECT_ID('testMonitor.testLongRunningExceptions', 'P') IS NOT NULL
DROP PROCEDURE testMonitor.testLongRunningExceptions;
GO
CREATE PROCEDURE testMonitor.testLongRunningExceptions
AS
BEGIN
    DECLARE @expected INT = 0;

    DECLARE @actual INT = (
	SELECT COUNT(*) FROM [900_Direct_Framework].[omd_reporting].[vw_EXCEPTIONS_LONG_RUNNING_PROCESSES]
	WHERE HOURS_DIFFERENCE>0
    )

    --Assertion
   EXEC tSQLt.AssertEquals @expected, @actual;
END

/*
TEST RUN
EXEC tSQLt.Run 'testMonitor.testLongRunningExceptions';

EXEC [tSQLt].[XmlResultFormatter];

IF EXISTS (select * from tSQLt.TestResult where Result != 'Success') RAISERROR ('Errors encountered',16,1)
*/


/*
TEST - fragmentation
Compare the expected value of 0 fragemented tables against the runtime value.
The outcome should equal 0.
*/

IF OBJECT_ID('testMonitor.testFragmentedTableCount', 'P') IS NOT NULL
DROP PROCEDURE testMonitor.testFragmentedTableCount;
GO
CREATE PROCEDURE testMonitor.testFragmentedTableCount
AS
BEGIN
    DECLARE @expected INT = 0;
    DECLARE @actual INT = (
	SELECT 
	  COUNT(*) as FragmentedTableCount
	  --dbschemas.[name] as SchemaName,
	  --dbtables.[name] as TableName,
	  --dbindexes.[name] as IndexName,
	  --ROUND(indexstats.avg_fragmentation_in_percent,2) AS FragmentationPercentage
	FROM [200_Integration_Layer].sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
	  INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
	  INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
	  INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
	AND indexstats.index_id = dbindexes.index_id
	WHERE indexstats.database_id = DB_ID()
	AND ROUND(indexstats.avg_fragmentation_in_percent,2)>50
    )

    --Assertion
   EXEC tSQLt.AssertEquals @expected, @actual;
END

/*
TEST RUN
EXEC tSQLt.Run 'testMonitor.testFragmentedTableCount';
*/



/*
TEST - Control framework attributes
Compare the expected value of 0 fragemented tables against the runtime value
The outcome should equal 0
*/

IF OBJECT_ID('testMonitor.testDirectAttributes', 'P') IS NOT NULL
DROP PROCEDURE testMonitor.testDirectAttributes;
GO
CREATE PROCEDURE testMonitor.testDirectAttributes
AS

BEGIN

DECLARE @PsaMetadatAttributeCount INT = 
	(	
	-- PSA checks
	select count(*) from (
	select
		OBJECT_SCHEMA_NAME(object_id) as SchemaName,
		OBJECT_NAME(object_id) as TableName,
		COUNT(*) as AttributeCount
		from sys.columns 
		where [Name] in ('omd_module_instance_id', 'omd_load_ts','omd_event_ts', 'omd_source_row_id', 'omd_cdc_operation', 'omd_hash_full_record')
		and SUBSTRING(OBJECT_SCHEMA_NAME(object_id),1,4)='psa_'
	group by OBJECT_SCHEMA_NAME(object_id), OBJECT_NAME(object_id)
	having count(*)!=6
	) sub
	)
	

DECLARE @LandingMetadatAttributeCount INT = 
	(	
	-- Landing checks
    select count(*) from (
	select
		OBJECT_SCHEMA_NAME(object_id) as SchemaName,
		OBJECT_NAME(object_id) as TableName,
		COUNT(*) as AttributeCount
		from sys.columns 
		where [Name] in ('omd_module_instance_id', 'omd_load_ts','omd_event_ts', 'omd_source_row_id', 'omd_cdc_operation')
		and SUBSTRING(OBJECT_SCHEMA_NAME(object_id),1,8)='landing_'
	group by OBJECT_SCHEMA_NAME(object_id), OBJECT_NAME(object_id)
	having count(*)!=5
	) sub
	)

	BEGIN
		IF @PsaMetadatAttributeCount = 0 AND @LandingMetadatAttributeCount = 0
			EXEC tSQLt.AssertEqualsString NULL, NULL;
		ELSE
			EXEC tSQLt.Fail 'Missing Direct framework columns - please investigate.'
	END
END;

/*
TEST RUN
EXEC tSQLt.Run 'testMonitor.testDirectAttributes';
*/


/* 
TEST - Assert if Modules haven't run for a long time.
This may indicate inconsistencies in the framework (module registration) or indicate that something is not right with the scheduling.
The outcome should be 0.
*/

IF OBJECT_ID('testMonitor.testNonRunningModuleExceptions', 'P') IS NOT NULL
DROP PROCEDURE testMonitor.testNonRunningModuleExceptions;
GO
CREATE PROCEDURE testMonitor.testNonRunningModuleExceptions
AS
BEGIN
	SET ANSI_WARNINGS OFF; -- Suppress NULL elimination warning within SET operation.

    DECLARE @expected INT = 0;

    DECLARE @actual INT = 
	(
	   SELECT COALESCE(MAX(IssueCount),0) as IssueCount 
	   FROM
	   (
	     SELECT COUNT(*) as IssueCount FROM [900_Direct_Framework].[omd_reporting].[vw_EXCEPTIONS_NON_RUNNING_MODULES]
	     HAVING COUNT(*)>1
	     UNION SELECT NULL
	   ) sub
    )

    --Assertion
   EXEC tSQLt.AssertEquals @expected, @actual;
END

/* 
TEST RUN
EXEC tSQLt.Run 'testMonitor.testNonRunningModuleExceptions';
*/



/*
Run all test(s).

EXEC tSQLt.RunAll

IF EXISTS (select * from tSQLt.TestResult where Result != 'Success') RAISERROR ('Errors encountered',16,1)
*/
