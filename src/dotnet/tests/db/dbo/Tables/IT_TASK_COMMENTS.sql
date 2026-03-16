CREATE TABLE [dbo].[IT_TASK_COMMENTS] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [TASKID]    INT              NOT NULL,
    [CTEXT]     NTEXT            NULL,
    [NEWSTATE]  INT              NULL,
    [PLAINTEXT] NTEXT            NULL,
    [TS]        ROWVERSION       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IT_TASK_COMMENTS_TASKID] FOREIGN KEY ([TASKID]) REFERENCES [dbo].[IT_TASKS] ([ID]) ON DELETE CASCADE
);

