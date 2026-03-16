CREATE TABLE [dbo].[PR_NAV_VAC_DEPMODES] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [DEPID]     INT              NOT NULL,
    [SENDV2NAV] INT              NOT NULL,
    [SHOWMENU]  INT              NULL,
    [REMARK]    NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_NAV_VAC_DEPMODES_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_NAV_VAC_DEPMODES_1]
    ON [dbo].[PR_NAV_VAC_DEPMODES]([DEPID] ASC);

