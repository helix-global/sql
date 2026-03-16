CREATE TABLE [dbo].[PR_NAV_SERVICE_ORD_SETT] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [DEPID]          INT              NOT NULL,
    [CALL_CHREPSTAT] INT              NULL,
    [REMARK]         NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_NAV_SERVICE_ORD_SETT_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_NAV_SERVICE_ORD_SETT_DEPID]
    ON [dbo].[PR_NAV_SERVICE_ORD_SETT]([DEPID] ASC);

