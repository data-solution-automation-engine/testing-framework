/*
Process: Run Test
Purpose: Executes test's CODE from the [ut].[TEST] table for the respective test NAME
Input:
  - Test Name
  - Plan Id (if run as part of a plan)
  - Debug flag (Y/N, default N)
Returns:
  - Test Id
  - Test timestamp
  - Test result (Pass/Fail)
  - Result description (Output)
  - Test code
Usage:

EXEC [ut].[RunTest]
    @TestName = 'MyNewTest',
    @PlanId = NULL,
    @Debug = 'Y';

*/

--if OBJECT_ID('[ut].[RunTest]','P') IS NOT NULL
--    drop procedure [ut].[RunTest]
--GO

CREATE PROCEDURE [ut].[RunTest]
    @TestName       VARCHAR(255),
    @PlanId         INT = NULL,
    @Debug          CHAR(1) = 'N',
    @TestId         INT = NULL OUTPUT,
    @TestCode       NVARCHAR(MAX) = NULL OUTPUT,
    @TestResult     VARCHAR(100) = NULL OUTPUT,
    @TestOutput     VARCHAR(MAX) = NULL OUTPUT,
    @TestTimestamp  DATETIME2(7) = NULL OUTPUT
AS
BEGIN

    DECLARE @Area           VARCHAR(100);
    DECLARE @TestObject     VARCHAR(255);
    DECLARE @TestObjectType VARCHAR(100);
    DECLARE @Enabled        CHAR(1);

    SELECT
        @TestId = [ID],
        @TestCode = [TEST_CODE],
        @Area = [AREA],
        @TestObject = [TEST_OBJECT],
        @TestObjectType = [TEST_OBJECT_TYPE],
        @Enabled = [ENABLED]
    FROM [ut].[TEST] WHERE [NAME] = @TestName;

    IF @Debug = 'Y' BEGIN
        PRINT concat('The Test ID retrieved is: ''', @TestId, '''.');
        PRINT concat('The Test Area retrieved is: ''', @Area, '''.');
        PRINT concat('The Test Object retrieved is: ''', @TestObject, '''.');
        PRINT concat('The Test Object Type retrieved is: ''', @TestObjectType, '''.');
        PRINT concat('The Enabled flag retrieved is: ''', @Enabled, '''.');
        PRINT concat('The test executable code retrieved is: ''', @TestCode, '''.');
    END

    IF @Enabled = 'Y' BEGIN
        EXEC sp_executesql @TestCode,
            N'@TestObject VARCHAR(255), @TestResult VARCHAR(100) OUT, @TestOutput VARCHAR(MAX) OUT, @TestTimestamp DATETIME2(7) OUT',
            @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT;

        SET @TestCode = REPLACE(@TestCode, '@TestObject', @TestObject);

        IF @Debug = 'Y' BEGIN
            PRINT concat('Test Code: ''', @TestCode, '''.');
            PRINT concat('Test Result: ''', @TestResult, '''.');
            PRINT concat('Test Output: ''', @TestOutput, '''.');
            PRINT concat('Test Timestamp: ''', @TestTimestamp, '''.');
        END

        -- Inserting the test outcome(s) into the Test Results table.
        BEGIN TRY
            INSERT INTO [ut].[TEST_RESULTS] (PLAN_ID, TEST_ID, TEST_TIMESTAMP, OUTPUT, RESULT, TEST_CODE)
            VALUES (@PlanId, @TestId, @TestTimestamp, @TestOutput, @TestResult, @TestCode)
        END TRY
        BEGIN CATCH
            IF @Debug = 'Y' PRINT 'Test Results insert failed.';
            THROW
        END CATCH
    END

    ELSE BEGIN
        IF @Debug = 'Y' PRINT concat('Test skipped. ENABLED: ''', @Enabled, '''.');
    END
END;