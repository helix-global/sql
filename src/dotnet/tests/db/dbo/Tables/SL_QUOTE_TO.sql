CREATE TABLE [dbo].[SL_QUOTE_TO] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [OPID]      INT              NOT NULL,
    [OPTID]     INT              NOT NULL,
    [QUANTITY]  INT              NULL,
    [NAVLINENO] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_QUOTE_TO_OPID] FOREIGN KEY ([OPID]) REFERENCES [dbo].[SL_QUOTE] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SL_QUOTE_TO]
    ON [dbo].[SL_QUOTE_TO]([OPID] ASC);

