CREATE TABLE [dbo].[MSG_OUTGOING] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_S]              INT              NOT NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [MSGTO]            NVARCHAR (MAX)   NOT NULL,
    [MSGSUBJ]          NVARCHAR (1024)  NOT NULL,
    [MSGBODY]          NTEXT            NULL,
    [MSGSENT]          DATETIME         NULL,
    [MSGDELIVERYID]    INT              NULL,
    [MSGCC]            NVARCHAR (MAX)   NULL,
    [ERRLOG]           NTEXT            NULL,
    [INCOMINGID]       INT              NULL,
    [MSGIMP]           INT              NULL,
    [DELIVERYID]       INT              NULL,
    [MSGOPTIONS]       NVARCHAR (250)   NULL,
    [SENDERRCOUNT]     INT              NULL,
    [CUSTOMERSUBSCRID] INT              NULL,
    [MSGBCC]           NVARCHAR (MAX)   NULL,
    [DOCOID]           INT              NULL,
    [DOCID]            INT              NULL,
    [CUSTOMERID]       INT              NULL,
    [SEND_AFTER_DT]    DATETIME         NULL,
    [MSGTYPE]          INT              NULL,
    [MEETING_LOCATION] NVARCHAR (250)   NULL,
    [MEETING_START]    DATETIME         NULL,
    [MEETING_END]      DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_OUTGOING_S_CDT_S_S]
    ON [dbo].[MSG_OUTGOING]([S_CDT] ASC, [S_S] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_OUTGOING_C]
    ON [dbo].[MSG_OUTGOING]([CUSTOMERSUBSCRID] ASC) WHERE ([CUSTOMERSUBSCRID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_OUTGOING_2]
    ON [dbo].[MSG_OUTGOING]([MSGSENT] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_OUTGOING_1]
    ON [dbo].[MSG_OUTGOING]([MSGDELIVERYID] ASC, [S_CDT] ASC, [DELIVERYID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IS_MSG_MSG_OUTGOING_DOCOID_DOCID]
    ON [dbo].[MSG_OUTGOING]([DOCOID] ASC, [DOCID] ASC) WHERE ([DOCOID] IS NOT NULL AND [DOCID] IS NOT NULL);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[MSG_OUTGOING] TO [EMEA\DESVCMailExp]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[MSG_OUTGOING] TO [EMEA\DESVCMailExp]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[MSG_OUTGOING] TO [EMEA\DESVCMailExp]
    AS [dbo];

