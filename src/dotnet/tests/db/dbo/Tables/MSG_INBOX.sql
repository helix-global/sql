CREATE TABLE [dbo].[MSG_INBOX] (
    [ID]                 INT              IDENTITY (1, 1) NOT NULL,
    [GID]                UNIQUEIDENTIFIER NULL,
    [S_S]                INT              NOT NULL,
    [S_CR]               INT              NOT NULL,
    [S_CDT]              DATETIME         NOT NULL,
    [S_MR]               INT              NULL,
    [S_MDT]              DATETIME         NULL,
    [MSGFROM]            NVARCHAR (1024)  NULL,
    [MSGSUBJ]            NVARCHAR (1024)  NULL,
    [MSGBODY]            NTEXT            NULL,
    [MSGPROCESSED]       DATETIME         NULL,
    [MSGCC]              NVARCHAR (1024)  NULL,
    [ERRLOG]             NTEXT            NULL,
    [MSGID]              NVARCHAR (100)   NULL,
    [MSGTASK]            INT              NULL,
    [OBJID]              INT              NULL,
    [ARC]                INT              NULL,
    [TEMPID]             INT              NULL,
    [MSGSIGNED]          INT              NULL,
    [MSGSENDERTRUSTED]   INT              NULL,
    [PACKETCREATEDEMAIL] NVARCHAR (200)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_INBOX_S_S]
    ON [dbo].[MSG_INBOX]([S_S] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_INBOX_S_CDT_S_S]
    ON [dbo].[MSG_INBOX]([S_CDT] ASC, [S_S] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MSG_INBOX]
    ON [dbo].[MSG_INBOX]([MSGID] ASC);

