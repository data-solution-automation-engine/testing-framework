/*
Process: Register Test
Purpose: Creates (registers) a new Test, if it doesn't yet exist by name (Name)
Input (Mandatory):
  - Template Id
  - Test Name
  - Test code (executable)
  - Test object (table name)
Returns:
  - Test Id (if new Id created)
  - NULL (if test name (Name) already exists)
Usage:

DECLARE @TestId INT;
EXEC [ut].[RegisterTest]
    -- Mandatory
    @TemplateId = '1',
    @Name = 'MyNewTest',
    -- sample with test procedure
    @TestCode = 'EXEC [ut].[test_AssertEmptyTable] @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT',
    @TestObject = '[ut].[TEST_RESULTS]',
    -- sample with test function
    -- @TestCode = 'select @TestResult = TestResult, @TestOutput = TestOutput, @TestTimestamp = TestTimestamp from [ut].[test_AssertEquals] (@TestObject, 0, (select count(*) from [omd].[MODULE_PARAMETER]))';
    -- @TestObject = 'empty table [omd].[MODULE_PARAMETER]',
    -- Non mandatory
    @Area = 'AREA',
    @TestObjectType = 'TABLE',
    @Notes = 'meaningful note to the new test',
    @Enabled = 'Y',
    @Debug = 'Y',
    -- Output
    @TestId = @TestId OUTPUT;
PRINT concat('The Test Id is: ', @TestId, '.');

*/

--if OBJECT_ID('[ut].[RegisterTest]','P') IS NOT NULL
--    drop procedure [ut].[RegisterTest]
--GO

CREATE PROCEDURE [ut].[RegisterTest]
    @TemplateId     INT,
    @Name           VARCHAR(255),
    @TestCode       VARCHAR(MAX),
    @TestObject     VARCHAR(255),
    @Area           VARCHAR(100) = NULL,
    @TestObjectType VARCHAR(100) = NULL,
    @Notes          VARCHAR(MAX) = NULL,
    @Enabled        CHAR(1) = 'Y',
    @Debug          CHAR(1) = 'N',
    @TestId         INT = NULL OUTPUT
AS
BEGIN

    DECLARE @Checksum BINARY(20) = HASHBYTES('SHA1', @TestCode);

    BEGIN TRY
        INSERT INTO [ut].[TEST] (TEMPLATE_ID, NAME, TEST_CODE, AREA, TEST_OBJECT, TEST_OBJECT_TYPE, NOTES, ENABLED, CHECKSUM)
        select * from (
            values (@TemplateId, @Name, @TestCode, @Area, @TestObject, @TestObjectType, @Notes, @Enabled, @Checksum)
            ) AS refData(TEMPLATE_ID, NAME, TEST_CODE, AREA, TEST_OBJECT, TEST_OBJECT_TYPE, NOTES, ENABLED, CHECKSUM)
        where NOT EXISTS (select NULL from [ut].[TEST] t where t.NAME = refData.NAME);
        set @TestId = SCOPE_IDENTITY();
    end try
    begin catch
        if @Debug = 'Y' PRINT 'Test registration failed.';
        throw
    end catch

    if @Debug = 'Y' begin
        if @TestId IS NOT NULL
            PRINT concat('A new Test ID ''', @TestId, ''' has been created for Test Name: ''', @Name, '''.');
        else begin
            DECLARE @ExistingID INT;
            SELECT @ExistingID = ID FROM [ut].[TEST] WHERE NAME = @Name;
            PRINT concat('The Test ''', @Name, ''' already exists in [omd].[TEST] with ID ', @ExistingID, '.');
            PRINT concat('SELECT * FROM [omd].[TEST] where [NAME] = ''', @Name, '''');
        END
    END
END;
