CREATE TABLE [dbo].[IC_SETTINGS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [RESOURCEURL] NVARCHAR (450)   NOT NULL,
    [CLIENTID]    NVARCHAR (250)   NOT NULL,
    [CLIENTS]     NVARCHAR (250)   NOT NULL,
    [AUTHORITY]   NVARCHAR (450)   NOT NULL,
    [REMARK]      NTEXT            NULL,
    [SERVERNAMES] NVARCHAR (200)   NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

