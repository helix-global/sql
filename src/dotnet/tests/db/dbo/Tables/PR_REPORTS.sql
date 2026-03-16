CREATE TABLE [dbo].[PR_REPORTS] (
    [ID]                       INT              IDENTITY (1, 1) NOT NULL,
    [GID]                      UNIQUEIDENTIFIER NULL,
    [S_S]                      INT              NOT NULL,
    [S_CR]                     INT              NOT NULL,
    [S_CDT]                    DATETIME         NOT NULL,
    [S_MR]                     INT              NULL,
    [S_MDT]                    DATETIME         NULL,
    [ARC]                      INT              NULL,
    [DESCRIPTION]              NTEXT            NULL,
    [REPORT]                   NTEXT            NULL,
    [NAME]                     NVARCHAR (100)   NOT NULL,
    [MTID]                     INT              NOT NULL,
    [USE_DEV_READY]            INT              NULL,
    [USE_DEV_PROD]             INT              NULL,
    [USE_OPER_ALL]             INT              NULL,
    [USE_OPER_ONE]             INT              NULL,
    [USE_OPER_PRD]             INT              NULL,
    [REPFILENAME]              NVARCHAR (200)   NULL,
    [USE_IN_ASSEMBLY]          INT              NULL,
    [SHOW_ONLY_CMPL]           INT              NULL,
    [CODE]                     NVARCHAR (50)    NOT NULL,
    [REVN]                     INT              NOT NULL,
    [USE_DEV_LIST]             INT              NULL,
    [SIZEMODE]                 INT              NULL,
    [CUSTOMWIDTH]              DECIMAL (12, 1)  NULL,
    [CUSTOMHEIGHT]             DECIMAL (12, 1)  NULL,
    [OLDCODE]                  NVARCHAR (50)    NULL,
    [SHOW_ONLY_INPROGRESS]     INT              NULL,
    [HIDEINSNINFO]             INT              NULL,
    [DEPID]                    INT              NOT NULL,
    [USE_OPER_LIST]            INT              NULL,
    [CUSTOMLEFTM]              DECIMAL (12, 1)  NULL,
    [CUSTOMTOPM]               DECIMAL (12, 1)  NULL,
    [LINKTOPRMID]              INT              NULL,
    [FULLMT]                   INT              NULL,
    [EXECUTIONMODE]            INT              NULL,
    [USE_FAR]                  INT              NULL,
    [VISIBILITY_FOR_CUSTOMERS] INT              NULL,
    [VISIBILITY_FOR_OPTIONS]   INT              NULL,
    [USE_ONLYINDEP]            INT              NULL,
    [PRINTSPECIALFORMS]        INT              NULL,
    [USEINEQUIPMENT]           INT              NULL,
    [DONOTPRINTQTY]            INT              NULL,
    [LINKTOPRMID_AUTORUN]      INT              NULL,
    [MULTBYQTY]                INT              NULL,
    [PRINT_COUNT]              INT              NULL,
    [OPTIONS]                  NVARCHAR (1024)  NULL,
    [USE_REV_LIST]             INT              DEFAULT ((0)) NULL,
    [REMARK]                   NTEXT            NULL,
    CONSTRAINT [PK__PR_REPOR__3214EC27711DBAFA] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PR_REPORTS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_REPORTS_LINKTOPRMID] FOREIGN KEY ([LINKTOPRMID]) REFERENCES [dbo].[PR_MODELTYPE_PARAMS] ([ID]),
    CONSTRAINT [FK_PR_REPORTS_USE_ONLYINDEP] FOREIGN KEY ([USE_ONLYINDEP]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_REPORTS_USE_OPER_ONE] FOREIGN KEY ([USE_OPER_ONE]) REFERENCES [dbo].[PR_OPERATIONS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REPORTS_S_S_USE_OPER_ONE]
    ON [dbo].[PR_REPORTS]([S_S] ASC, [USE_OPER_ONE] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REPORTS_MTID_S_S_2]
    ON [dbo].[PR_REPORTS]([MTID] ASC, [S_S] ASC, [USE_DEV_LIST] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REPORTS_MTID_S_S]
    ON [dbo].[PR_REPORTS]([MTID] ASC, [S_S] ASC, [USE_OPER_LIST] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REPORTS_MTID_3]
    ON [dbo].[PR_REPORTS]([MTID] ASC, [S_S] ASC)
    INCLUDE([USE_OPER_LIST], [USE_DEV_PROD], [USE_DEV_READY], [USE_OPER_ALL], [USE_OPER_ONE], [FULLMT]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REPORTS_LINKTOPRMID]
    ON [dbo].[PR_REPORTS]([LINKTOPRMID] ASC) WHERE ([LINKTOPRMID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_REPORTS_GID]
    ON [dbo].[PR_REPORTS]([GID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_REPORTS_CODE]
    ON [dbo].[PR_REPORTS]([CODE] ASC, [REVN] ASC) WITH (FILLFACTOR = 90);

