CREATE TABLE [dbo].[MSG_WAIT_DOCS] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [DOCOID]        INT            NOT NULL,
    [DOCID]         INT            NOT NULL,
    [SENDINGOID]    INT            NOT NULL,
    [SUBJ]          NVARCHAR (255) NOT NULL,
    [LAST_MDT]      DATETIME       NULL,
    [LAST_MR]       INT            NULL,
    [DEPID]         INT            NOT NULL,
    [S_S]           INT            NOT NULL,
    [S_CR]          INT            NULL,
    [S_CDT]         DATETIME       NULL,
    [EXPIREDDATE]   DATETIME       NOT NULL,
    [DELAYED_UNTIL] DATETIME       NULL,
    CONSTRAINT [PK_MSG_WAIT_DOCS] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_WAIT_DOCS_EXPIREDDATE]
    ON [dbo].[MSG_WAIT_DOCS]([EXPIREDDATE] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MSG_WAIT_DOCS_1]
    ON [dbo].[MSG_WAIT_DOCS]([DOCOID] ASC, [DOCID] ASC);

