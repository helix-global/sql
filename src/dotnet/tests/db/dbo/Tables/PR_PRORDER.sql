CREATE TABLE [dbo].[PR_PRORDER] (
    [ID]                        INT              IDENTITY (1, 1) NOT NULL,
    [GID]                       UNIQUEIDENTIFIER NULL,
    [S_CR]                      INT              NULL,
    [S_CDT]                     DATETIME         NULL,
    [S_MR]                      INT              NULL,
    [S_MDT]                     DATETIME         NULL,
    [S_S]                       INT              NULL,
    [NN]                        NVARCHAR (20)    NULL,
    [DD]                        DATETIME         NOT NULL,
    [URGENCY]                   INT              NOT NULL,
    [CUSTOMERID]                INT              NOT NULL,
    [ARC]                       INT              NULL,
    [DEPARTMENTID]              INT              NOT NULL,
    [ORDERTYPE]                 INT              NOT NULL,
    [EXPDATE]                   DATETIME         NULL,
    [HIDEORDERMODE]             INT              NULL,
    [NN2]                       NVARCHAR (50)    NULL,
    [SPREQ]                     NTEXT            NULL,
    [COMPLETED_DT]              DATETIME         NULL,
    [RUNLOG]                    NTEXT            NULL,
    [PARENTORDER]               INT              NULL,
    [NN3]                       NVARCHAR (50)    NULL,
    [SERVMAP]                   INT              NULL,
    [TESTORDER]                 INT              NULL,
    [CDD]                       DATETIME         NULL,
    [INTREFERENCE]              NVARCHAR (50)    NULL,
    [APPLICATION]               NVARCHAR (255)   NULL,
    [FROMDEPID]                 INT              NULL,
    [PLACEDSETTINGID]           INT              NULL,
    [OUT2NAVGID]                NVARCHAR (50)    NULL,
    [RMAREQUESTID]              INT              NULL,
    [temp_olddep]               INT              NULL,
    [CREATED_BY_SUPPLY]         INT              NULL,
    [INTWASREQUESTEDINNAV]      INT              NULL,
    [SERV_ORDER_IN_PROGRESS_DT] DATETIME         NULL,
    [AUTOLOADED]                DATETIME         NULL,
    [SETMODELID]                INT              NULL,
    [SETREVID]                  INT              NULL,
    [REMARK]                    NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PR_PRORDER_CUSTOMERID] FOREIGN KEY ([CUSTOMERID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_PR_PRORDER_DEPARTMENTID] FOREIGN KEY ([DEPARTMENTID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_PRORDER_FROMDEPID] FOREIGN KEY ([FROMDEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_PRORDER_PARENTORDER] FOREIGN KEY ([PARENTORDER]) REFERENCES [dbo].[PR_PRORDER] ([ID]),
    CONSTRAINT [FK_PR_PRORDER_SERVMAP] FOREIGN KEY ([SERVMAP]) REFERENCES [dbo].[PR_MAP] ([ID]),
    CONSTRAINT [FK_PR_PRORDER_SETMODELID] FOREIGN KEY ([SETMODELID]) REFERENCES [dbo].[PR_MODELS] ([ID]),
    CONSTRAINT [FK_PR_PRORDER_SETREVID] FOREIGN KEY ([SETREVID]) REFERENCES [dbo].[PR_REVISION] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_PRORDER_RMAREQUESTID]
    ON [dbo].[PR_PRORDER]([RMAREQUESTID] ASC) WHERE ([RMAREQUESTID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_PR_PRORDER_PARENTORDER]
    ON [dbo].[PR_PRORDER]([PARENTORDER] ASC) WHERE ([PARENTORDER] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_PR_PRORDER_OUT2NAVGID]
    ON [dbo].[PR_PRORDER]([OUT2NAVGID] ASC) WHERE ([OUT2NAVGID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_PR_PRORDER_DEPARTMENTID_ID]
    ON [dbo].[PR_PRORDER]([DEPARTMENTID] ASC)
    INCLUDE([ID]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_PRORDER_2]
    ON [dbo].[PR_PRORDER]([DEPARTMENTID] ASC, [ORDERTYPE] ASC, [S_S] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_PRORDER]
    ON [dbo].[PR_PRORDER]([DEPARTMENTID] ASC, [NN] ASC) WHERE ([NN] IS NOT NULL) WITH (FILLFACTOR = 90);

