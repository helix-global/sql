CREATE TABLE [dbo].[MSG_LOGOS] (
    [ID]    INT              IDENTITY (1, 1) NOT NULL,
    [GID]   UNIQUEIDENTIFIER NULL,
    [S_CR]  INT              NOT NULL,
    [S_CDT] DATETIME         NOT NULL,
    [S_MR]  INT              NULL,
    [S_MDT] DATETIME         NULL,
    [ARC]   INT              NULL,
    [NAME]  NVARCHAR (100)   NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MSG_LOGOS_NAME]
    ON [dbo].[MSG_LOGOS]([NAME] ASC);

