CREATE TABLE [dbo].[PR_NAV_SOSTATES] (
    [ORDERID]   INT              NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_S]       INT              NOT NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [NAVSTATE]  INT              NULL,
    [LASTERROR] NVARCHAR (500)   NULL,
    PRIMARY KEY CLUSTERED ([ORDERID] ASC)
);

