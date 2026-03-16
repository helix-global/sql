CREATE TABLE [dbo].[PR_AUTOOPERATION] (
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
    [OPERFORMID]     INT              NOT NULL,
    [BOUNDOPERID]    INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_AUTOOPERATION_NEWOPERFORMID] FOREIGN KEY ([OPERFORMID]) REFERENCES [dbo].[PR_OPERATIONS] ([ID]),
    CONSTRAINT [FK_PR_AUTOPOSTPONE_DEVICEID_copy] FOREIGN KEY ([DEVICEID]) REFERENCES [dbo].[PR_DEVICE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_AUTOPOSTPONE]
    ON [dbo].[PR_AUTOOPERATION]([DEVICEID] ASC, [MAPOPERID] ASC, [S_S] ASC);

