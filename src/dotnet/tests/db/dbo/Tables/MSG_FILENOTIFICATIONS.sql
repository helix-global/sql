CREATE TABLE [dbo].[MSG_FILENOTIFICATIONS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [MTID]       INT              NOT NULL,
    [DEPID]      INT              NOT NULL,
    [CUSTOMERID] INT              NULL,
    [MSG]        NTEXT            NULL,
    [ADR]        NVARCHAR (500)   NULL,
    [CC]         NVARCHAR (500)   NULL,
    [SUBJ]       NVARCHAR (500)   NULL,
    [REMARK]     NTEXT            NULL,
    [EVENTTYPE]  INT              NOT NULL,
    [S_S]        INT              NOT NULL,
    [NAME]       NVARCHAR (200)   NOT NULL,
    [SENDDELAY]  INT              NULL,
    [BCC]        NVARCHAR (500)   NULL,
    [ALLMODELS]  INT              NULL,
    [STYPE]      INT              NOT NULL,
    [TICKETEXP]  INT              NULL,
    [ERRCOPYTO]  NVARCHAR (500)   NULL,
    [ERRTO]      NVARCHAR (500)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MSG_FILENOTIFICATIONS_CUSTOMERID] FOREIGN KEY ([CUSTOMERID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_MSG_FILENOTIFICATIONS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_MSG_FILENOTIFICATIONS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_FILENOTIFICATIONS_MTID]
    ON [dbo].[MSG_FILENOTIFICATIONS]([MTID] ASC);

