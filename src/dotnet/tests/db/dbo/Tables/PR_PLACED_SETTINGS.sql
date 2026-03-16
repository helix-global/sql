CREATE TABLE [dbo].[PR_PLACED_SETTINGS] (
    [ID]                 INT              IDENTITY (1, 1) NOT NULL,
    [GID]                UNIQUEIDENTIFIER NULL,
    [S_CR]               INT              NOT NULL,
    [S_CDT]              DATETIME         NOT NULL,
    [S_MR]               INT              NULL,
    [S_MDT]              DATETIME         NULL,
    [ARC]                INT              NULL,
    [DEPID]              INT              NOT NULL,
    [PLACEDORDER]        INT              NOT NULL,
    [NAVIO]              INT              NULL,
    [DAYSLAG]            INT              NOT NULL,
    [MTID]               INT              NULL,
    [PLACEDMTID]         INT              NOT NULL,
    [ADDINFORMATIONMODE] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_PLACED_SETTINGS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_PLACED_SETTINGS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID]),
    CONSTRAINT [FK_PR_PLACED_SETTINGS_PLACEDMTID] FOREIGN KEY ([PLACEDMTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_PLACED_SETTINGS_1]
    ON [dbo].[PR_PLACED_SETTINGS]([DEPID] ASC, [MTID] ASC, [PLACEDMTID] ASC);

