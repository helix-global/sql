CREATE TABLE [dbo].[SM_CUSTOMEVENTS] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [DBEG]   DATETIME         NOT NULL,
    [DEND]   DATETIME         NOT NULL,
    [REMARK] NTEXT            NULL,
    [RESS]   NVARCHAR (MAX)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

