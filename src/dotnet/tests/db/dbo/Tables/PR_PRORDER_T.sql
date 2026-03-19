CREATE TABLE [dbo].[PR_PRORDER_T] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NULL,
    [S_CDT]            DATETIME         NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [PRORDERID]        INT              NOT NULL,
    [MODELID]          INT              NOT NULL,
    [REVID]            INT              NULL,
    [QUANTITY]         INT              NOT NULL,
    [REMARK]           NTEXT            NULL,
    [PARENTORDERROWID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_PRORDER_T_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID]),
    CONSTRAINT [FK_PR_PRORDER_T_PRORDERID] FOREIGN KEY ([PRORDERID]) REFERENCES [dbo].[PR_PRORDER] ([ID]) ON DELETE CASCADE,
    CONSTRAINT [FK_PR_PRORDER_T_REVID] FOREIGN KEY ([REVID]) REFERENCES [dbo].[PR_REVISION] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_PRORDER_T]
    ON [dbo].[PR_PRORDER_T]([PRORDERID] ASC) WITH (FILLFACTOR = 90);

