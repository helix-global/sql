CREATE TABLE [dbo].[PR_FP_PLANNING_ITEMS] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NOT NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [DEVICEID]     INT              NOT NULL,
    [DBEG]         DATETIME         NULL,
    [DEND]         DATETIME         NULL,
    [TURMNUM]      INT              NULL,
    [LOCK_COMMENT] NVARCHAR (250)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [CK_PR_FP_PLANNING_ITEMS] CHECK ([dbo].[PR_FP_CHECK_DEVICEID_UNIQ]()=(0))
);

