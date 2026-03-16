CREATE TABLE [dbo].[DEF_FRL] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [LANGUAGE] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

