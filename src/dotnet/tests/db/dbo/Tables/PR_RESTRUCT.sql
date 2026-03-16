CREATE TABLE [dbo].[PR_RESTRUCT] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [DD]          DATETIME         NOT NULL,
    [REASON]      NVARCHAR (250)   NOT NULL,
    [SN]          INT              NOT NULL,
    [NEWSN]       NVARCHAR (50)    NULL,
    [NEWMODEL]    INT              NULL,
    [NEWREVISION] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_RESTRUCT_NEWMODEL] FOREIGN KEY ([NEWMODEL]) REFERENCES [dbo].[PR_MODELS] ([ID]),
    CONSTRAINT [FK_PR_RESTRUCT_NEWREVISION] FOREIGN KEY ([NEWREVISION]) REFERENCES [dbo].[PR_REVISION] ([ID]),
    CONSTRAINT [FK_PR_RESTRUCT_SN] FOREIGN KEY ([SN]) REFERENCES [dbo].[PR_DEVICE] ([ID])
);

