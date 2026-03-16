CREATE TABLE [dbo].[IT_KB_NOTIFICATIONS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [EMPID]       INT              NULL,
    [ONLYMY]      INT              NULL,
    [COMMENT_ADD] INT              NULL,
    [PLAN_CHANGE] INT              NULL,
    [NEW_TASKS]   INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IT_KB_NOTIFICATIONS_EMPID] FOREIGN KEY ([EMPID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IT_KB_NOTIFICATIONS]
    ON [dbo].[IT_KB_NOTIFICATIONS]([EMPID] ASC);

