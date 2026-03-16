CREATE TABLE [dbo].[PR_FP_PLANNING_OPERSETTINGS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_S]        INT              NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [OPERFORMID] INT              NOT NULL,
    [OPERTYPE]   INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_FP_PLANNING_OPERSETTINGS_OPERFORMID] FOREIGN KEY ([OPERFORMID]) REFERENCES [dbo].[PR_OPERATIONS] ([ID])
);

