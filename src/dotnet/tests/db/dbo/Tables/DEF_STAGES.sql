CREATE TABLE [dbo].[DEF_STAGES] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [OID]             INT              NOT NULL,
    [LABEL]           NVARCHAR (256)   NOT NULL,
    [NAME]            NVARCHAR (2048)  NOT NULL,
    [STAGETYPE]       INT              NOT NULL,
    [METHODOID]       INT              NULL,
    [STATEOID]        INT              NULL,
    [CLASSOID]        INT              NULL,
    [ENTITYOID]       INT              NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_CR]            INT              NULL,
    [S_MR]            INT              NULL,
    [S_CDT]           DATETIME         NULL,
    [S_MDT]           DATETIME         NULL,
    [SQLTEXT]         NTEXT            NULL,
    [CSTEXT]          NTEXT            NULL,
    [DISABLE]         INT              NULL,
    [NATIVECLASS]     NVARCHAR (150)   NULL,
    [DESCRIPTION]     NTEXT            NULL,
    [SORTORDER]       INT              NOT NULL,
    [LONGSTAGE]       INT              NULL,
    [OPTIONS]         NVARCHAR (512)   NULL,
    [HTML_REPORT_OID] INT              NULL,
    [UOID]            INT              NULL,
    CONSTRAINT [PK_DEF_STAGES] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_STAGES_CLASSOID] FOREIGN KEY ([CLASSOID]) REFERENCES [dbo].[DEF_CLASSES] ([OID]),
    CONSTRAINT [FK_DEF_STAGES_ENTITYOID] FOREIGN KEY ([ENTITYOID]) REFERENCES [dbo].[DEF_ENTITY] ([OID]),
    CONSTRAINT [FK_DEF_STAGES_METHODOID] FOREIGN KEY ([METHODOID]) REFERENCES [dbo].[DEF_CLASS_METHODS] ([OID]),
    CONSTRAINT [FK_DEF_STAGES_STATEOID] FOREIGN KEY ([STATEOID]) REFERENCES [dbo].[DEF_CLASS_STATES] ([OID]),
    CONSTRAINT [FK_DEF_STAGES_UOID] FOREIGN KEY ([UOID]) REFERENCES [dbo].[DEF_UNIT] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_STAGES_OID]
    ON [dbo].[DEF_STAGES]([OID] ASC);

