CREATE TABLE [dbo].[SYNC_RESTRICTIONS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [RLOCATIONID]    INT              NOT NULL,
    [NO_PREPARATORY] INT              NULL,
    [NO_REPORTS]     INT              NULL,
    [REMARK]         NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SYNC_RESTRICTIONS_RLOCATIONID] FOREIGN KEY ([RLOCATIONID]) REFERENCES [dbo].[COM_REMOTE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SYNC_RESTRICTIONS_RLOCATIONID]
    ON [dbo].[SYNC_RESTRICTIONS]([RLOCATIONID] ASC);

