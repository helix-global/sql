CREATE TABLE [dbo].[SL_QUOTE3_TO] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [OPOSID]   INT              NOT NULL,
    [OPTID]    INT              NOT NULL,
    [QUANTITY] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_QUOTE3_TO_OPOSID] FOREIGN KEY ([OPOSID]) REFERENCES [dbo].[SL_QUOTE3_T] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SL_QUOTE3_TO]
    ON [dbo].[SL_QUOTE3_TO]([OPOSID] ASC);

