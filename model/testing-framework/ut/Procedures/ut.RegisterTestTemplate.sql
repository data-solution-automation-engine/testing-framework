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
PRINT concat('The New Test Template Id is: ', @TemplateId, '.');

*/

if OBJECT_ID('[ut].[RegisterTestTemplate]','P') IS NOT NULL
    drop procedure [ut].[RegisterTestTemplate]
GO

create procedure [ut].[RegisterTestTemplate]
    @TemplateName  VARCHAR(255),
    @TemplateNotes VARCHAR(MAX) = NULL,
    @Debug         CHAR(1) = 'N',
    @TemplateId    INT = NULL OUTPUT
as
begin

    begin try
        insert into [ut].[TEST_TEMPLATE] (NAME, NOTES)
        select * from (values (@TemplateName, @TemplateNotes)) AS refData(NAME, NOTES)
        where NOT EXISTS (select NULL from [ut].[TEST_TEMPLATE] t where t.NAME = refData.NAME);
        set @TemplateId = SCOPE_IDENTITY();
    end try
    begin catch
        throw
    end catch

    if @Debug = 'Y' begin
        if @TemplateId IS NOT NULL
            PRINT concat('A new Test Template ID ''', @TemplateId, ''' has been created for Template Name: ''', @TemplateName, '''.');
        else begin
            DECLARE @ExistingID INT;
            SELECT @ExistingId = ID FROM [ut].[TEST_TEMPLATE] WHERE NAME = @TemplateName;
            PRINT concat('The Test Template ''', @TemplateName, ''' already exists in [omd].[TEST_TEMPLATE] with ID ', @ExistingId, '.');
            PRINT concat('SELECT * FROM [omd].[TEST_TEMPLATE] where [NAME] = ''', @TemplateName, '''');
        end
    end
end;
