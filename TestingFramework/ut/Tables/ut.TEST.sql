CREATE TABLE [ut].[TEST] (
    [ID]                  INT IDENTITY (1,1) NOT NULL,
    [TEMPLATE_ID]         INT                NOT NULL,
    [NAME]                NVARCHAR (255)     NOT NULL,
    [TEST_CODE]           NVARCHAR (MAX)     NOT NULL,
    [AREA]                NVARCHAR (100)     NULL,
    [TEST_OBJECT]         NVARCHAR (255)     NOT NULL,
    [TEST_OBJECT_TYPE]    NVARCHAR (100)     NULL,
    [NOTES]               NVARCHAR (MAX)     NULL,
    [CHECKSUM]            BINARY(20)         NOT NULL,
    [ACTIVE_INDICATOR]    CHAR (1)
     CONSTRAINT [DF_UT_TEST_ACTIVE_INDICATOR]
      DEFAULT ('Y')                          NOT NULL,
    CONSTRAINT [PK_TEST] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [IX_TEST_NAME] UNIQUE ([NAME]),
    CONSTRAINT [FK_TEST_TEMPLATE_ID] FOREIGN KEY ([TEMPLATE_ID]) REFERENCES [ut].[TEST_TEMPLATE] ([ID])
);

GO
CREATE NONCLUSTERED INDEX [FK_TEST_TEST_TEMPLATE] ON [ut].[TEST]([TEMPLATE_ID] ASC);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Applies to an area of the data solution, e.g. PSA, INT, DIM.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'AREA';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Whatever you want to report against.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'TEST_OBJECT';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Any descriptions or comments that can be meaningfully added to the test.', @level0type = N'SCHEMA', @level0name = N'ut', @level1type = N'TABLE', @level1name = N'TEST', @level2type = N'COLUMN', @level2name = N'NOTES';
