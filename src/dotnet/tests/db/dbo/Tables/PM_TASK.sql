CREATE TABLE [dbo].[PM_TASK] (
    [ID]                  INT              IDENTITY (1, 1) NOT NULL,
    [GID]                 UNIQUEIDENTIFIER NOT NULL,
    [S_S]                 INT              NOT NULL,
    [S_CR]                INT              NOT NULL,
    [S_CDT]               DATETIME         NOT NULL,
    [S_MR]                INT              NULL,
    [S_MDT]               DATETIME         NULL,
    [ARC]                 INT              NULL,
    [PROJID]              INT              NOT NULL,
    [PARENTID]            INT              NULL,
    [SUBJ]                NVARCHAR (500)   NOT NULL,
    [DESCR]               NTEXT            NULL,
    [DEPID]               INT              NOT NULL,
    [RESPDEP]             INT              NOT NULL,
    [DBEG]                DATETIME         NULL,
    [DUEDATE]             DATETIME         NULL,
    [PLANDATE]            DATETIME         NULL,
    [CLODEDATE]           DATETIME         NULL,
    [PRIORITY]            INT              NOT NULL,
    [DD]                  DATETIME         NOT NULL,
    [LABOR_EST]           DECIMAL (10, 2)  NULL,
    [RESPDEP_NOTIFIED]    DATETIME         NULL,
    [RESPDEP_NOTIFIED_ID] INT              NULL,
    [JIRA_ID]             INT              NULL,
    [SHORTDESCR]          NVARCHAR (250)   NULL,
    [LASTPLAN_ROWID]      INT              NULL,
    [EXCLFROMPLAN]        INT              NULL,
    [CLOSEREASON]         NTEXT            NULL,
    [TASKTYPEOVERRIDE]    INT              NULL,
    [COMPLETE_DT]         DATETIME         NULL,
    [TEMP_ID]             INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PM_TASK_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PM_TASK_PARENTID] FOREIGN KEY ([PARENTID]) REFERENCES [dbo].[PM_TASK] ([ID]),
    CONSTRAINT [FK_PM_TASK_PROJID] FOREIGN KEY ([PROJID]) REFERENCES [dbo].[PM_PROJECT] ([ID]),
    CONSTRAINT [FK_PM_TASK_RESPDEP] FOREIGN KEY ([RESPDEP]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PM_TASK_S_S_JIRA_ID_DUEDATE_LABOR_EST]
    ON [dbo].[PM_TASK]([S_S] ASC, [JIRA_ID] ASC, [DUEDATE] ASC, [LABOR_EST] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PM_TASK_S_CR_ID]
    ON [dbo].[PM_TASK]([S_CR] ASC)
    INCLUDE([ID]);


GO
CREATE NONCLUSTERED INDEX [IX_PM_TASK_RESPDEP]
    ON [dbo].[PM_TASK]([RESPDEP] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PM_TASK_PROJID]
    ON [dbo].[PM_TASK]([PROJID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PM_TASK_PARENTID]
    ON [dbo].[PM_TASK]([PARENTID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PM_TASK_JIRA_ID]
    ON [dbo].[PM_TASK]([JIRA_ID] ASC) WHERE ([JIRA_ID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_PM_TASK_DEPID]
    ON [dbo].[PM_TASK]([DEPID] ASC);

