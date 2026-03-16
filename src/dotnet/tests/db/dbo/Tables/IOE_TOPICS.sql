CREATE TABLE [dbo].[IOE_TOPICS] (
    [ID]                      INT              IDENTITY (1, 1) NOT NULL,
    [GID]                     UNIQUEIDENTIFIER NOT NULL,
    [S_CR]                    INT              NOT NULL,
    [S_CDT]                   DATETIME         NOT NULL,
    [S_MR]                    INT              NULL,
    [S_MDT]                   DATETIME         NULL,
    [ARC]                     INT              NULL,
    [NAME]                    NVARCHAR (400)   NOT NULL,
    [DESCRIPTION]             NTEXT            NULL,
    [REMARK]                  NTEXT            NULL,
    [DEPID]                   INT              NOT NULL,
    [TOPICGR]                 INT              NOT NULL,
    [AVAILALL]                INT              NULL,
    [IMGFOLD]                 IMAGE            NULL,
    [ABOUTCOURSE]             NTEXT            NULL,
    [NANSW]                   INT              NULL,
    [ESTIMATTIME]             DECIMAL (10, 2)  NULL,
    [S_S]                     INT              NOT NULL,
    [EINZELNACHWEIS_REQUIRED] INT              NULL,
    [WORKSAFETY]              INT              NULL,
    [HAZARDOUSMAT]            INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IOE_TOPICS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_IOE_TOPICS_TOPICGR] FOREIGN KEY ([TOPICGR]) REFERENCES [dbo].[IOE_TOPIC_GROUPS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IOE_TOPICS_GID]
    ON [dbo].[IOE_TOPICS]([GID] ASC);

