CREATE TABLE [dbo].[EQ_CHANGEDEP] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_S]     INT              NOT NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [DD]      DATETIME         NOT NULL,
    [DEPID]   INT              NOT NULL,
    [TODEPID] INT              NOT NULL,
    [REMARK]  NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_EQ_CHANGEDEP_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_EQ_CHANGEDEP_TODEPID] FOREIGN KEY ([TODEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

