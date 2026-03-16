CREATE TABLE [dbo].[DEF_VIEW_LEVELS] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [OID]             INT              NOT NULL,
    [PARENTOID]       INT              NULL,
    [CLASSOID]        INT              NULL,
    [MASTERIDFIELD]   VARCHAR (50)     NULL,
    [DETAILLINKFIELD] VARCHAR (50)     NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_CR]            INT              NULL,
    [S_MR]            INT              NULL,
    [S_CDT]           DATETIME         NULL,
    [S_MDT]           DATETIME         NULL,
    CONSTRAINT [PK_DEF_VIEW_LEVELS] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_VIEW_LEVELS_OID]
    ON [dbo].[DEF_VIEW_LEVELS]([OID] ASC);

