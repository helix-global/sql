CREATE TABLE [dbo].[IOE_PROGRESS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NOT NULL,
    [S_S]            INT              NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [EMPLID]         INT              NOT NULL,
    [TOPIC]          INT              NOT NULL,
    [PRDONE]         INT              NULL,
    [ANSWCOUNT]      INT              NULL,
    [TRAININGID]     INT              NOT NULL,
    [RATED]          INT              NULL,
    [RATINGCOMMENT]  NTEXT            NULL,
    [COMPLETEDD]     DATETIME         NULL,
    [KB3106NOTIFIED] DATETIME         NULL,
    [PRINTQTY]       INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IOE_PROGRESS_EMPLID] FOREIGN KEY ([EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_IOE_PROGRESS_TOPIC] FOREIGN KEY ([TOPIC]) REFERENCES [dbo].[IOE_TOPICS] ([ID]),
    CONSTRAINT [FK_IOE_PROGRESS_TRAININGID] FOREIGN KEY ([TRAININGID]) REFERENCES [dbo].[IOE_TRAINING] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IOE_PROGRESS_GID]
    ON [dbo].[IOE_PROGRESS]([GID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IOE_PROGRESS_EMPLID_S_S]
    ON [dbo].[IOE_PROGRESS]([EMPLID] ASC, [S_S] ASC);

