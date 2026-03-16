CREATE TABLE [dbo].[MNT_PLAN] (
    [ID]                       INT              IDENTITY (1, 1) NOT NULL,
    [GID]                      UNIQUEIDENTIFIER NULL,
    [S_S]                      INT              NOT NULL,
    [S_CR]                     INT              NOT NULL,
    [S_CDT]                    DATETIME         NOT NULL,
    [S_MR]                     INT              NULL,
    [S_MDT]                    DATETIME         NULL,
    [ARC]                      INT              NULL,
    [DEPID]                    INT              NOT NULL,
    [OPERID]                   INT              NOT NULL,
    [DBEG]                     DATETIME         NOT NULL,
    [SPERIOD]                  INT              NOT NULL,
    [HP_DAY]                   INT              NULL,
    [HP_HOUR]                  INT              NULL,
    [HP_MINUTE]                INT              NULL,
    [CRMODE]                   INT              NOT NULL,
    [TODO]                     NTEXT            NULL,
    [NEXTDATE]                 DATETIME         NULL,
    [LASTDATE]                 DATETIME         NULL,
    [SHIFTFROMLASTDATE]        INT              NULL,
    [NOTIFICATIONP]            INT              NULL,
    [REMARK]                   NTEXT            NULL,
    [NOTIFICATIONEXP]          INT              NULL,
    [NOTIFICATIONP_EVRDAY]     INT              NULL,
    [NOTIFICATIONEXP_EVRDAY]   INT              NULL,
    [WEEKLY_ONLY]              INT              NULL,
    [EQINNOTIFICATION]         INT              NULL,
    [SHIFTFROMLASTCMPLDATE]    INT              NULL,
    [SHIFTHMODE]               INT              NULL,
    [WORKCYCLES]               INT              NULL,
    [NOTIFICATIONP_WORKCYCLES] INT              NULL,
    [EXEC_EQ_STATES]           INT              NULL,
    [CHECKPREVIOUSCOMPLETED]   INT              DEFAULT ((1)) NULL,
    [COMB_PLANID]              INT              NULL,
    [NEXTDATE_SHIFT_MODE]      INT              DEFAULT ((0)) NULL,
    [NOTIFICATIONP_DAYS]       INT              NULL,
    [NOTIFICATIONEXP_DAYS]     INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MNT_PLAN_COMB_PLANID] FOREIGN KEY ([COMB_PLANID]) REFERENCES [dbo].[MNT_PLAN] ([ID]),
    CONSTRAINT [FK_MNT_PLAN_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_MNT_PLAN_OPERID] FOREIGN KEY ([OPERID]) REFERENCES [dbo].[PR_OPERATIONS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_MNT_PLAN_S_S_SPERIOD_CRMODE_ID_WORKCYCLES]
    ON [dbo].[MNT_PLAN]([S_S] ASC, [SPERIOD] ASC, [CRMODE] ASC)
    INCLUDE([ID], [WORKCYCLES]);


GO
CREATE NONCLUSTERED INDEX [IX_MNT_PLAN_S_S_NEXTDATE_CRMODE]
    ON [dbo].[MNT_PLAN]([S_S] ASC, [NEXTDATE] ASC, [CRMODE] ASC);

