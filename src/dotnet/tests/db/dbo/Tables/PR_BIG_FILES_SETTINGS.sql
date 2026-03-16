CREATE TABLE [dbo].[PR_BIG_FILES_SETTINGS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [PARAMID]     INT              NOT NULL,
    [ALLOWEDSIZE] INT              NOT NULL,
    [REMARK]      NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_BIG_FILES_SETTINGS]
    ON [dbo].[PR_BIG_FILES_SETTINGS]([PARAMID] ASC);

