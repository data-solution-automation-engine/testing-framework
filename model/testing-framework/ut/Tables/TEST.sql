CREATE TABLE [ut].[TEST] (
    [ID]               INT            NOT NULL,
    [TEMPLATE_ID]      INT            NOT NULL,
    [NAME]             VARCHAR (100)  NULL,
    [TEST_CODE]        NVARCHAR (MAX) NOT NULL,
    [AREA]             VARCHAR (100)  NULL,
    [TEST_OBJECT]      VARCHAR (100)  NULL,
    [TEST_OBJECT_TYPE] VARCHAR (100)  NULL,
    [NOTES]            VARCHAR (MAX)  NULL,
    [ENABLED]          CHAR (1)       NOT NULL,
    [CHECKSUM]         CHAR (40)      NOT NULL,
    CONSTRAINT [PK_TEST] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_7_1] FOREIGN KEY ([TEMPLATE_ID]) REFERENCES [ut].[TEST_TEMPLATE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [FK_TEST_TEST_TEMPLATE]
    ON [ut].[TEST]([TEMPLATE_ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Applies to an area of the data solution, e.g. PSA, INT, DIM.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'AREA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Whatever you want to report against.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'TEST_OBJECT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Any descriptions or comments that can be meaningfully added to the test.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'NOTES';

