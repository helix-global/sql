CREATE TABLE [dbo].[PM_DUEDATE_AGREEMENT] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NOT NULL,
    [S_S]    INT              NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [DD]     DATE             NOT NULL,
    [REMARK] NTEXT            NULL,
    [TASKID] INT              NOT NULL,
    [TYPE]   INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PM_DUEDATE_AGREEMENT_TASKID] FOREIGN KEY ([TASKID]) REFERENCES [dbo].[PM_TASK] ([ID])
);

