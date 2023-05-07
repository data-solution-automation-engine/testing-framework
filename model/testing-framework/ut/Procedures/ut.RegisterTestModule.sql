/*
Process: Register Test Module (DIRECT)
Purpose: Creates (registers) a new Module in DIRECT, if it doesn't yet exist by name (Module Code)
Input (Mandatory);
  - Test Name (Name)
Returns:
  - Test Module Id (if new Id created)
  - NULL (if test module (Module Code) already exists)
Usage:

DECLARE @ModuleId INT;
EXEC [ut].[RegisterTestModule]
    -- Mandatory
    @Name = 'MyNewTestName',
    -- Non mandatory
    @ModuleDescription = 'created with [ut].[RegisterTestModule]',
    @ModuleType = 'TEST',
    @ModuleSourceDataObject = 'NA',
    @ModuleTargetDataObject = 'NA',
    @ModuleAreaCode = 'Maintenance',
    @ModuleFrequency = 'Continuous',
    @ModuleInactiveIndicator = 'N',
    @Debug = 'Y',
    -- Output
    @ModuleId = @ModuleId OUTPUT;
PRINT concat('The Module Id is: ', @ModuleID, '.');

*/

--if OBJECT_ID('[ut].[RegisterTestModule]','P') IS NOT NULL
--    drop procedure [ut].[RegisterTestModule]
--GO

create procedure [ut].[RegisterTestModule]
    @Name                    VARCHAR(255),
    @ModuleDescription       VARCHAR(MAX) = 'created with [ut].[RegisterTestModule]',
	@ModuleType              VARCHAR(255) = 'TEST',
	@ModuleSourceDataObject  VARCHAR(255) = 'NA',
	@ModuleTargetDataObject  VARCHAR(255) = 'NA',
	@ModuleAreaCode          VARCHAR(255) = 'Maintenance',
	@ModuleFrequency         VARCHAR(255) = 'Continuous',
	@ModuleInactiveIndicator CHAR(1) = 'N',
	@Debug                   CHAR(1) = 'N',
	@ModuleId                INT = NULL OUTPUT
as
begin

    DECLARE @ModuleCode VARCHAR(255) = concat('utm_', @Name);
    DECLARE @Executable VARCHAR(MAX) = concat('EXEC [ut].RunTest @TestName=''', @Name, '''');


    if NOT EXISTS (select NULL from [omd].[MODULE] where [MODULE_CODE] = @ModuleCode)
        EXEC [omd].[RegisterModule]
             @ModuleCode = @ModuleCode,
             @ModuleDescription = @ModuleDescription,
             @ModuleType = @ModuleType,
             @ModuleSourceDataObject = @ModuleSourceDataObject,
             @ModuleTargetDataObject = @ModuleTargetDataObject,
             @ModuleAreaCode = @ModuleAreaCode,
             @ModuleFrequency = @ModuleFrequency,
             @ModuleInactiveIndicator = @ModuleInactiveIndicator,
             @Debug = @Debug,
             @Executable = @Executable,
             @ModuleId = @ModuleId OUTPUT;

    if @Debug = 'Y'
    begin
        if @ModuleId IS NOT NULL
            PRINT concat('A new Test Module Id ''', @ModuleId, ''' has been registered for Test Module Code: ''', @ModuleCode, '''.');
        else begin
            DECLARE @ExistingID INT;
            SELECT @ExistingId = MODULE_ID FROM [omd].[MODULE] WHERE MODULE_CODE = @ModuleCode;
            PRINT concat('The Module Code ''', @ModuleCode, ''' already exists in [omd].[MODULE] with Module Id ''', @ExistingId, '''.');
            PRINT concat('SELECT * FROM [omd].[MODULE] WHERE [MODULE_CODE] = ''', @ModuleCode, '''.');
        end
    end
end;
