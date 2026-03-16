CREATE TABLE [dbo].[SM_RMA_NOTIFICATIONS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [SCASEID]     INT              NOT NULL,
    [RESULT]      INT              NOT NULL,
    [RESULTRMA]   NVARCHAR (50)    NULL,
    [RESULTERROR] NVARCHAR (110)   NULL,
    [MSGID]       INT              NULL,
    [REQUESTID]   INT              NOT NULL,
    [S_S]         INT              NOT NULL,
    [REQUEST_CR]  INT              NULL,
    CONSTRAINT [PK__SM_RMA_N__3214EC276CAED6EF] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SM_RMA_NOTIFICATIONS_S_S]
    ON [dbo].[SM_RMA_NOTIFICATIONS]([S_S] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SM_RMA_NOTIFICATIONS_REQUESTID]
    ON [dbo].[SM_RMA_NOTIFICATIONS]([REQUESTID] ASC);

