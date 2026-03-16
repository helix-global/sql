CREATE TABLE [dbo].[LN_WEEKS] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [ISOWEEK] INT              NOT NULL,
    [YEAR]    INT              NOT NULL,
    [REMARK]  NTEXT            NULL,
    [DBEG]    DATETIME         NOT NULL,
    [S_S]     INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_LN_WEEKS_DBEG]
    ON [dbo].[LN_WEEKS]([DBEG] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_LN_WEEKS]
    ON [dbo].[LN_WEEKS]([YEAR] ASC, [ISOWEEK] ASC);

