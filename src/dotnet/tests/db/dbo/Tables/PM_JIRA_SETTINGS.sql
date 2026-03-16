CREATE TABLE [dbo].[PM_JIRA_SETTINGS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [AUTOLOAD]   INT              NOT NULL,
    [USR]        NVARCHAR (50)    NOT NULL,
    [PSW]        NVARCHAR (50)    NOT NULL,
    [JHOST]      NVARCHAR (200)   NOT NULL,
    [JDOMAIN]    NVARCHAR (50)    NOT NULL,
    [LASTIMPORT] DATETIME         NULL,
    [LASTERROR]  NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

