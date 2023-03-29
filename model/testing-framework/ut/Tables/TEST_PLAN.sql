CREATE TABLE [ut].[TEST_PLAN] (
    [ID]      INT           NOT NULL,
    [NAME]    VARCHAR (100) NULL,
    [ENABLED] CHAR (1)      NOT NULL,
    [NOTES]   VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_TEST_PLAN] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Any descriptions or comments that can be meaningfully added to the test plan.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST_PLAN', @level2type = N'COLUMN', @level2name = N'NOTES';

