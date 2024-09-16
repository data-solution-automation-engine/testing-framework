/*
Process: Reset Framework
Purpose: Returns the frameweork to its freshly installed condition - removing all user content. Requires enabled override to work for protection.
Input (Mandatory):
  - Template Id
  - Test Name
  - Test code (executable)
  - Test object (table name)
Returns:
  - Test Id (if new Id created)
  - NULL (if test name (Name) already exists)
*/

CREATE PROCEDURE [ut].[ResetFramework]
    @Enabled        CHAR(1) = 'N',
    @Debug          CHAR(1) = 'N'
AS
BEGIN
    IF @Debug = 'Y'
      PRINT 'Starting to clear out framework.';

    IF @Debug = 'Y'
      PRINT '@Enabled is :'+@Enabled;

    IF @Enabled = 'Y'
      GOTO EndOfProcedure;

  -- Start of main process

  DELETE FROM ut.TEST_RESULTS;
  DELETE FROM ut.TEST;
  DELETE FROM ut.TEST_TEMPLATE;


  -- End of procedure label
  EndOfProcedure:

    IF @Debug = 'Y'
      PRINT 'Process completed'

END;
