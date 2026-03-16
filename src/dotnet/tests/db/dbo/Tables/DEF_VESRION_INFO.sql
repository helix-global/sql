CREATE TABLE [dbo].[DEF_VESRION_INFO] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NOT NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [VERSION] NVARCHAR (15)    NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

