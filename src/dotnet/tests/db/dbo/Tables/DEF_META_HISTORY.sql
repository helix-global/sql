CREATE TABLE [dbo].[DEF_META_HISTORY] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [DD]       DATETIME         NOT NULL,
    [METAOID]  INT              NOT NULL,
    [MTYPE]    INT              NOT NULL,
    [SQLTEXT]  NTEXT            NULL,
    [DISABLED] INT              NULL,
    [REMARK]   NTEXT            NULL,
    [NN]       INT              NOT NULL,
    [OBJTYPE]  INT              NULL,
    [OBJINFO]  XML              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_META_HISTORY_METAOID] FOREIGN KEY ([METAOID]) REFERENCES [dbo].[DEF_META] ([OID]) ON DELETE CASCADE
);

