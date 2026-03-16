CREATE TABLE [dbo].[SM_SERVICETASKS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [MTID]           INT              NOT NULL,
    [OPERFORMID]     INT              NOT NULL,
    [ESTIMATED_TIME] INT              NOT NULL,
    [REMARK]         NTEXT            NULL,
    [NAME]           NVARCHAR (200)   NOT NULL,
    [DEPID]          INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_SERVICETASKS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_SM_SERVICETASKS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID]),
    CONSTRAINT [FK_SM_SERVICETASKS_OPERFORMID] FOREIGN KEY ([OPERFORMID]) REFERENCES [dbo].[PR_OPERATIONS] ([ID])
);

