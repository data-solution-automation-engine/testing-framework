/*
Function: Checks if a table is empty.
Purpose: If the table does contain any rows, the test is failed.
Input:
  - Table name
Returns:
  - Table with test results
Usage:

DECLARE @TestResult     VARCHAR(100);
DECLARE @TestOutput     VARCHAR(MAX);
DECLARE @TestTimestamp  DATETIME2(7);
DECLARE @TestObject     VARCHAR(255) = '[omd].[MODULE_PARAMETER]';
DECLARE @TestCode       NVARCHAR(MAX);
set @TestCode = N'EXEC [ut].[test_AssertEmptyTable] @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT'
EXEC sp_executesql @TestCode,
    N'@TestObject VARCHAR(255), @TestResult VARCHAR(100) OUT, @TestOutput VARCHAR(MAX) OUT, @TestTimestamp DATETIME2(7) OUT',
    @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT;
PRINT concat('Test Result: ', @TestResult);
PRINT concat('Test Output: ', @TestOutput);
PRINT concat('Test Timestamp: ', @TestTimestamp);

*/

if OBJECT_ID('[ut].[test_AssertEmptyTable]','P') IS NOT NULL
    drop procedure [ut].[test_AssertEmptyTable]
GO

create procedure [ut].[test_AssertEmptyTable]
    @TestObject     VARCHAR(255),
    @TestResult     VARCHAR(100) = NULL OUTPUT,
    @TestOutput     VARCHAR(MAX) = NULL OUTPUT,
    @TestTimestamp  DATETIME2(7) = NULL OUTPUT
as
begin
    DECLARE @ObjectId INT = OBJECT_ID(@TestObject,'U');
    set @TestTimestamp = SYSDATETIME();

    if @ObjectId IS NULL begin
        set @TestResult = 'Error';
        set @TestOutput = 'Function: <AssertEmptyTable>. TestObject: <'+ISNULL(@TestObject,'NULL')+'>. Error: Table was not found.';
    end
    else begin
        DECLARE @Empty      INT;
        DECLARE @QuotedName VARCHAR(255) = QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectId))+'.'+QUOTENAME(OBJECT_NAME(@ObjectId));
        DECLARE @Query      NVARCHAR(MAX) = 'select @Empty = case when NOT EXISTS(select NULL from '+@QuotedName+') THEN 1 ELSE 0 END;';
        EXEC sp_executesql @Query, N'@Empty INT OUT', @Empty OUT;
        if @Empty = 1 begin
            set @TestResult = 'Pass';
            set @TestOutput = 'Function: <AssertEmptyTable>. TestObject: <'+ISNULL(@TestObject,'NULL')+'>. OK: Table was empty.';
        end
        else begin
            set @TestResult = 'Fail';
            set @TestOutput = 'Function: <AssertEmptyTable>. TestObject: <'+ISNULL(@TestObject,'NULL')+'>. Fail: Table was not empty.';
        end
    end
end;
