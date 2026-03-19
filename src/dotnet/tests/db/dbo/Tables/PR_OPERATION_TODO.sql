CREATE TABLE [dbo].[PR_OPERATION_TODO] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [OPERID]       INT              NOT NULL,
    [ORDERPOS]     INT              NOT NULL,
    [OPERATIONID]  INT              NOT NULL,
    [TODO]         NTEXT            NULL,
    [DONEID]       INT              NULL,
    [EMPLOYEEID]   INT              NULL,
    [TRBRANCH]     INT              NULL,
    [TODO_CONFIRM] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_OPERATION_TODO_EMPLOYEEID] FOREIGN KEY ([EMPLOYEEID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_PR_OPERATION_TODO_OPERID] FOREIGN KEY ([OPERID]) REFERENCES [dbo].[PR_OPERATION] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_TODO]
    ON [dbo].[PR_OPERATION_TODO]([OPERID] ASC);

