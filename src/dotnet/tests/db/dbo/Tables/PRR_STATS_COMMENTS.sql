CREATE TABLE [dbo].[PRR_STATS_COMMENTS] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [YY]       INT              NOT NULL,
    [MM]       INT              NOT NULL,
    [DEPID]    INT              NOT NULL,
    [COMMENTS] NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PRR_STATS_COMMENTS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PRR_STATS_COMMENTS]
    ON [dbo].[PRR_STATS_COMMENTS]([YY] ASC, [MM] ASC, [DEPID] ASC);

