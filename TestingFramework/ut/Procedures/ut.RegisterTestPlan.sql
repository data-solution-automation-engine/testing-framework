/*
Process: Register Test Plan
Purpose: Creates (registers) a new Test Plan, if it doesn't exist by name (Name)
Input:
  - Plan Name
Returns:
  - Plan Id (if new Id created)
  - NULL (if plan name (Name) already exists)
Usage:

DECLARE @PlanId INT;
EXEC [ut].[RegisterTestPlan]
    -- Mandatory
    @PlanName = 'MyNewTestPlan',
    -- Optional
    @Enabled = 'Y',
    @Notes = 'meaningful note to the new test plan',
    @Debug = 'Y',
    -- Output
    @PlanId = @PlanId OUTPUT;
PRINT concat('The New Test Plan Id is: ', @PlanId, '.');

*/

--if OBJECT_ID('[ut].[RegisterTestPlan]','P') IS NOT NULL
--    drop procedure [ut].[RegisterTestPlan]
--GO

create procedure [ut].[RegisterTestPlan]
    @PlanName VARCHAR(255),
    @Enabled  CHAR(1) = 'Y',
    @Notes    VARCHAR(MAX) = NULL,
    @Debug    CHAR(1) = 'N',
    @PlanId   INT = NULL OUTPUT
as
begin

    begin try
        insert into [ut].[TEST_PLAN] (NAME, ACTIVE_INDICATOR, NOTES)
        select * from (values (@PlanName,@Enabled, @Notes)) AS refData(NAME, ENABLED, NOTES)
        where NOT EXISTS (select NULL from [ut].[TEST_PLAN] t where t.NAME = refData.NAME);
        set @PlanId = SCOPE_IDENTITY();
    end try
    begin catch
        if @Debug = 'Y' PRINT 'Test Plan registration failed.';
        throw
    end catch

    if @Debug = 'Y' begin
        if @PlanId IS NOT NULL
            PRINT concat('A new Test Plan ID ''', @PlanId, ''' has been created for Plan Name: ''', @PlanName, '''.');
        else begin
            DECLARE @ExistingID INT;
            SELECT @ExistingId = ID FROM [ut].[TEST_PLAN] WHERE NAME = @PlanName;
            PRINT concat('The Test Plan ''', @PlanName, ''' already exists in [omd].[TEST_PLAN] with ID ', @ExistingId, '.');
            PRINT concat('SELECT * FROM [omd].[TEST_TEMPLATE] where [NAME] = ''', @PlanName, '''');
        end
    end
end;
