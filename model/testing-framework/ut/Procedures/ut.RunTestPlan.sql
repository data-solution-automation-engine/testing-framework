/*
Process: Run Test Plan
Purpose: Executes Tests allocated to a Plan by respective Plan NAME
Input:
  - Test Plan Name
  - Debug flag (Y/N, default N)
Returns:
  - Plan Id retrieved by Plan Name
Usage:

EXEC [ut].[RunTestPlan]
    @PlanName = 'MyNewTestPlan',
    @Debug = 'Y';

*/

if OBJECT_ID('[ut].[RunTestPlan]','P') IS NOT NULL
    drop procedure [ut].[RunTestPlan]
GO

create procedure [ut].[RunTestPlan]
    @PlanName VARCHAR(255),
    @Debug    CHAR(1) = 'N',
    @PlanId   INT = NULL OUTPUT
as
begin

    DECLARE @Enabled CHAR(1);
    select
        @PlanId = [ID],
        @Enabled = [ENABLED]
    from [ut].[TEST_PLAN] where [NAME] = @PlanName;

    if @Debug = 'Y' begin
        PRINT concat('The Test Plan Id retrieved is: ''', @PlanId, '''.');
        PRINT concat('The Enabled flag retrieved is: ''', @Enabled, '''.');
    end

    if @Enabled = 'Y' begin
        begin try
            DECLARE @TestName VARCHAR(255);
            DECLARE TestPlan_Cursor CURSOR FOR
                select t.[NAME] from [ut].[TEST] t
                join [ut].[TEST_PLAN_ALLOCATION] tpa ON t.[ID] = tpa.[TEST_ID] AND tpa.[TEST_PLAN_ID] = @PlanId

            OPEN TestPlan_Cursor
                FETCH NEXT FROM TestPlan_Cursor INTO @TestName
                while @@FETCH_STATUS = 0 begin

                    if @Debug = 'Y' PRINT concat('Running test name: ''', @TestName);
                    EXEC [ut].[RunTest] @TestName,@PlanId,@Debug;
                    FETCH NEXT FROM TestPlan_Cursor INTO @TestName

                end
            CLOSE TestPlan_Cursor
            DEALLOCATE TestPlan_Cursor
        end try

        begin catch
            if @Debug = 'Y' PRINT 'Test Plan run failed.';
            throw
        end catch
    end

    else begin
        if @Debug = 'Y' PRINT concat('Test Plan skipped. ENABLED: ''', @Enabled, '''.');
    end
end;
