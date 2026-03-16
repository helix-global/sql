CREATE TABLE [dbo].[SYNC2_NOTIFICATIONS] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_S]          INT              NOT NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [DEPID]        INT              NOT NULL,
    [TOLOCATIONID] INT              NOT NULL,
    [REMARK]       NTEXT            NULL,
    [TR_TYPE]      INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SYNC2_NOTIFICATIONS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SYNC2_NOTIFICATIONS_2]
    ON [dbo].[SYNC2_NOTIFICATIONS]([DEPID] ASC, [TOLOCATIONID] ASC, [TR_TYPE] ASC);

