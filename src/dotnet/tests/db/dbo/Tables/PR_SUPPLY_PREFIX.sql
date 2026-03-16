CREATE TABLE [dbo].[PR_SUPPLY_PREFIX] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [PREFIX]      NVARCHAR (5)     NULL,
    [DESCRIPTION] NVARCHAR (250)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

