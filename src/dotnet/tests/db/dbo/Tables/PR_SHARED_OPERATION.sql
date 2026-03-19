CREATE TABLE [dbo].[PR_SHARED_OPERATION] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_S]       INT              NOT NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [FROMDEPID] INT              NOT NULL,
    [TODEPID]   INT              NOT NULL,
    [DD]        DATETIME         NOT NULL,
    [EXP_DATE]  DATETIME         NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_SHARED_OPERATION_FROMDEPID] FOREIGN KEY ([FROMDEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_SHARED_OPERATION_TODEPID] FOREIGN KEY ([TODEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

