CREATE TABLE [dbo].[FC_REPORT] (
    [ID]                            INT              IDENTITY (1, 1) NOT NULL,
    [GID]                           UNIQUEIDENTIFIER NULL,
    [S_S]                           INT              NOT NULL,
    [S_CR]                          INT              NOT NULL,
    [S_CDT]                         DATETIME         NOT NULL,
    [S_MR]                          INT              NULL,
    [S_MDT]                         DATETIME         NULL,
    [ARC]                           INT              NULL,
    [PARENTID]                      INT              NULL,
    [FAILUREDATE]                   DATETIME         NOT NULL,
    [WARRANTY]                      INT              NULL,
    [RMA_TYPE]                      INT              NULL,
    [RMA]                           NVARCHAR (40)    NULL,
    [OTHERRMA]                      NVARCHAR (40)    NULL,
    [FROMDEPID]                     INT              NULL,
    [FROMCUSTOMERID]                INT              NULL,
    [DEVICEID]                      INT              NULL,
    [QUANTITY]                      DECIMAL (10, 2)  NULL,
    [OPERTIME]                      DECIMAL (12, 1)  NULL,
    [FAILUREDESCRIPTION]            NVARCHAR (2048)  NULL,
    [REQUESTEDACTIONS]              INT              NULL,
    [RESULT_INC_INSP]               NVARCHAR (1000)  NULL,
    [FAILURE_ANALYSIS]              NVARCHAR (2000)  NULL,
    [CORRECTIVE_ACTION]             NVARCHAR (1000)  NULL,
    [CORR_ACTION_DATE]              DATETIME         NULL,
    [ACTIONPOINTS]                  NVARCHAR (1000)  NULL,
    [WARRANTYREPAIR]                INT              NULL,
    [REMARK]                        NTEXT            NULL,
    [INTERNALREMARK]                NTEXT            NULL,
    [MODELID]                       INT              NOT NULL,
    [SN]                            NVARCHAR (50)    NOT NULL,
    [INT_EXT]                       INT              NULL,
    [REPAIRDATE]                    DATETIME         NULL,
    [USER2ID]                       INT              NULL,
    [USER2DT]                       DATETIME         NULL,
    [USER3ID]                       INT              NULL,
    [USER3DT]                       DATETIME         NULL,
    [OFFICEID]                      INT              NULL,
    [USER1DT]                       DATETIME         NULL,
    [USER4DT]                       DATETIME         NULL,
    [USER4ID]                       INT              NULL,
    [CUSTOMFORMID]                  INT              NULL,
    [FRNUM]                         NVARCHAR (30)    NULL,
    [FRNUMN]                        INT              NULL,
    [TOTROUBLEID]                   INT              NULL,
    [NORETURN]                      INT              NULL,
    [DATE_PRODUCT3]                 DATETIME         NULL,
    [CUSTREF]                       NVARCHAR (50)    NULL,
    [CUSTOMANALYSISFORMID]          INT              NULL,
    [APPRCOUNT]                     INT              NULL,
    [NOTIFICATION_MARK]             DATETIME         NULL,
    [BATCHN]                        NVARCHAR (100)   NULL,
    [AREMARK]                       NTEXT            NULL,
    [NOTIFICATION_IS_SENT]          INT              NULL,
    [NOTIFICATION_APPROVAL_IS_SENT] INT              NULL,
    [WASPARENTIDINSOURCEDB]         INT              NULL,
    [EXTPARENTID]                   INT              NULL,
    [EXTREQDEPID]                   INT              NULL,
    [SERVORDERID]                   INT              NULL,
    [CUSTOMER_REMARK]               NTEXT            NULL,
    [OPERFAILED]                    INT              NULL,
    [OPEROPERATOR]                  INT              NULL,
    [OPEROPERATORMI]                INT              NULL,
    [DONT_REQUEST_OPER_FEEDBACK]    INT              NULL,
    [CRM_REPORT_OWNER_NAME]         NVARCHAR (250)   NULL,
    CONSTRAINT [PK__FC_MASTE__3214EC270C26B6F1] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FC_MASTERFAILURE_DEVICEID] FOREIGN KEY ([DEVICEID]) REFERENCES [dbo].[PR_DEVICE] ([ID]),
    CONSTRAINT [FK_FC_MASTERFAILURE_FROMCUSTOMERID] FOREIGN KEY ([FROMCUSTOMERID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_FC_MASTERFAILURE_FROMDEPARTID] FOREIGN KEY ([FROMDEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_FC_MASTERFAILURE_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID]),
    CONSTRAINT [FK_FC_MASTERFAILURE_PARENTID] FOREIGN KEY ([PARENTID]) REFERENCES [dbo].[FC_REPORT] ([ID]),
    CONSTRAINT [FK_FC_REPORT_CUSTOMANALYSISFORMID] FOREIGN KEY ([CUSTOMANALYSISFORMID]) REFERENCES [dbo].[FC_FORMS_HISTORY] ([ID]),
    CONSTRAINT [FK_FC_REPORT_CUSTOMFORMID] FOREIGN KEY ([CUSTOMFORMID]) REFERENCES [dbo].[FC_FORMS_HISTORY] ([ID]),
    CONSTRAINT [FK_FC_REPORT_EXTPARENTID] FOREIGN KEY ([EXTPARENTID]) REFERENCES [dbo].[FC_REPORT] ([ID]),
    CONSTRAINT [FK_FC_REPORT_EXTREQDEPID] FOREIGN KEY ([EXTREQDEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_FC_REPORT_OFFICEID] FOREIGN KEY ([OFFICEID]) REFERENCES [dbo].[FC_OFFICE] ([ID]),
    CONSTRAINT [FK_FC_REPORT_OPERFAILED] FOREIGN KEY ([OPERFAILED]) REFERENCES [dbo].[PR_OPERATION] ([ID]),
    CONSTRAINT [FK_FC_REPORT_OPEROPERATOR] FOREIGN KEY ([OPEROPERATOR]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_FC_REPORT_USER2ID] FOREIGN KEY ([USER2ID]) REFERENCES [dbo].[DEF_USERS] ([ID]),
    CONSTRAINT [FK_FC_REPORT_USER4ID] FOREIGN KEY ([USER4ID]) REFERENCES [dbo].[DEF_USERS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_TOTROUBLEID]
    ON [dbo].[FC_REPORT]([TOTROUBLEID] ASC) WHERE ([TOTROUBLEID] IS NOT NULL) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_S_S]
    ON [dbo].[FC_REPORT]([S_S] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_S_CDT]
    ON [dbo].[FC_REPORT]([S_CR] ASC, [S_CDT] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_OPEROPERATOR]
    ON [dbo].[FC_REPORT]([OPEROPERATOR] ASC) WHERE ([OPEROPERATOR] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_OPERFAILED]
    ON [dbo].[FC_REPORT]([OPERFAILED] ASC) WHERE ([OPERFAILED] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_MODELID_SN]
    ON [dbo].[FC_REPORT]([MODELID] ASC, [SN] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_MODELID]
    ON [dbo].[FC_REPORT]([MODELID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FC_REPORT_GID]
    ON [dbo].[FC_REPORT]([GID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_FROMDEPID]
    ON [dbo].[FC_REPORT]([FROMDEPID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_EXTREQDEPID]
    ON [dbo].[FC_REPORT]([EXTREQDEPID] ASC) WHERE ([EXTREQDEPID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_EXTPARENTID]
    ON [dbo].[FC_REPORT]([EXTPARENTID] ASC) WHERE ([EXTPARENTID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_DEVICEID]
    ON [dbo].[FC_REPORT]([DEVICEID] ASC) WHERE ([DEVICEID] IS NOT NULL) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_DD]
    ON [dbo].[FC_REPORT]([FAILUREDATE] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT]
    ON [dbo].[FC_REPORT]([PARENTID] ASC) WHERE ([PARENTID] IS NOT NULL) WITH (FILLFACTOR = 90);

