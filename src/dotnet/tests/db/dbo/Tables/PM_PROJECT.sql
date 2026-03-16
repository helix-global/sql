CREATE TABLE [dbo].[PM_PROJECT] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [NAME]        NVARCHAR (500)   NOT NULL,
    [DEPID]       INT              NOT NULL,
    [PROJLEAD]    INT              NOT NULL,
    [DESCRIPTION] NTEXT            NULL,
    [DBEG]        DATETIME         NULL,
    [PLANDATE]    DATETIME         NULL,
    [CLODEDATE]   DATETIME         NULL,
    [PTYPE]       INT              NOT NULL,
    [REMARKS]     NTEXT            NULL,
    [S_S]         INT              NOT NULL,
    [CODE]        NVARCHAR (50)    NOT NULL,
    [JIRA_ID]     INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PM_PROJECT_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PM_PROJECT_PROJLEAD] FOREIGN KEY ([PROJLEAD]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PM_PROJECT_JIRA_ID]
    ON [dbo].[PM_PROJECT]([JIRA_ID] ASC) WHERE ([JIRA_ID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PM_PROJECT_CODE]
    ON [dbo].[PM_PROJECT]([CODE] ASC);

