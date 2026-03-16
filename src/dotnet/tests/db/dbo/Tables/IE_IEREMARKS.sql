CREATE TABLE [dbo].[IE_IEREMARKS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [VNESHID]    INT              NOT NULL,
    [DD]         DATE             NOT NULL,
    [REMARK]     NTEXT            NOT NULL,
    [IMPORTANCE] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IE_IEREMARKS_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[IE_IE] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_IE_IEREMARKS]
    ON [dbo].[IE_IEREMARKS]([VNESHID] ASC);

