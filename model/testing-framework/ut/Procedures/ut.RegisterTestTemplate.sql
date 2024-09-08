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

CREATE PROCEDURE [ut].[RegisterTestTemplate]
    @TemplateName  VARCHAR(255),
    @TemplateNotes VARCHAR(MAX) = NULL,
    @Debug         CHAR(1) = 'N',
    @TemplateId    INT OUTPUT
AS
BEGIN

  BEGIN TRY
    INSERT INTO [ut].[TEST_TEMPLATE] (NAME, NOTES)
    SELECT *
    FROM (VALUES (@TemplateName, @TemplateNotes)) AS refData(NAME, NOTES)
    WHERE NOT EXISTS (select NULL from [ut].[TEST_TEMPLATE] t WHERE t.NAME = refData.NAME);

    SET @TemplateId = SCOPE_IDENTITY();
  END TRY
  BEGIN CATCH
    IF @Debug = 'Y'
      PRINT 'Template registration failed.';

      THROW
  END CATCH

  BEGIN
    IF @TemplateId IS NULL
    BEGIN
      DECLARE @ExistingID INT;

      SELECT @ExistingId = ID FROM [ut].[TEST_TEMPLATE] WHERE NAME = @TemplateName;

      IF @Debug = 'Y'
      BEGIN
          PRINT concat('The Test Template ''', @TemplateName, ''' already exists in [omd].[TEST_TEMPLATE] with ID ', CONVERT(VARCHAR(10),@ExistingID), '.');
          PRINT concat('SELECT * FROM [omd].[TEST_TEMPLATE] where [NAME] = ''', @TemplateName, '''');
      END

      -- Return the already existing id.
      SET @TemplateId = @ExistingID;
    END
    ELSE
      BEGIN
        IF @Debug = 'Y'
          PRINT concat('A new Test Template ID ''', CONVERT(VARCHAR(10),@TemplateId), ''' has been created for Template Name: ''', @TemplateName, '''.');
      END
    END
END;
