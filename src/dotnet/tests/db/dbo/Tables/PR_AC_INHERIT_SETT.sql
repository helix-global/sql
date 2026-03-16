CREATE TABLE [dbo].[PR_AC_INHERIT_SETT] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [DEPID]   INT              NOT NULL,
    [MTID]    INT              NOT NULL,
    [REMARK]  NTEXT            NULL,
    [DEF4MT]  INT              NULL,
    [NAME]    NVARCHAR (200)   NOT NULL,
    [TEMPINT] INT              NULL,
    [NEWPMAP] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_AC_INHERIT_SETT_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_AC_INHERIT_SETT_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID]),
    CONSTRAINT [FK_PR_AC_INHERIT_SETT_NEWPMAP] FOREIGN KEY ([NEWPMAP]) REFERENCES [dbo].[PR_MAP] ([ID])
);

