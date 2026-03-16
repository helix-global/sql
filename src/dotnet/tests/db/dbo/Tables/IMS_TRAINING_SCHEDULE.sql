CREATE TABLE [dbo].[IMS_TRAINING_SCHEDULE] (
    [ID]                       INT              IDENTITY (1, 1) NOT NULL,
    [GID]                      UNIQUEIDENTIFIER NOT NULL,
    [S_S]                      INT              NOT NULL,
    [S_CR]                     INT              NOT NULL,
    [S_CDT]                    DATETIME         NOT NULL,
    [S_MR]                     INT              NULL,
    [S_MDT]                    DATETIME         NULL,
    [ARC]                      INT              NULL,
    [PLANID]                   INT              NOT NULL,
    [REMARK]                   NTEXT            NULL,
    [NAME]                     NVARCHAR (250)   NOT NULL,
    [TRLOCATION]               NVARCHAR (250)   NULL,
    [TRAINING_INSIDEDEP]       INT              NULL,
    [TRAINING_INSIDEDEP_BEGDT] DATETIME         NULL,
    [TRAINING_INSIDEDEP_ENDDT] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IMS_TRAINING_SCHEDULE_PLANID] FOREIGN KEY ([PLANID]) REFERENCES [dbo].[IMS_TRAINING_PLAN] ([ID])
);

