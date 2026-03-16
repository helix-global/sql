CREATE TABLE [dbo].[COM_UNITS] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NULL,
    [S_CR]   INT              NULL,
    [S_CDT]  DATETIME         NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [NAME]   NVARCHAR (200)   NOT NULL,
    [SYMBOL] NVARCHAR (50)    NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

