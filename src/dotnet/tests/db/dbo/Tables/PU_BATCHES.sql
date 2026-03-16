CREATE TABLE [dbo].[PU_BATCHES] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [NN]      NVARCHAR (100)   NOT NULL,
    [DD]      DATETIME         NOT NULL,
    [VNESHNN] NVARCHAR (100)   NULL,
    [QTY]     DECIMAL (16, 3)  NULL,
    [REMARK]  NTEXT            NULL,
    [MODELID] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PU_BATCHES_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PU_BATCHES]
    ON [dbo].[PU_BATCHES]([MODELID] ASC, [NN] ASC);

