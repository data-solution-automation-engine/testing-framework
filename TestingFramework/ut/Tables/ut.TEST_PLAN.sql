--if OBJECT_ID('[ut].[TEST_PLAN]','U') IS NOT NULL
--    drop table [ut].[TEST_PLAN]
--GO

CREATE TABLE [ut].[TEST_PLAN] (
    [ID]      INT IDENTITY(1,1) NOT NULL,
    [NAME]    NVARCHAR(100)     NOT NULL,
    [ACTIVE_INDICATOR]    CHAR (1)
      CONSTRAINT [DF_UT_TEST_PLAN_ACTIVE_INDICATOR]
      DEFAULT ('Y')             NOT NULL,
    [NOTES]   NVARCHAR(MAX)      NULL,
    CONSTRAINT [PK_TEST_PLAN] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [IX_TEST_PLAN_NAME] UNIQUE ([NAME])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Any descriptions or comments that can be meaningfully added to the test plan.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST_PLAN', @level2type = N'COLUMN', @level2name = N'NOTES';
