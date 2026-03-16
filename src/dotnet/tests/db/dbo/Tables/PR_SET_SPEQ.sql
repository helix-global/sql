CREATE TABLE [dbo].[PR_SET_SPEQ] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_S]      INT              NOT NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [REVID]    INT              NOT NULL,
    [REMARK]   NTEXT            NULL,
    [SPFORMID] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_SET_SPEQ_REVID] FOREIGN KEY ([REVID]) REFERENCES [dbo].[PR_REVISION] ([ID]),
    CONSTRAINT [FK_PR_SET_SPEQ_SPFORMID] FOREIGN KEY ([SPFORMID]) REFERENCES [dbo].[PR_SP_FORMS] ([ID])
);

