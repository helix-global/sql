CREATE TABLE [dbo].[DEF_CLASSES] (
    [ID]                  INT              IDENTITY (1, 1) NOT NULL,
    [OID]                 INT              NOT NULL,
    [LABEL]               NVARCHAR (256)   NOT NULL,
    [MODULEOID]           INT              NOT NULL,
    [NAME]                NVARCHAR (2048)  NOT NULL,
    [ENTITYOID]           INT              NULL,
    [ARC]                 INT              NULL,
    [NAMEMASK]            NVARCHAR (200)   NULL,
    [NEWNAME]             NVARCHAR (200)   NULL,
    [NEWFORMOID]          INT              NULL,
    [SQLFILTER]           NVARCHAR (300)   NULL,
    [GID]                 UNIQUEIDENTIFIER NULL,
    [S_CR]                INT              NULL,
    [S_MR]                INT              NULL,
    [S_CDT]               DATETIME         NULL,
    [S_MDT]               DATETIME         NULL,
    [DEFAULTPERIOD]       INT              NULL,
    [INITFORMOID]         INT              NULL,
    [LIVEUNIT]            INT              NULL,
    [NOLISTADD]           INT              NULL,
    [NOLISTDEL]           INT              NULL,
    [NOEDITABLE]          INT              NULL,
    [ACCESSLEVEL]         NVARCHAR (200)   NULL,
    [NOCOPY]              INT              NULL,
    [DOPTION]             NVARCHAR (400)   NULL,
    [FAQUERY]             INT              NULL,
    [REMARK]              NTEXT            NULL,
    [FACCESS]             NVARCHAR (250)   NULL,
    [FACCESSNEW]          NVARCHAR (250)   NULL,
    [FOLDERSQOID]         INT              NULL,
    [OPENUNITOID]         INT              NULL,
    [SRVOID]              INT              NULL,
    [RENTITYSQLFILTER]    NVARCHAR (500)   NULL,
    [SPELLCHECKER]        INT              NULL,
    [FOLDERIMG]           NVARCHAR (120)   NULL,
    [DEFAULTPERIODCUSTOM] INT              NULL,
    [LISTUNIT]            INT              NULL,
    [SQLPROLOG]           NTEXT            NULL,
    [SQLCLAUSEOPTION]     NVARCHAR (512)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_CLASSES_ENTITYOID] FOREIGN KEY ([ENTITYOID]) REFERENCES [dbo].[DEF_ENTITY] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_FAQUERY] FOREIGN KEY ([FAQUERY]) REFERENCES [dbo].[DEF_SQL] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_FOLDERSQOIUD] FOREIGN KEY ([FOLDERSQOID]) REFERENCES [dbo].[DEF_SQL] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_INITFORMOID] FOREIGN KEY ([INITFORMOID]) REFERENCES [dbo].[DEF_FORM] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_LISTUNIT] FOREIGN KEY ([LISTUNIT]) REFERENCES [dbo].[DEF_UNIT] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_LIVEUNIT] FOREIGN KEY ([LIVEUNIT]) REFERENCES [dbo].[DEF_UNIT] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_MODULEOID] FOREIGN KEY ([MODULEOID]) REFERENCES [dbo].[DEF_MODULES] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_NEWFORMOID] FOREIGN KEY ([NEWFORMOID]) REFERENCES [dbo].[DEF_FORM] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_OPENUNITOID] FOREIGN KEY ([OPENUNITOID]) REFERENCES [dbo].[DEF_UNIT] ([OID]),
    CONSTRAINT [FK_DEF_CLASSES_SRVOID] FOREIGN KEY ([SRVOID]) REFERENCES [dbo].[DEF_SERVERS] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_CLASSES_1]
    ON [dbo].[DEF_CLASSES]([LABEL] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_CLASSES]
    ON [dbo].[DEF_CLASSES]([OID] ASC);

