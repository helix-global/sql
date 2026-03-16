CREATE TABLE [dbo].[PR_REPAIR_RQ] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_S]      INT              NULL,
    [S_CR]     INT              NULL,
    [S_CDT]    DATETIME         NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [DEVICEID] INT              NOT NULL,
    [REMARK]   NTEXT            NULL,
    [REASON]   NVARCHAR (400)   NOT NULL,
    [ARC]      INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_REPAIR_RQ_DEVICEID] FOREIGN KEY ([DEVICEID]) REFERENCES [dbo].[PR_DEVICE] ([ID])
);

