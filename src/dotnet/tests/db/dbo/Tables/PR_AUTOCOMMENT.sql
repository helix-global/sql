CREATE TABLE [dbo].[PR_AUTOCOMMENT] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [DEVICEID]         INT              NOT NULL,
    [MAPOPERID]        INT              NOT NULL,
    [TODOTEXT]         NTEXT            NOT NULL,
    [TODOTEXT_SHOWMSG] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_AUTOCOMMENT_DEVICEID] FOREIGN KEY ([DEVICEID]) REFERENCES [dbo].[PR_DEVICE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_AUTOCOMMENT2]
    ON [dbo].[PR_AUTOCOMMENT]([DEVICEID] ASC, [MAPOPERID] ASC);

