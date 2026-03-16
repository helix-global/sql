CREATE TABLE [dbo].[PR_REV_ADD_TIMES] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [ADDVALUE]      DECIMAL (16, 4)  NOT NULL,
    [REMARK]        NVARCHAR (200)   NULL,
    [REVID]         INT              NOT NULL,
    [PRODSUPPORT]   INT              NULL,
    [MAPOPERID]     INT              NOT NULL,
    [NAVCODE]       NVARCHAR (20)    NOT NULL,
    [QUALIFICATION] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_REV_ADD_TIMES_MAPOPERID] FOREIGN KEY ([MAPOPERID]) REFERENCES [dbo].[PR_MAP_OPER] ([ID]),
    CONSTRAINT [FK_PR_REV_ADD_TIMES_REVID] FOREIGN KEY ([REVID]) REFERENCES [dbo].[PR_REVISION] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REV_ADD_TIMES_REVID_MAPOPERID]
    ON [dbo].[PR_REV_ADD_TIMES]([REVID] ASC, [MAPOPERID] ASC);

