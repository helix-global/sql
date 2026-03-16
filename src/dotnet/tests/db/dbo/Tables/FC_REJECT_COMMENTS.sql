CREATE TABLE [dbo].[FC_REJECT_COMMENTS] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [FRID]     INT              NOT NULL,
    [RCOMMENT] NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_REJECT_COMMENTS_FRID] FOREIGN KEY ([FRID]) REFERENCES [dbo].[FC_REPORT] ([ID]) ON DELETE CASCADE
);

