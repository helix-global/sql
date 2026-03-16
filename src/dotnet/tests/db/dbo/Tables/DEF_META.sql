CREATE TABLE [dbo].[DEF_META] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [OID]             INT              NOT NULL,
    [MODULEOID]       INT              NOT NULL,
    [NAME]            NVARCHAR (150)   NOT NULL,
    [MTYPE]           INT              NOT NULL,
    [SQLTEXT]         NTEXT            NULL,
    [DISABLED]        INT              NULL,
    [REMARK]          NTEXT            NULL,
    [S_S]             INT              NOT NULL,
    [TABLENAME]       NVARCHAR (150)   NULL,
    [SCRIPTCONDITION] NTEXT            NULL,
    [OBJTYPE]         INT              NULL,
    [OBJINFO]         XML              NULL,
    [SCHEMA]          NVARCHAR (32)    NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_META_MODULEOID] FOREIGN KEY ([MODULEOID]) REFERENCES [dbo].[DEF_MODULES] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_META_OID]
    ON [dbo].[DEF_META]([OID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_META_NAME]
    ON [dbo].[DEF_META]([NAME] ASC, [TABLENAME] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_META_2]
    ON [dbo].[DEF_META]([MTYPE] ASC, [NAME] ASC, [TABLENAME] ASC, [SCHEMA] ASC);

