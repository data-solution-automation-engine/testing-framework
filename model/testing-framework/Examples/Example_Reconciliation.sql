/*

Examples on how to use the testing framework, usig a reconciliation example.

*/

-- Step 1: register a new test template.

DECLARE @TemplateId INT;
EXEC [ut].[RegisterTestTemplate]
    @TemplateName = 'Generic-Reconciliation',
    @TemplateNotes = 'https://github.com/data-solution-automation-engine/testing-framework/blob/main/test-library/Test%20-%20Generic%20-%20Reconciliation.md',
    @Debug = 'Y',
    @TemplateId = @TemplateId OUTPUT;
PRINT concat('The Test Template Id is: ', @TemplateId, '.');

-- Step 2: register a new test for this template.
-- The test (code) must report back if the test has passed or failed.
-- This is the code that can be generated using VDW.

DECLARE @TestId INT;
EXEC [ut].[RegisterTest]
    -- Mandatory
    @TemplateId = '1',
    @Name = 'RECON_STG_CUSTOMER_PERSONAL',
    -- sample with test procedure
  @Debug='Y',
    @TestCode = 'BEGIN
  -- Framework required.
  --DECLARE @TestResult VARCHAR(10) = ''Fail'';
  --DECLARE @TestOutput VARCHAR(MAX);
  -- Local
  DECLARE @Issues INT = 0;

  BEGIN TRY
    SELECT @Issues =
      COUNT(*)
    FROM [200_Integration_Layer].dbo.SAT_CUSTOMER sat
    WHERE NOT EXISTS
    (
      SELECT 1 FROM [200_Integration_Layer].dbo.HUB_CUSTOMER hub
      WHERE 1=1
       AND sat.CUSTOMER_SK = hub.CUSTOMER_SK
    )

    SET @TestOutput = CONVERT(VARCHAR(10),@Issues)+'' issues were found.''

    IF @Issues=0
    BEGIN
      SET @TestResult=''Pass''
    END
  END TRY
  BEGIN CATCH
    --THROW
    SET @TestOutput = ERROR_MESSAGE();
    SET @TestResult=''Fail''
  END CATCH


  SELECT @TestOutput AS [OUTPUT], @TestResult AS [RESULT]
END',
    @TestObject = 'dbo.STG_CUSTOMER_PERSONAL',
    -- Output
    @TestId = @TestId OUTPUT;
PRINT concat('The Test Id is: ', @TestId, '.');

--SELECT * FROM ut.TEST

-- Step 3: run the test

EXEC [ut].[RunTest]
    @TestName = 'RI_SAT_CUSTOMER',
    @PlanId = NULL,
    @Debug = 'Y';

SELECT * FROM ut.TEST_RESULTS
