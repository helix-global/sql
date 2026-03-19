CREATE TABLE [dbo].[PR_MODELTYPE] (
    [ID]                      INT              IDENTITY (1, 1) NOT NULL,
    [GID]                     UNIQUEIDENTIFIER NULL,
    [S_CR]                    INT              NULL,
    [S_CDT]                   DATETIME         NULL,
    [S_MR]                    INT              NULL,
    [S_MDT]                   DATETIME         NULL,
    [NAME]                    NVARCHAR (300)   NOT NULL,
    [DESCRIPTION]             NTEXT            NULL,
    [DEPARTMENTID]            INT              NOT NULL,
    [SNMASK]                  NVARCHAR (100)   NULL,
    [ARC]                     INT              NULL,
    [SNPMODE]                 INT              NULL,
    [SNPRM]                   NVARCHAR (50)    NULL,
    [SNPMASK]                 NVARCHAR (50)    NULL,
    [ACCMODE]                 INT              NOT NULL,
    [PRINT_EXP]               INT              NULL,
    [SNUNIQUE]                INT              NULL,
    [BACKUP_PATH]             NVARCHAR (250)   NULL,
    [BACKUP_MODE]             INT              NULL,
    [BACKUP_LANG]             INT              NULL,
    [FRA_MODE]                INT              NULL,
    [MPICT]                   IMAGE            NULL,
    [ENDLEV]                  INT              NULL,
    [ALLOWFREEREPAIR]         INT              NULL,
    [ALLOWFULLRESTART]        INT              NULL,
    [REPAIRABLE]              INT              NULL,
    [PRINT_ONEL]              INT              NULL,
    [PRINTLABELKIND]          INT              NULL,
    [OPERCRMODE]              INT              NULL,
    [STATEXCLUDE]             INT              NULL,
    [PRINT_CUST]              INT              NULL,
    [SNP4MTYPE]               INT              NULL,
    [STOCKPARAM]              NVARCHAR (300)   NULL,
    [BLOCKBYCOMPATIPRMS]      INT              NULL,
    [ALLOWUSEINPRODUCTION]    INT              NULL,
    [NAVQTY_TRANS]            INT              NULL,
    [PRINTED_DOC_REQUIRED]    INT              NULL,
    [SHOWORDFILESINOPER]      INT              NULL,
    [DONOTCREATESUPPLYORD]    INT              NULL,
    [SNPMIN]                  INT              NULL,
    [ALLOWUSEINPRODUCTIONCMP] INT              NULL,
    [MULTREVADDTIMES]         INT              NULL,
    [BQNOTIFY]                INT              NULL,
    [UPDOPERQTYFROMITEM]      INT              NULL,
    [USEREMARKFROMORDER]      INT              NULL,
    [APPROVALONLYBYPLM]       INT              NULL,
    [QTY_MULTIPLIER_PARAMID]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_MODELTYPE_DEPARTMENTID] FOREIGN KEY ([DEPARTMENTID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_MODELTYPE_QTY_MULTIPLIER_PARAMID] FOREIGN KEY ([QTY_MULTIPLIER_PARAMID]) REFERENCES [dbo].[PR_MODELTYPE_PARAMS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_MODELTYPE_NAME]
    ON [dbo].[PR_MODELTYPE]([NAME] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_MODELTYPE_GID]
    ON [dbo].[PR_MODELTYPE]([GID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PR_MODELTYPE_DEPARTMENTID]
    ON [dbo].[PR_MODELTYPE]([DEPARTMENTID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_MODELTYPE_1]
    ON [dbo].[PR_MODELTYPE]([DEPARTMENTID] ASC, [NAME] ASC);

