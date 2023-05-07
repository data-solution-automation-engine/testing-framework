/*
Function: Compares two values (Expected and Actual) for equality.
Purpose: If the values are not equal, the test is failed.
Input:
  - Test Object
  - Expected value
  - Actual value
Returns:
  - Table with test results
Usage:

DECLARE @TestResult     VARCHAR(100);
DECLARE @TestOutput     VARCHAR(MAX);
DECLARE @TestTimestamp  DATETIME2(7);
DECLARE @TestObject     VARCHAR(255) = 'SomeTestObject';
DECLARE @TestCode       NVARCHAR(MAX);
SET @TestCode = N'select @TestResult = TestResult, @TestOutput = TestOutput, @TestTimestamp = TestTimestamp from [ut].[test_AssertEquals] (@TestObject, ''ExpectedValue'', ''ActualValue'')';
EXEC sp_executesql @TestCode,
    N'@TestObject VARCHAR(255), @TestResult VARCHAR(100) OUT, @TestOutput VARCHAR(MAX) OUT, @TestTimestamp DATETIME2(7) OUT',
    @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT;
PRINT concat('Test Result: ', @TestResult);
PRINT concat('Test Output: ', @TestOutput);
PRINT concat('Test Timestamp: ', @TestTimestamp);

*/

--if OBJECT_ID('[ut].[test_AssertEquals]','TF') IS NOT NULL
--    drop function [ut].[test_AssertEquals]
--GO

create function [ut].[test_AssertEquals] (@TestObject VARCHAR(255), @Expected SQL_VARIANT, @Actual SQL_VARIANT)
returns @TestResultsTable TABLE (
    TestResult      VARCHAR(100) NOT NULL,
    TestOutput      VARCHAR(MAX) NOT NULL,
    TestTimestamp   DATETIME2(7) NOT NULL
)
as
begin

    DECLARE @TestResult    VARCHAR(100) = 'Fail';
    DECLARE @TestOutput    VARCHAR(MAX) = 'Function: <AssertEquals>. TestObject: <'+ISNULL(@TestObject,'NULL')+'>. Expected: <'+ISNULL(CAST(@Expected AS NVARCHAR(MAX)),'NULL')+'>. Actual: <'+ISNULL(CAST(@Actual AS NVARCHAR(MAX)),'NULL')+'>.';
    DECLARE @TestTimestamp DATETIME2(7) = SYSDATETIME();

    if ((@Expected = @Actual) OR (@Actual IS NULL AND @Expected IS NULL)) begin
        set @TestResult = 'Pass';
    end

    insert @TestResultsTable
    select @TestResult, @TestOutput, @TestTimestamp;

    RETURN;
end;
