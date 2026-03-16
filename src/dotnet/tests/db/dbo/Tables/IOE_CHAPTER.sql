CREATE TABLE [dbo].[IOE_CHAPTER] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NOT NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [NAME]          NVARCHAR (400)   NOT NULL,
    [DESCRIPTION]   NTEXT            NULL,
    [TOPICID]       INT              NOT NULL,
    [REMARK]        NTEXT            NULL,
    [NASK]          INT              NULL,
    [NANSW]         INT              NULL,
    [POSORDER]      INT              NULL,
    [CHAPTERTYPE]   INT              NOT NULL,
    [CHTEXT]        NTEXT            NULL,
    [S_S]           INT              NOT NULL,
    [DEPRECATED_DT] DATETIME         NULL,
    [CODE]          NVARCHAR (50)    NOT NULL,
    [REVN]          INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IOE_CHAPTER_TOPICID] FOREIGN KEY ([TOPICID]) REFERENCES [dbo].[IOE_TOPICS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IOE_CHAPTER_GID]
    ON [dbo].[IOE_CHAPTER]([GID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IOE_CHAPTER_CODE_REVN]
    ON [dbo].[IOE_CHAPTER]([CODE] ASC, [REVN] ASC);

