CREATE TABLE [dbo].[DEF_HISTORY] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [NN]       INT              NOT NULL,
    [DD]       DATETIME         NOT NULL,
    [XMLPACK]  NTEXT            NULL,
    [OBJCLASS] INT              NOT NULL,
    [OBJOID]   INT              NOT NULL,
    [OBJNAME]  NVARCHAR (200)   NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_HISTORY_OBJCLASS] FOREIGN KEY ([OBJCLASS]) REFERENCES [dbo].[DEF_CLASSES] ([ID])
);

