CREATE TABLE [dbo].[PR_SUPPLY_STATE] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [STATE]       NVARCHAR (20)    NULL,
    [DESCRIPTION] NVARCHAR (250)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

