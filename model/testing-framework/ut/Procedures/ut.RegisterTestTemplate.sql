/*
Process: Register Test Template
Purpose: Creates (registers) a new Test Template, if it doesn't exist by name (Name)
Input:
  - Template Name
  - Template Notes (Optional)
  - Debug flag (Y/N, default N)
Returns:
  - Template Id (if new Id created)
  - NULL (if template name (Name) already exists)
Usage:

DECLARE @TemplateId INT;
EXEC [ut].[RegisterTestTemplate]
    -- Mandatory
    @TemplateName = 'MyNewTestTemplate',
    -- Optional
    @TemplateNotes = 'meaningful comment to the new test template',
    @Debug = 'Y',
    -- Output
    @TemplateId = @TemplateId OUTPUT;
PRINT concat('The new Test Template Id is: ', @TemplateId, '.');

*/

--if OBJECT_ID('[ut].[RegisterTestTemplate]','P') IS NOT NULL
--    drop procedure [ut].[RegisterTestTemplate]
--GO

--CREATE OR ALTER PROCEDURE [ut].[RegisterTestTemplate]
CREATE PROCEDURE [ut].[RegisterTestTemplate]
    @TemplateName  VARCHAR(255),
    @TemplateNotes VARCHAR(MAX) = NULL,
    @Debug         CHAR(1) = 'N',
    @TemplateId    INT = NULL OUTPUT
AS
BEGIN

    BEGIN TRY
        INSERT INTO [ut].[TEST_TEMPLATE] (NAME, NOTES)
        SELECT * FROM (VALUES (@TemplateName, @TemplateNotes)) AS refData(NAME, NOTES)
        WHERE NOT EXISTS (select NULL from [ut].[TEST_TEMPLATE] t WHERE t.NAME = refData.NAME);
        SET @TemplateId = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        IF @Debug = 'Y' PRINT 'Template registration failed.';
			THROW
    END CATCH

    IF @Debug = 'Y' 
	BEGIN
        IF @TemplateId IS NOT NULL
            PRINT concat('A new Test Template ID ''', @TemplateId, ''' has been created for Template Name: ''', @TemplateName, '''.');
        ELSE 
			BEGIN
				DECLARE @ExistingID INT;
				SELECT @ExistingId = ID FROM [ut].[TEST_TEMPLATE] WHERE NAME = @TemplateName;
				PRINT concat('The Test Template ''', @TemplateName, ''' already exists in [omd].[TEST_TEMPLATE] with ID ', @ExistingId, '.');
				PRINT concat('SELECT * FROM [omd].[TEST_TEMPLATE] where [NAME] = ''', @TemplateName, '''');

				-- Return the already existing id.
				SET @TemplateId = @ExistingID;
			END
    END
END;
