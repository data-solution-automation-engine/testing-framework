CREATE TABLE [ut].[TEST_TEMPLATE] (
    [ID]    INT           NOT NULL,
    [NAME]  VARCHAR (100) NULL,
    [NOTES] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_TEST_TEMPLATE] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Any descriptions or comments that can be meaningfully added to the test group.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST_TEMPLATE', @level2type = N'COLUMN', @level2name = N'NOTES';

