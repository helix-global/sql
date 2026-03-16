CREATE TABLE [dbo].[PR_REV_REPORTS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [REVID]       INT              NOT NULL,
    [DESCRIPTION] NTEXT            NULL,
    [REPORT]      NTEXT            NULL,
    [NAME]        NVARCHAR (100)   NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_REV_REPORTS_REVID] FOREIGN KEY ([REVID]) REFERENCES [dbo].[PR_REVISION] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REV_REPORTS]
    ON [dbo].[PR_REV_REPORTS]([REVID] ASC);

