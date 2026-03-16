CREATE TABLE [dbo].[PM_TASK_DEPEND] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [VNESHID]        INT              NOT NULL,
    [TOTASKID]       INT              NOT NULL,
    [DEPENDENCYTYPE] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PM_TASK_DEPEND_TOTASKID] FOREIGN KEY ([TOTASKID]) REFERENCES [dbo].[PM_TASK] ([ID]),
    CONSTRAINT [FK_PM_TASK_DEPEND_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[PM_TASK] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PM_TASK_DEPEND]
    ON [dbo].[PM_TASK_DEPEND]([VNESHID] ASC);

