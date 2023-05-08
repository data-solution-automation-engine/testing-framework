/*
Function: Check referential integrity.
Purpose: If there are keys in Satellite, that are not present in Hub, the test is failed.
Input:
  - Satellite table name
  - Hub table name
  - Test object name (key column name)
Returns:
  - Test result ('Pass', 'Fail', 'Error')
  - Test output
  - Test timestamp
Usage:

DECLARE @TestResult     VARCHAR(100);
DECLARE @TestOutput     VARCHAR(MAX);
DECLARE @TestTimestamp  DATETIME2(7);
DECLARE @TestObject     VARCHAR(255) = 'CUSTOMER_SK';
DECLARE @TestCode       NVARCHAR(MAX);
SET @TestCode = N'EXEC [ut].[test_AssertReferentialIntegrity] ''[dbo].[SAT_CUSTOMER]'', ''[dbo].[HUB_CUSTOMER]'', @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT';
EXEC sp_executesql @TestCode,
     N'@TestObject VARCHAR(255), @TestResult VARCHAR(100) OUT, @TestOutput VARCHAR(MAX) OUT, @TestTimestamp DATETIME2(7) OUT',
     @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT;
PRINT concat('Test Result: ', @TestResult);
PRINT concat('Test Output: ', @TestOutput);
PRINT concat('Test Timestamp: ', @TestTimestamp);

*/

CREATE PROCEDURE [ut].[test_AssertReferentialIntegrity]
    @SatTable       VARCHAR(255),
    @HubTable       VARCHAR(255),
    @TestObject     VARCHAR(255),
    @TestResult     VARCHAR(100) = NULL OUTPUT,
    @TestOutput     VARCHAR(MAX) = NULL OUTPUT,
    @TestTimestamp  DATETIME2(7) = NULL OUTPUT
AS
BEGIN
    DECLARE @SatObjectId INT = OBJECT_ID(@SatTable,'U');
    DECLARE @HubObjectId INT = OBJECT_ID(@HubTable,'U');
    SET @TestTimestamp = SYSDATETIME();

    IF @SatObjectId IS NULL OR @HubObjectId IS NULL OR @TestObject IS NULL
    BEGIN
        SET @TestResult = 'Error';
        SET @TestOutput = 'Function: <AssertReferentialIntegrity>. ' +
                          'Satellite: <'+ISNULL(@SatTable,'NULL')+'>. ' +
                          'Hub: <'+ISNULL(@HubTable,'NULL')+'>. ' +
                          'TestObject: <'+ISNULL(@TestObject,'NULL')+'>. ' +
                          'Error: Table(s) was not found, or NULL value(s) provided.';
    END

    ELSE
    BEGIN
        DECLARE @SatQuotedName VARCHAR(255) = QUOTENAME(OBJECT_SCHEMA_NAME(@SatObjectId))+'.'+QUOTENAME(OBJECT_NAME(@SatObjectId));
        DECLARE @HubQuotedName VARCHAR(255) = QUOTENAME(OBJECT_SCHEMA_NAME(@HubObjectId))+'.'+QUOTENAME(OBJECT_NAME(@HubObjectId));
        DECLARE @Issues INT;
        DECLARE @Query NVARCHAR(MAX) = 'SELECT @Issues = COUNT(*) FROM '+@SatQuotedName+' sat ' +
                                       'WHERE NOT EXISTS (SELECT NULL FROM '+@HubQuotedName+' hub WHERE sat.'+@TestObject+' = hub.'+@TestObject+')';

        EXEC sp_executesql @Query, N'@Issues INT OUT', @Issues OUT;

        IF @Issues = 0
        BEGIN
            SET @TestResult = 'Pass';
            SET @TestOutput = 'Function: <AssertReferentialIntegrity>. ' +
                              'Satellite: <'+@SatTable+'>. ' +
                              'Hub: <'+@HubTable+'>. ' +
                              'TestObject: <'+@TestObject+'>. ' +
                              'Pass: No issues found.';
        END

        ELSE
        BEGIN
            SET @TestResult = 'Fail';
            SET @TestOutput = 'Function: <AssertReferentialIntegrity>. ' +
                              'Satellite: <'+@SatTable+'>. ' +
                              'Hub: <'+@HubTable+'>. ' +
                              'TestObject: <'+@TestObject+'>. ' +
                              'Fail. Issues found: <'+ISNULL(STR(@Issues),'NULL')+'>.';
        END
    END
END;
