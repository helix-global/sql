CREATE TABLE [dbo].[PR_AUTOPOSTPONE] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [DEVICEID]       INT              NOT NULL,
    [MAPOPERID]      INT              NOT NULL,
    [DESCRIPTION]    NTEXT            NULL,
    [EMAILTOCREATOR] INT              NULL,
    [S_S]            INT              NOT NULL,
    [OPERID]         INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PR_AUTOPOSTPONE_DEVICEID] FOREIGN KEY ([DEVICEID]) REFERENCES [dbo].[PR_DEVICE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_AUTOPOSTPONE]
    ON [dbo].[PR_AUTOPOSTPONE]([DEVICEID] ASC, [MAPOPERID] ASC, [S_S] ASC) WITH (FILLFACTOR = 90);

