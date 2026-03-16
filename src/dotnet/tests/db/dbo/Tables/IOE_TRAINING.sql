CREATE TABLE [dbo].[IOE_TRAINING] (
    [ID]                  INT              IDENTITY (1, 1) NOT NULL,
    [GID]                 UNIQUEIDENTIFIER NOT NULL,
    [S_CR]                INT              NOT NULL,
    [S_CDT]               DATETIME         NOT NULL,
    [S_MR]                INT              NULL,
    [S_MDT]               DATETIME         NULL,
    [ARC]                 INT              NULL,
    [DEPID]               INT              NOT NULL,
    [TOPICID]             INT              NOT NULL,
    [EXPIREDDD]           DATE             NULL,
    [REMARK]              NTEXT            NULL,
    [DD]                  DATE             NOT NULL,
    [S_S]                 INT              NOT NULL,
    [KB5343_LASTNOTIFIED] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IOE_TRAINING_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_IOE_TRAINING_TOPICID] FOREIGN KEY ([TOPICID]) REFERENCES [dbo].[IOE_TOPICS] ([ID])
);

