CREATE TABLE [dbo].[IMS_TRAINING_PLAN] (
    [ID]                INT              IDENTITY (1, 1) NOT NULL,
    [GID]               UNIQUEIDENTIFIER NOT NULL,
    [S_CR]              INT              NOT NULL,
    [S_CDT]             DATETIME         NOT NULL,
    [S_MR]              INT              NULL,
    [S_MDT]             DATETIME         NULL,
    [ARC]               INT              NULL,
    [TRTYPEID]          INT              NOT NULL,
    [SNOOZEPERIOD]      INT              NOT NULL,
    [SNOOZEPERIODVALUE] INT              NULL,
    [REMARK]            NTEXT            NULL,
    [SENDNOTYF]         INT              NULL,
    [NAME]              NVARCHAR (250)   NOT NULL,
    [LASTNOTIFYDD]      DATE             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IMS_TRAINING_PLAN_TRTYPEID] FOREIGN KEY ([TRTYPEID]) REFERENCES [dbo].[IMS_TRAINING_TYPE] ([ID])
);

