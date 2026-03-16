CREATE TABLE [dbo].[PR_REV_CHANGINGS] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NULL,
    [S_S]    INT              NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [MTID]   INT              NOT NULL,
    [REMARK] NTEXT            NULL,
    [APPLDT] DATETIME         NULL,
    [APPLBY] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_REV_CHANGINGS_APPLBY] FOREIGN KEY ([APPLBY]) REFERENCES [dbo].[DEF_USERS] ([ID]),
    CONSTRAINT [FK_PR_REV_CHANGINGS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);

