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

if OBJECT_ID('[ut].[RunTest]','P') IS NOT NULL
    drop procedure [ut].[RunTest]
GO

create procedure [ut].[RunTest]
    @TestName       VARCHAR(255),
    @PlanId         INT = NULL,
    @Debug          CHAR(1) = 'N',
    @TestId         INT = NULL OUTPUT,
    @TestCode       NVARCHAR(MAX) = NULL OUTPUT,
    @TestResult     VARCHAR(100) = NULL OUTPUT,
    @TestOutput     VARCHAR(MAX) = NULL OUTPUT,
    @TestTimestamp  DATETIME2(7) = NULL OUTPUT
as
begin

    DECLARE @Area           VARCHAR(100);
    DECLARE @TestObject     VARCHAR(255);
    DECLARE @TestObjectType VARCHAR(100);
    DECLARE @Enabled        CHAR(1);

    select
        @TestId = [ID],
        @TestCode = [TEST_CODE],
        @Area = [AREA],
        @TestObject = [TEST_OBJECT],
        @TestObjectType = [TEST_OBJECT_TYPE],
        @Enabled = [ENABLED]
    from [ut].[TEST] where [NAME] = @TestName;

    if @Debug = 'Y' begin
        PRINT concat('The Test ID retrieved is: ''', @TestId, '''.');
        PRINT concat('The Test Area retrieved is: ''', @Area, '''.');
        PRINT concat('The Test Object retrieved is: ''', @TestObject, '''.');
        PRINT concat('The Test Object Type retrieved is: ''', @TestObjectType, '''.');
        PRINT concat('The Enabled flag retrieved is: ''', @Enabled, '''.');
        PRINT concat('The test executable code retrieved is: ''', @TestCode, '''.');
    end

    if @Enabled = 'Y' begin
        EXEC sp_executesql @TestCode,
            N'@TestObject VARCHAR(255), @TestResult VARCHAR(100) OUT, @TestOutput VARCHAR(MAX) OUT, @TestTimestamp DATETIME2(7) OUT',
            @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT;

        SET @TestCode = REPLACE(@TestCode, '@TestObject', @TestObject);

        if @Debug = 'Y' begin
            PRINT concat('Test Code: ''', @TestCode, '''.');
            PRINT concat('Test Result: ''', @TestResult, '''.');
            PRINT concat('Test Output: ''', @TestOutput, '''.');
            PRINT concat('Test Timestamp: ''', @TestTimestamp, '''.');
        end

        begin try
            insert into [ut].[TEST_RESULTS] (PLAN_ID, TEST_ID, TEST_TIMESTAMP, OUTPUT, RESULT, TEST_CODE)
            values (@PlanId, @TestId, @TestTimestamp, @TestOutput, @TestResult, @TestCode)
        end try
        begin catch
            if @Debug = 'Y' PRINT 'Test Results insert failed.';
            throw
        end catch
    end

    else begin
        if @Debug = 'Y' PRINT concat('Test skipped. ENABLED: ''', @Enabled, '''.');
    end
end;
