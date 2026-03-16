CREATE TABLE [dbo].[PM_TT_NOTIFY] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [DEPID]       INT              NOT NULL,
    [REMARK]      NTEXT            NULL,
    [ENABL]       INT              NOT NULL,
    [LAST_EXECDD] DATE             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PM_TT_NOTIFY_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PM_TT_NOTIFY_DEPID]
    ON [dbo].[PM_TT_NOTIFY]([DEPID] ASC);

