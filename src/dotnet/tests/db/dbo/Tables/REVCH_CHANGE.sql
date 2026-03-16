CREATE TABLE [dbo].[REVCH_CHANGE] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NULL,
    [S_S]    INT              NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [DEPID]  INT              NOT NULL,
    [MTID]   INT              NOT NULL,
    [DD]     DATETIME         NOT NULL,
    [REMARK] NTEXT            NULL,
    [MAPID]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_REVCH_CHANGE_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_REVCH_CHANGE_MAPID] FOREIGN KEY ([MAPID]) REFERENCES [dbo].[PR_MAP] ([ID]),
    CONSTRAINT [FK_REVCH_CHANGE_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);

