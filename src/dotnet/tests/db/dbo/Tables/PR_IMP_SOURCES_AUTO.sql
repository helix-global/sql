CREATE TABLE [dbo].[PR_IMP_SOURCES_AUTO] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [TRANSID]   INT              NOT NULL,
    [LOADTIME]  DATETIME         NOT NULL,
    [LASTLOAD]  DATETIME         NULL,
    [DISABLED]  INT              NULL,
    [ERRORS]    NVARCHAR (1)     NULL,
    [LASTERROR] DATETIME         NULL,
    [REMARK]    NTEXT            NULL,
    [ADDMODE]   INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_IMP_SOURCES_AUTO_TRANSID] FOREIGN KEY ([TRANSID]) REFERENCES [dbo].[PR_IMP_TRANS] ([ID])
);

