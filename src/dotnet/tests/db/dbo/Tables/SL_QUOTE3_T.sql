CREATE TABLE [dbo].[SL_QUOTE3_T] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [VNESHID]  INT              NOT NULL,
    [MODELID]  INT              NOT NULL,
    [QUANTITY] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_QUOTE3_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[SL_QUOTE3] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SL_QUOTE3_T]
    ON [dbo].[SL_QUOTE3_T]([VNESHID] ASC);

