CREATE TABLE [dbo].[DEF_SQL] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [OID]         INT              NOT NULL,
    [LABEL]       NVARCHAR (256)   NOT NULL,
    [NAME]        NVARCHAR (2048)  NOT NULL,
    [MODULEOID]   INT              NOT NULL,
    [SQLTEXT]     NTEXT            NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NULL,
    [S_MR]        INT              NULL,
    [S_CDT]       DATETIME         NULL,
    [S_MDT]       DATETIME         NULL,
    [DESCRIPTION] NTEXT            NULL,
    [OPTIONS]     NVARCHAR (512)   NULL,
    [ARC]         INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_SQL_MODULEOID] FOREIGN KEY ([MODULEOID]) REFERENCES [dbo].[DEF_MODULES] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_SQL_1]
    ON [dbo].[DEF_SQL]([LABEL] ASC) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_SQL]
    ON [dbo].[DEF_SQL]([OID] ASC) WITH (FILLFACTOR = 90);

