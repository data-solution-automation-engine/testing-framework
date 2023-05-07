/*

Examples on how to use the testing framework.

*/

-- Step 1: register a new test template.

DECLARE @TemplateId INT;
EXEC [ut].[RegisterTestTemplate]
    @TemplateName = 'Generic-Referential-Integrity',
    @TemplateNotes = 'https://github.com/data-solution-automation-engine/testing-framework/blob/main/test-library/Test%20-%20Generic%20-%20Referential%20Integrity.md',
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
    @Name = 'RI_SAT_CUSTOMER',
    -- sample with test procedure
    @TestCode = '-- Framework required.
DECLARE @TestResult VARCHAR(10) = ''Fail'';
-- Local
DECLARE @Issues INT = 0;

SELECT @Issues =
    COUNT(*)
FROM [200_Integration_Layer].dbo.SAT_CUSTOMER sat
WHERE NOT EXISTS
(
  SELECT 1 FROM [200_Integration_Layer].dbo.HUB_CUSTOMER hub
  WHERE 1=1
     AND sat.CUSTOMER_SK = hub.CUSTOMER_SK
)

--PRINT CONVERT(CHAR(1), @Issues)

IF @Issues=0
	BEGIN
		SET @TestResult=''Pass''
	END

SELECT @TestResult AS [OUTPUT]
-- Needs something to grab the results and insert into the Tests Results table.',
    @TestObject = '[200_Integration_Layer].dbo.SAT_CUSTOMER',
    -- Output
    @TestId = @TestId OUTPUT;
PRINT concat('The Test Id is: ', @TestId, '.');

-- Step 3: run the test

EXEC [ut].[RunTest]
    @TestName = 'RI_SAT_CUSTOMER',
    @PlanId = NULL,
    @Debug = 'Y';

SELECT * FROM ut.TEST_RESULTS