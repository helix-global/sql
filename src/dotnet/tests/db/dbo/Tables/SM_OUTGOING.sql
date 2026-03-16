CREATE TABLE [dbo].[SM_OUTGOING] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_S]           INT              NOT NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [MSGTO]         NVARCHAR (MAX)   NULL,
    [MSGSUBJ]       NVARCHAR (1024)  NOT NULL,
    [MSGBODY]       NTEXT            NULL,
    [MSGSENT]       DATETIME         NULL,
    [MSGDELIVERYID] INT              NULL,
    [MSGCC]         NVARCHAR (MAX)   NULL,
    [ERRLOG]        NTEXT            NULL,
    [MSGIMP]        INT              NULL,
    [MSGBCC]        NVARCHAR (MAX)   NULL,
    [BOXID]         INT              NOT NULL,
    [SERVICECALLID] INT              NOT NULL,
    [ERRINFOID]     INT              NULL,
    [ERRINFOID2]    INT              NULL,
    [SENDERRCOUNT]  INT              NULL,
    [ERRINFODONE]   INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_OUTGOING_BOXID] FOREIGN KEY ([BOXID]) REFERENCES [dbo].[SM_EMAIL_BOXES] ([ID]),
    CONSTRAINT [FK_SM_OUTGOING_SERVICECALLID] FOREIGN KEY ([SERVICECALLID]) REFERENCES [dbo].[SM_SERVICECALL] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_SM_OUTGOING_S_CDT_S_S]
    ON [dbo].[SM_OUTGOING]([S_CDT] ASC, [S_S] ASC);

