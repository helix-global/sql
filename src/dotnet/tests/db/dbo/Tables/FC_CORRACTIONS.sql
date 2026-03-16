CREATE TABLE [dbo].[FC_CORRACTIONS] (
    [ID]                       INT              IDENTITY (1, 1) NOT NULL,
    [GID]                      UNIQUEIDENTIFIER NULL,
    [S_S]                      INT              NOT NULL,
    [S_CR]                     INT              NOT NULL,
    [S_CDT]                    DATETIME         NOT NULL,
    [S_MR]                     INT              NULL,
    [S_MDT]                    DATETIME         NULL,
    [ARC]                      INT              NULL,
    [DEPID]                    INT              NOT NULL,
    [DBEG]                     DATETIME         NOT NULL,
    [ANALYSISCODEID]           INT              NOT NULL,
    [DESCR]                    NTEXT            NOT NULL,
    [PDATE]                    DATETIME         NOT NULL,
    [EFFICIENCY]               INT              NOT NULL,
    [REMARK]                   NTEXT            NULL,
    [IDATE]                    DATETIME         NOT NULL,
    [FINISHED_DT]              DATETIME         NULL,
    [FINISHED_DATA]            NTEXT            NULL,
    [FAILURE_CODE]             INT              NULL,
    [OPERID]                   INT              NULL,
    [PERIODTYPE]               INT              NULL,
    [NOTIFICATION_BEFORE_CD]   INT              NULL,
    [NOTIFICATION_BEFORE_RATE] INT              NULL,
    [NOTIFICATION_AFTER_CD]    INT              NULL,
    [NOTIFICATION_AFTER_RATE]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_CORRACTIONS_ANALYSISCODEID] FOREIGN KEY ([ANALYSISCODEID]) REFERENCES [dbo].[FC_FAILUREANALYSISCODES] ([ID]),
    CONSTRAINT [FK_FC_CORRACTIONS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_FC_CORRACTIONS_FAILURE_CODE] FOREIGN KEY ([FAILURE_CODE]) REFERENCES [dbo].[FC_FAILURECODES] ([ID]),
    CONSTRAINT [FK_FC_CORRACTIONS_OPERID] FOREIGN KEY ([OPERID]) REFERENCES [dbo].[PR_OPERATIONS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_CORRACTIONS_DEPID]
    ON [dbo].[FC_CORRACTIONS]([DEPID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FC_CORRACTIONS_ACODE]
    ON [dbo].[FC_CORRACTIONS]([ANALYSISCODEID] ASC);

