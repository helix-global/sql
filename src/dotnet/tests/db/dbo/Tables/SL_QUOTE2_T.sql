CREATE TABLE [dbo].[SL_QUOTE2_T] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [VNESHID]   INT              NOT NULL,
    [MODELID]   INT              NOT NULL,
    [QUANTITY]  INT              NOT NULL,
    [NAVLINENO] INT              NULL,
    [WARRANTY]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_QUOTE2_T_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID]),
    CONSTRAINT [FK_SL_QUOTE2_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[SL_QUOTE2] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SL_QUOTE2_T]
    ON [dbo].[SL_QUOTE2_T]([VNESHID] ASC);

