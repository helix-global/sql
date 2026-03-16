CREATE TABLE [dbo].[FC_FAILURECODES] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [DESCRIPTION]      NTEXT            NULL,
    [NAME]             NVARCHAR (200)   NOT NULL,
    [CAPTION]          NVARCHAR (400)   NULL,
    [S_S]              INT              NOT NULL,
    [POSORDER]         INT              NULL,
    [MTID]             INT              NOT NULL,
    [TEMP_OLDID]       INT              NULL,
    [TEMP_WASADDED]    INT              NULL,
    [TEMP_OLDDEPARTID] INT              NULL,
    [INTUSE]           INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FC_FAILURECODES_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_TEMP_FC_FAILURECODES_OLDID]
    ON [dbo].[FC_FAILURECODES]([TEMP_OLDID] ASC);

