CREATE TABLE [dbo].[IOE_PROGRESS_T] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NOT NULL,
    [S_S]              INT              NOT NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [VNESHID]          INT              NOT NULL,
    [QASKED]           INT              NULL,
    [CHAPTERID]        INT              NOT NULL,
    [EMPLHASQUESTIONS] INT              NULL,
    [EMPLQUESTION]     NTEXT            NULL,
    [WRONGANSWERS]     INT              NULL,
    [QUESTIONWASSENT]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IOE_PROGRESS_T_CHAPTERID] FOREIGN KEY ([CHAPTERID]) REFERENCES [dbo].[IOE_CHAPTER] ([ID]),
    CONSTRAINT [FK_IOE_PROGRESS_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[IOE_PROGRESS] ([ID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IOE_PROGRESS_T_UNI]
    ON [dbo].[IOE_PROGRESS_T]([VNESHID] ASC, [CHAPTERID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IOE_PROGRESS_T]
    ON [dbo].[IOE_PROGRESS_T]([VNESHID] ASC);

