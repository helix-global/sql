CREATE TABLE [dbo].[MSG_SETTINGS] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [SERVERNAME]       NVARCHAR (50)    NOT NULL,
    [EXCH_URL]         NVARCHAR (200)   NOT NULL,
    [EXCH_UDOMAIN]     NVARCHAR (100)   NOT NULL,
    [EXCH_UNAME]       NVARCHAR (100)   NOT NULL,
    [EXCH_P]           NVARCHAR (100)   NOT NULL,
    [REMARK]           NTEXT            NULL,
    [DO_CHIPLOADER]    INT              NULL,
    [DO_SERVICEBOXES]  INT              NULL,
    [DO_DOC_METHODS]   INT              NULL,
    [DO_COREEXEC]      INT              NULL,
    [DO_SHIPMENTTRANS] INT              NULL,
    [DO_DUTY_TASKS]    INT              NULL,
    [DO_PORTALDEPLOY]  INT              NULL,
    [EXCH_VER]         INT              NULL,
    [DO_FULLMODELS]    INT              NULL,
    [DO_LOADSOSTATES]  INT              NULL,
    [DO_REPORTS2]      INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MSG_SETTINGS_SERVERNAME]
    ON [dbo].[MSG_SETTINGS]([SERVERNAME] ASC);

