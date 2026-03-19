CREATE TABLE [dbo].[COM_SHACCOUNT_S] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_S]        INT              NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [ACCOUNTID]  INT              NOT NULL,
    [DBEG]       DATE             NOT NULL,
    [DEND]       DATE             NOT NULL,
    [EMPLOYEEID] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_SHACCOUNT_S_ACCOUNTID] FOREIGN KEY ([ACCOUNTID]) REFERENCES [dbo].[COM_SHARED_ACCOUNTS] ([ID]),
    CONSTRAINT [FK_COM_SHACCOUNT_S_EMPLOYEEID] FOREIGN KEY ([EMPLOYEEID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);

