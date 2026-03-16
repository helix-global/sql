CREATE TABLE [dbo].[PR_AC_BACKUP_STORAGE] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [DEPID]       INT              NOT NULL,
    [DEPMODE]     INT              NOT NULL,
    [DEPPATH]     NVARCHAR (250)   NOT NULL,
    [BACKUP_LANG] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_AC_BACKUP_STORAGE_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

