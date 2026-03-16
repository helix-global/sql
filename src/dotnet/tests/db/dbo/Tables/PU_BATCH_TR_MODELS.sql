CREATE TABLE [dbo].[PU_BATCH_TR_MODELS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [MODELID]    INT              NOT NULL,
    [BATCH_MODE] INT              NOT NULL,
    [REMARK]     NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PU_BATCH_TR_MODELS_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PU_BATCH_TR_MODELS]
    ON [dbo].[PU_BATCH_TR_MODELS]([MODELID] ASC)
    INCLUDE([BATCH_MODE]);

