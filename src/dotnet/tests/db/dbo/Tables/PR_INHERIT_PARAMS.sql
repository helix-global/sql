CREATE TABLE [dbo].[PR_INHERIT_PARAMS] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [MODELID] INT              NULL,
    [REMARK]  NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_INHERIT_PARAMS_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);

