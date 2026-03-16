CREATE TABLE [dbo].[IT_PROJECT] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [NAME]     NVARCHAR (200)   NOT NULL,
    [REMARK]   NTEXT            NULL,
    [TABCOLOR] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

