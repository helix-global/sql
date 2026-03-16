CREATE TABLE [dbo].[IT_A_LOG] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [SQLTEXT]   NTEXT            NULL,
    [USERNAME]  NVARCHAR (200)   NOT NULL,
    [DD]        DATETIME         NOT NULL,
    [FINOBJECT] INT              NULL,
    [REMARK]    NTEXT            NULL,
    [REQ_DEP]   NVARCHAR (10)    NULL,
    [BATCH_N]   INT              NOT NULL,
    [DEVUSER]   NVARCHAR (200)   NULL,
    [DEVDATE]   DATETIME         NULL,
    [ISSUEDATE] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

