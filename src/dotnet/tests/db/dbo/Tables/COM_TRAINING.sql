CREATE TABLE [dbo].[COM_TRAINING] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_S]              INT              NOT NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [SKILLID]          INT              NOT NULL,
    [EMPLOYEEID]       INT              NULL,
    [TARGETDATE]       DATETIME         NULL,
    [TRAINING_TYPE]    INT              NULL,
    [REMARK]           NTEXT            NULL,
    [OPERATION_MODE]   INT              NULL,
    [AUTOINCLUDE_ITEM] INT              NULL,
    [START_DATE]       DATE             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_TRAINING_EMPLOYEEID] FOREIGN KEY ([EMPLOYEEID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_COM_TRAINING_SKILLID] FOREIGN KEY ([SKILLID]) REFERENCES [dbo].[COM_SKILLS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_TRAINING]
    ON [dbo].[COM_TRAINING]([S_CDT] ASC, [EMPLOYEEID] ASC, [SKILLID] ASC, [TARGETDATE] ASC);

