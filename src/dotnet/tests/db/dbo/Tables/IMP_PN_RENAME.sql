CREATE TABLE [dbo].[IMP_PN_RENAME] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NULL,
    [S_S]    INT              NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [DD]     DATETIME         NOT NULL,
    [DEPID]  INT              NOT NULL,
    [REMARK] NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IMP_PN_RENAME_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

