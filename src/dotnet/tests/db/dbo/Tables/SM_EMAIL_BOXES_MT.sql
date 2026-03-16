CREATE TABLE [dbo].[SM_EMAIL_BOXES_MT] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [VNESHID]      INT              NOT NULL,
    [MTID]         INT              NOT NULL,
    [SHOW_RELATED] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_EMAIL_BOXES_MT_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID]),
    CONSTRAINT [FK_SM_EMAIL_BOXES_MT_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[SM_EMAIL_BOXES] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SM_EMAIL_BOXES_MT]
    ON [dbo].[SM_EMAIL_BOXES_MT]([VNESHID] ASC);

