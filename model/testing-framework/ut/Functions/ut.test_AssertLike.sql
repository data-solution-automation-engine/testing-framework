/*
Function: Checks if the actual value matches the expected pattern.
Purpose: If it does not match, the test is failed.
Input:
  - Test Object
  - Expected pattern
  - Actual value
Returns:
  - Table with test results
Usage:

DECLARE @TestResult     VARCHAR(100);
DECLARE @TestOutput     VARCHAR(MAX);
DECLARE @TestTimestamp  DATETIME2(7);
DECLARE @TestObject     VARCHAR(255) = 'SomeTestObject';
DECLARE @TestCode       NVARCHAR(MAX);
SET @TestCode = N'select @TestResult = TestResult, @TestOutput = TestOutput, @TestTimestamp = TestTimestamp from [ut].[test_AssertLike] (@TestObject, ''ExpectedPattern'', ''ActualValue'')';
EXEC sp_executesql @TestCode,
    N'@TestObject VARCHAR(255), @TestResult VARCHAR(100) OUT, @TestOutput VARCHAR(MAX) OUT, @TestTimestamp DATETIME2(7) OUT',
    @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT;
PRINT concat('Test Result: ', @TestResult);
PRINT concat('Test Output: ', @TestOutput);
PRINT concat('Test Timestamp: ', @TestTimestamp);

*/

if OBJECT_ID('[ut].[test_AssertLike]','TF') IS NOT NULL
    drop function [ut].[test_AssertLike]
GO

create function [ut].[test_AssertLike] (@TestObject VARCHAR(255), @ExpectedPattern NVARCHAR(255), @Actual NVARCHAR(MAX))
returns @TestResultsTable TABLE (
    TestResult      VARCHAR(100) NOT NULL,
    TestOutput      VARCHAR(MAX) NOT NULL,
    TestTimestamp   DATETIME2(7) NOT NULL
)
as
begin

    DECLARE @TestResult    VARCHAR(100) = 'Fail';
    DECLARE @TestOutput    VARCHAR(MAX) = 'Function: <AssertLike>. TestObject: <'+ISNULL(@TestObject,'NULL')+'>. Expected pattern: <'+ISNULL(CAST(@ExpectedPattern AS NVARCHAR(MAX)),'NULL')+'>. Actual: <'+ISNULL(CAST(@Actual AS NVARCHAR(MAX)),'NULL')+'>.';
    DECLARE @TestTimestamp DATETIME2(7) = SYSDATETIME();

    if ((@Actual LIKE @ExpectedPattern) OR (@Actual IS NULL AND @ExpectedPattern IS NULL)) begin
        set @TestResult = 'Pass';
    end

    insert @TestResultsTable
    select @TestResult, @TestOutput, @TestTimestamp;

    RETURN;
end;
