/*
Function: Sample test function
Purpose: Executes test on an object and returns the results as a table
Input:
  - Test Object Name
Returns:
  - Table with test results
Usage:

DECLARE @TestResult     VARCHAR(100);
DECLARE @TestOutput     VARCHAR(MAX);
DECLARE @TestTimestamp  DATETIME2(7);
DECLARE @TestObject     VARCHAR(255) = 'SomeTestObject';
DECLARE @TestCode       NVARCHAR(MAX);
SET @TestCode = N'select @TestResult = TestResult, @TestOutput = TestOutput, @TestTimestamp = TestTimestamp from [ut].[test_SampleTestFunction] (''someTestObject'')';
EXEC sp_executesql @TestCode,
    N'@TestObject VARCHAR(255), @TestResult VARCHAR(100) OUT, @TestOutput VARCHAR(MAX) OUT, @TestTimestamp DATETIME2(7) OUT',
    @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT;
PRINT concat('Test Result: ', @TestResult);
PRINT concat('Test Output: ', @TestOutput);
PRINT concat('Test Timestamp: ', @TestTimestamp);

*/

if OBJECT_ID('[ut].[test_SampleTestFunction]','TF') IS NOT NULL
    drop function [ut].[test_SampleTestFunction]
GO

create function [ut].[test_SampleTestFunction] (@TestObject VARCHAR(255))
returns @TestResultsTable TABLE (
    TestResult      VARCHAR(100) NOT NULL,
    TestOutput      VARCHAR(MAX) NOT NULL,
    TestTimestamp   DATETIME2(7) NOT NULL
)
as
begin

    DECLARE @TestResult    VARCHAR(100) = 'Pass / Fail';
    DECLARE @TestOutput    VARCHAR(MAX) = 'Sample test output (# tests completed, # tests failed). Any other test notes.';
    DECLARE @TestTimestamp DATETIME2(7) = SYSDATETIME();

    insert @TestResultsTable
    select @TestResult, @TestOutput, @TestTimestamp;

    RETURN;
end;
