CREATE TABLE [dbo].[SM_REASONS4DELAY] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NOT NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [NAME]    NVARCHAR (320)   NOT NULL,
    [LISTPOS] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

