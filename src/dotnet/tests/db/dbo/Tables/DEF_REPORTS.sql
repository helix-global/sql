CREATE TABLE [dbo].[DEF_REPORTS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [MODULEOID]      INT              NOT NULL,
    [LABEL]          NVARCHAR (256)   NOT NULL,
    [OID]            INT              NOT NULL,
    [ARC]            INT              NULL,
    [NAME]           NVARCHAR (2048)  NOT NULL,
    [REPORT]         IMAGE            NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NULL,
    [S_MR]           INT              NULL,
    [S_CDT]          DATETIME         NULL,
    [S_MDT]          DATETIME         NULL,
    [REMARK]         NTEXT            NULL,
    [ISOCODE]        NVARCHAR (20)    NULL,
    [SAVEOPT]        INT              NULL,
    [FOLDERIMG]      NVARCHAR (120)   NULL,
    [COMPILEDSCRIPT] IMAGE            NULL,
    [S_S]            INT              DEFAULT ((1)) NULL,
    [OPTIONS]        NVARCHAR (512)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_REPORTS_MODULEOID] FOREIGN KEY ([MODULEOID]) REFERENCES [dbo].[DEF_MODULES] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_REPORTS_1]
    ON [dbo].[DEF_REPORTS]([LABEL] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_REPORTS]
    ON [dbo].[DEF_REPORTS]([OID] ASC);

