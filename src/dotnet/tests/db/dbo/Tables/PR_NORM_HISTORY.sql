CREATE TABLE [dbo].[PR_NORM_HISTORY] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [OPERID]   INT              NOT NULL,
    [REVID]    INT              NULL,
    [USERID]   INT              NOT NULL,
    [DD]       DATETIME         NOT NULL,
    [OLDVALUE] DECIMAL (10, 1)  NULL,
    [NEWVALUE] DECIMAL (10, 1)  NULL,
    [REMARK]   NVARCHAR (200)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

