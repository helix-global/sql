CREATE TABLE [dbo].[DEF_FORM] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [OID]            INT              NOT NULL,
    [NAME]           NVARCHAR (100)   NOT NULL,
    [MODULEOID]      INT              NOT NULL,
    [LABEL]          NVARCHAR (40)    NOT NULL,
    [TEXT]           NTEXT            NULL,
    [FORMTEXT]       NTEXT            NULL,
    [FORMCODE]       NTEXT            NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NULL,
    [S_MR]           INT              NULL,
    [S_CDT]          DATETIME         NULL,
    [S_MDT]          DATETIME         NULL,
    [NATIVECLASS]    NVARCHAR (100)   NULL,
    [PLUGINASSEMBLY] NVARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_FORM_MODULEOID] FOREIGN KEY ([MODULEOID]) REFERENCES [dbo].[DEF_MODULES] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_FORM_1]
    ON [dbo].[DEF_FORM]([LABEL] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_FORM]
    ON [dbo].[DEF_FORM]([OID] ASC);

