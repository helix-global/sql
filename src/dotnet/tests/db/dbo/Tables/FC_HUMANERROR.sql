CREATE TABLE [dbo].[FC_HUMANERROR] (
    [ID]                        INT              IDENTITY (1, 1) NOT NULL,
    [GID]                       UNIQUEIDENTIFIER NULL,
    [S_S]                       INT              NOT NULL,
    [S_CR]                      INT              NOT NULL,
    [S_CDT]                     DATETIME         NOT NULL,
    [S_MR]                      INT              NULL,
    [S_MDT]                     DATETIME         NULL,
    [ARC]                       INT              NULL,
    [DD]                        DATETIME         NOT NULL,
    [FAILUREDESCRIPTION]        NVARCHAR (1000)  NOT NULL,
    [CORRECTIVE_ACTION]         NVARCHAR (1000)  NULL,
    [CORR_ACTION_DATE]          DATETIME         NULL,
    [FAILURE_ANALYSIS]          NVARCHAR (1000)  NULL,
    [EMPLID]                    INT              NULL,
    [REPORTID]                  INT              NOT NULL,
    [UNKNOWNEMPL]               INT              NULL,
    [DEPID]                     INT              NOT NULL,
    [HECODEID]                  INT              NULL,
    [OPERATOR_REPLY]            NVARCHAR (1000)  NULL,
    [LAST_OPER_FEEDBACK_MSG_DT] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_HUMANERROR_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_FC_HUMANERROR_EMPLID] FOREIGN KEY ([EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_FC_HUMANERROR_HECODEID] FOREIGN KEY ([HECODEID]) REFERENCES [dbo].[FC_HUMANERRORCODES] ([ID]),
    CONSTRAINT [FK_FC_HUMANERROR_REPORTID] FOREIGN KEY ([REPORTID]) REFERENCES [dbo].[FC_REPORT] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_HUMANERROR_REPORTID]
    ON [dbo].[FC_HUMANERROR]([REPORTID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FC_HUMANERROR_HECODEID]
    ON [dbo].[FC_HUMANERROR]([HECODEID] ASC) WHERE ([HECODEID] IS NOT NULL);

