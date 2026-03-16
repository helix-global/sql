CREATE TABLE [dbo].[PU_SEARCH_ITEMS] (
    [ID]                  INT              IDENTITY (1, 1) NOT NULL,
    [GID]                 UNIQUEIDENTIFIER NOT NULL,
    [S_CR]                INT              NOT NULL,
    [S_CDT]               DATETIME         NOT NULL,
    [S_MR]                INT              NULL,
    [S_MDT]               DATETIME         NULL,
    [ARC]                 INT              NULL,
    [SEARCHID]            INT              NOT NULL,
    [QTY]                 INT              NULL,
    [QUERY_FREQ]          INT              NULL,
    [LAST_REQUEST]        DATETIME         NULL,
    [LAST_REQUEST_RESULT] NVARCHAR (4000)  NULL,
    [CODE]                NVARCHAR (16)    NULL,
    CONSTRAINT [PK__PU_SEARC__3214EC276299DCB3] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PU_SEARCH_ITEMS_SEARCHID] FOREIGN KEY ([SEARCHID]) REFERENCES [dbo].[PU_SEARCH] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PU_SEARCH_ITEMS]
    ON [dbo].[PU_SEARCH_ITEMS]([SEARCHID] ASC);

