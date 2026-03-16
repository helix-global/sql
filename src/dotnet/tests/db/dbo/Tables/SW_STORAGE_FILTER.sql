CREATE TABLE [dbo].[SW_STORAGE_FILTER] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NOT NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [FILTER_STRING] NVARCHAR (4000)  NULL,
    [FOLDERID]      INT              NULL,
    [NAME]          NVARCHAR (250)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SW_STORAGE_FILTER_SW_STORAGE] FOREIGN KEY ([FOLDERID]) REFERENCES [dbo].[SW_STORAGE] ([ID])
);

