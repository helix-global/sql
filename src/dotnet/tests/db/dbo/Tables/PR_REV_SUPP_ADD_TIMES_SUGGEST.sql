CREATE TABLE [dbo].[PR_REV_SUPP_ADD_TIMES_SUGGEST] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [DEPID]        INT              NOT NULL,
    [DBEG]         DATETIME         NULL,
    [DEND]         DATETIME         NULL,
    [PERIODTYPE]   INT              NULL,
    [PERIODSTR]    NVARCHAR (100)   NULL,
    [PERIODSTR_OL] NVARCHAR (100)   NULL,
    [S_S]          INT              NULL,
    [NAME]         NVARCHAR (200)   NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_REV_SUPP_ADD_TIMES_SUGGEST_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

