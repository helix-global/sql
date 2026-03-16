CREATE TABLE [dbo].[SM_INBOX] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_S]              INT              NOT NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [BOXID]            INT              NOT NULL,
    [MSGFROM]          NVARCHAR (1024)  NULL,
    [MSGSUBJ]          NVARCHAR (1024)  NULL,
    [MSGBODY]          NTEXT            NULL,
    [MSGDD]            DATETIME         NULL,
    [MSGCC]            NVARCHAR (MAX)   NULL,
    [MSGSIGNED]        INT              NULL,
    [MSGSENDERTRUSTED] INT              NULL,
    [MSGID]            NVARCHAR (100)   NULL,
    [CONTACTID]        INT              NULL,
    [MSGTO]            NVARCHAR (MAX)   NULL,
    [MSGTORAW]         NVARCHAR (MAX)   NULL,
    [MSGCCRAW]         NVARCHAR (MAX)   NULL,
    [PLAINTEXT]        INT              NULL,
    [MSG_RECIEVED]     DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_INBOX_BOXID] FOREIGN KEY ([BOXID]) REFERENCES [dbo].[SM_EMAIL_BOXES] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_SM_INBOX_S_CDT_S_S]
    ON [dbo].[SM_INBOX]([S_CDT] ASC, [S_S] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SM_INBOX_BOXID_MSGID]
    ON [dbo].[SM_INBOX]([BOXID] ASC, [MSGID] ASC);

