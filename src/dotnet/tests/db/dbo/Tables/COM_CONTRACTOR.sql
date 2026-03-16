CREATE TABLE [dbo].[COM_CONTRACTOR] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [NAME]    NVARCHAR (250)   NULL,
    [INTCODE] NVARCHAR (20)    NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NULL,
    [S_MR]    INT              NULL,
    [S_CDT]   DATETIME         NULL,
    [S_MDT]   DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

