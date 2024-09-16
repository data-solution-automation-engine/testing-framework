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

--CREATE OR ALTER PROCEDURE [ut].[RegisterTest]
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
    IF @Debug = 'Y'
    PRINT 'Registering test for '+@Name+'.';

    DECLARE @NewChecksum BINARY(20) = HASHBYTES('SHA1', @TestCode);

    BEGIN TRY
    -- Insert the test, if it does not exist yet.
        INSERT INTO [ut].[TEST] (TEMPLATE_ID, NAME, TEST_CODE, AREA, TEST_OBJECT, TEST_OBJECT_TYPE, NOTES, [ACTIVE_INDICATOR], [CHECKSUM])
        SELECT * FROM (
            VALUES (@TemplateId, @Name, @TestCode, @Area, @TestObject, @TestObjectType, @Notes, @Enabled, @NewChecksum)
            ) AS refData(TEMPLATE_ID, NAME, TEST_CODE, AREA, TEST_OBJECT, TEST_OBJECT_TYPE, NOTES, [ENABLED], [CHECKSUM])
        WHERE NOT EXISTS (SELECT NULL FROM [ut].[TEST] t WHERE t.NAME = refData.NAME);
        SET @TestId = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        IF @Debug = 'Y'
      PRINT 'Test registration failed.';
    THROW
    END CATCH

  IF @Debug = 'Y'
    PRINT 'Starting test id evaluation.';

  -- If a new test is created...
    IF @TestId IS NOT NULL
    BEGIN
      IF @Debug = 'Y'
        PRINT concat('A new Test ID ''', @TestId, ''' has been created for Test Name: ''', @Name, '''.');
    END
    ELSE
    BEGIN
      -- Compare the checksums, and update the code if different.
      DECLARE @ExistingID INT;
      DECLARE @ExistingChecksum BINARY(20);

      SELECT @ExistingID = ID FROM [ut].[TEST] WHERE NAME = @Name;

      SELECT @ExistingChecksum = [CHECKSUM] FROM ut.TEST WHERE [ID] = @ExistingID

      IF @Debug = 'Y'
        PRINT concat('The Test ''', @Name, ''' already exists in [omd].[TEST] with ID ', @ExistingID, '.');

      IF @NewChecksum != @ExistingChecksum
        BEGIN TRY
          UPDATE [ut].[TEST] SET
            [TEST_CODE] = @TestCode,
            [TEMPLATE_ID] = @TemplateId,
            [TEST_OBJECT] = @TestObject,
            [AREA] = @Area,
            [TEST_OBJECT_TYPE] = @TestObjectType,
            [NOTES] = @Notes,
            [ACTIVE_INDICATOR] = @Enabled,
            [CHECKSUM] = @NewChecksum
          WHERE [ID] = @ExistingID;
          IF @Debug = 'Y'
            PRINT concat('The Test ''', @Name, ''' has been updated with new test code.');
        END TRY
        BEGIN CATCH
          IF @Debug = 'Y'
            PRINT concat('Error. The Test ''', @Name, ''' update with new test code failed.');
          THROW
        END CATCH

      -- Return the already existing id, in case it is used for downstream processes.
      SET @TestId = @ExistingID;
    END

END;
