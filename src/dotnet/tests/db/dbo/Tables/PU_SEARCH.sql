CREATE TABLE [dbo].[PU_SEARCH] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_S]        INT              NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [NAME]       NVARCHAR (200)   NULL,
    [START]      DATETIME         NULL,
    [QUERY_FREQ] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

