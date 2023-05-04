/*
Process: Add Test to Plan
Purpose: Creates (registers) a new Test allocation for a Test Plan, if it doesn't yet exist by name (Name)
Input:
  - Test Name
  - Test Plan Name
Returns:
  - 1 (if test added to plan)
  - 0 (if test (Name) already exists in plan)
  - NULL (if test or plan is incorrect)
Usage:

DECLARE @AddedToPlan INT;
EXEC [ut].[AddTestToPlan]
    @TestName = 'MyNewTest',
    @PlanName = 'MyNewTestPlan',
    @Debug = 'Y',
    @AddedToPlan = @AddedToPlan OUTPUT;
PRINT concat('The AddedToPlan flag is: ', @AddedToPlan, '.');

*/

if OBJECT_ID('[ut].[AddTestToPlan]','P') IS NOT NULL
    drop procedure [ut].[AddTestToPlan]
GO

create procedure [ut].[AddTestToPlan]
    @TestName    VARCHAR(255),
    @PlanName    VARCHAR(255),
    @Debug       CHAR(1) = 'N',
    @AddedToPlan INT = NULL OUTPUT
as
begin

    DECLARE @TestId INT;
    DECLARE @PlanId INT;


    -- Find Test Id by Name
	begin try
		select @TestId = ID from [ut].[TEST] where NAME = @TestName;
    end try
    begin catch
        throw
    end catch

    if @Debug = 'Y' begin
        if @TestId IS NOT NULL
            PRINT 'Test Id <'+CONVERT(VARCHAR(10),@TestId)+'> has been retrieved for Test Name <'+@TestName+'>.';
        else
            PRINT 'No Test Id has been found for Test Name <'+@TestName+'>.';
    end


    -- Find Plan Id by Name
	begin try
		select @PlanId = ID from [ut].[TEST_PLAN] where NAME = @PlanName;
    end try
    begin catch
        throw
    end catch

    if @Debug = 'Y' begin
        if @PlanId IS NOT NULL
            PRINT 'Plan Id <'+CONVERT(VARCHAR(10),@PlanId)+'> has been retrieved for Plan Name <'+@PlanName+'>.';
        else
            PRINT 'No Plan Id has been found for Plan Name <'+@PlanName+'>.';
    end


	-- Register Test to Plan
    if @TestId IS NOT NULL AND @PlanId IS NOT NULL begin
        begin try
            insert into [ut].[TEST_PLAN_ALLOCATION] (TEST_ID, TEST_PLAN_ID)
            select * from (values (@TestId, @PlanId)) AS refData (TEST_ID, TEST_PLAN_ID)
            where NOT EXISTS (select NULL from [ut].[TEST_PLAN_ALLOCATION] t where t.TEST_ID = refData.TEST_ID AND t.TEST_PLAN_ID = refData.TEST_PLAN_ID);
            set @AddedToPlan = @@ROWCOUNT;
        end try
        begin catch
            throw
        end catch


        if @Debug = 'Y' begin
            if @AddedToPlan = 1
                PRINT concat('Test Name ''', @TestName, ''' has been registered to Test Plan ''', @PlanName, '''.');
            else begin
                PRINT concat('Test Name ''', @TestName, ''' already exists in Test Plan ''', @PlanName, '''.');
                PRINT concat('SELECT * FROM [ut].[TEST_PLAN_ALLOCATION] WHERE [TEST_ID] = ', @TestId, ' AND [TEST_PLAN_ID] = ', @PlanId);
            end
        end
    end
    else begin
        if @Debug = 'Y'
            PRINT 'Test Plan addition process encountered errors. Incorrect Test Name or/and Plan Name.';
    end
end;
