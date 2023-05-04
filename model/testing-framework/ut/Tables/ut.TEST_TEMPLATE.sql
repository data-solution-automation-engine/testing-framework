if OBJECT_ID('[ut].[TEST_TEMPLATE]','U') IS NOT NULL
    drop table [ut].[TEST_TEMPLATE]
GO

CREATE TABLE [ut].[TEST_TEMPLATE] (
    [ID]    INT IDENTITY (1,1) NOT NULL,
    [NAME]  VARCHAR (255)      NOT NULL,
    [NOTES] VARCHAR (MAX)      NULL,
    CONSTRAINT [PK_TEST_TEMPLATE] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [IX_TEMPLATE_NAME] UNIQUE ([NAME])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Any descriptions or comments that can be meaningfully added to the test group.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST_TEMPLATE', @level2type = N'COLUMN', @level2name = N'NOTES';
