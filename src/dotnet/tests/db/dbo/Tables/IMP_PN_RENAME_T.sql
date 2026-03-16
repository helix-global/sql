CREATE TABLE [dbo].[IMP_PN_RENAME_T] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [VNESHID]    INT              NOT NULL,
    [OLDPN]      NVARCHAR (20)    NOT NULL,
    [NEWPN]      NVARCHAR (20)    NOT NULL,
    [RESULT]     INT              NULL,
    [MODELID]    INT              NULL,
    [NAVCACHEID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IMP_PN_RENAME_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[IMP_PN_RENAME] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_IMP_PN_RENAME_T]
    ON [dbo].[IMP_PN_RENAME_T]([VNESHID] ASC);

