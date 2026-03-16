CREATE TABLE [dbo].[IMS_DEP_SCHEDULE] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_S]        INT              NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [SCHEDULEID] INT              NOT NULL,
    [DEPID]      INT              NOT NULL,
    [REMARK]     NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IMS_DEP_SCHEDULE_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_IMS_DEP_SCHEDULE_SCHEDULEID] FOREIGN KEY ([SCHEDULEID]) REFERENCES [dbo].[IMS_TRAINING_SCHEDULE] ([ID])
);

