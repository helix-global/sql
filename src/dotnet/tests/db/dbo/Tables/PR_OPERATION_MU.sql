CREATE TABLE [dbo].[PR_OPERATION_MU] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [OPERID]          INT              NOT NULL,
    [CODE]            NVARCHAR (100)   NOT NULL,
    [QUANTITY]        DECIMAL (18, 6)  NULL,
    [REFQUANTITY]     DECIMAL (18, 6)  NULL,
    [BATCHN]          NVARCHAR (100)   NULL,
    [CREATEFLAG]      INT              NULL,
    [REMARK]          NVARCHAR (200)   NULL,
    [QTYPEROPERATION] INT              NULL,
    [ASDEFECTIVE]     INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_OPERATION_MU_OPERID] FOREIGN KEY ([OPERID]) REFERENCES [dbo].[PR_OPERATION] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_MU]
    ON [dbo].[PR_OPERATION_MU]([OPERID] ASC);

