-- One more example on how to use the testing framework


-- Step 1: register a new test template.

DECLARE @TemplateId INT;
EXEC [ut].[RegisterTestTemplate]
     @TemplateName = 'Generic-Referential-Integrity',
     @TemplateNotes = 'https://github.com/data-solution-automation-engine/testing-framework/blob/main/test-library/Test%20-%20Generic%20-%20Referential%20Integrity.md',
     @Debug = 'Y',
     @TemplateId = @TemplateId OUTPUT;
PRINT concat('The Test Template Id is: ', @TemplateId, '.');


-- Step 2: register a new test for this template.
-- This is the code that can be generated using VDW.

DECLARE @TestID INT;
EXEC [ut].[RegisterTest]
     @TemplateId = '1',  -- << insert the new Template Id here
     @Name = 'RI_SAT_CUSTOMER',
     @TestCode = 'EXEC [ut].[test_AssertReferentialIntegrity] ''[dbo].[SAT_CUSTOMER]'', ''[dbo].[HUB_CUSTOMER]'', @TestObject, @TestResult OUT, @TestOutput OUT, @TestTimestamp OUT',
     @TestObject = 'CUSTOMER_SK',
    -- Non mandatory
  -- @Area = 'AREA',
  -- @TestObjectType = 'TABLE',
  -- @Notes = 'meaningful note to the new test',
  -- @Enabled = 'Y',
     @Debug = 'Y',
    -- Output
     @TestId = @TestId OUTPUT;
PRINT concat('The Test Id is: ', @TestId, '.');


-- Step 3: run the test.

EXEC [ut].[RunTest]
     @TestName = 'RI_SAT_CUSTOMER',
     @PlanId = NULL,
     @Debug = 'Y';

SELECT * FROM ut.TEST_RESULTS
