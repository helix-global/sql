CREATE TABLE [dbo].[IT_TASKS_SEARCH] (
    [ID]     INT             IDENTITY (1, 1) NOT NULL,
    [BODY]   VARBINARY (MAX) NULL,
    [DT]     AS              ('.html'),
    [TYPE]   NVARCHAR (1)    NULL,
    [TASKID] INT             NULL,
    [OBJID]  INT             NULL,
    CONSTRAINT [PK_IT_TASKS_SEARCH] PRIMARY KEY CLUSTERED ([ID] ASC)
);

