CREATE TABLE [dbo].[PR_BARCODE_PRINTERS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [NAME]           NVARCHAR (50)    NOT NULL,
    [DEPID]          INT              NOT NULL,
    [PRTADDR]        NVARCHAR (100)   NOT NULL,
    [PRTMODE]        INT              NOT NULL,
    [EMFTEMPLATE]    NVARCHAR (50)    NULL,
    [DEFCOUNT]       INT              NULL,
    [REMARK]         NTEXT            NULL,
    [SPMARK]         NVARCHAR (50)    NULL,
    [POSORDER]       INT              NULL,
    [USEINITEMCARD]  INT              NULL,
    [LINKKIND]       INT              NOT NULL,
    [OPTIONS]        NVARCHAR (200)   NULL,
    [DESREPORTID]    INT              NULL,
    [SAVEDTEST_H]    DECIMAL (9, 2)   NULL,
    [SAVEDTEST_W]    DECIMAL (9, 2)   NULL,
    [SIZEMODE]       INT              NULL,
    [CUSTOMWIDTH]    DECIMAL (12, 1)  NULL,
    [CUSTOMHEIGHT]   DECIMAL (12, 1)  NULL,
    [CUSTOMLEFTM]    DECIMAL (12, 1)  NULL,
    [CUSTOMTOPM]     DECIMAL (12, 1)  NULL,
    [USEINLABELCOPY] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_BARCODE_PRINTERS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_BARCODE_PRINTERS_DESREPORTID] FOREIGN KEY ([DESREPORTID]) REFERENCES [dbo].[PR_REPORTS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_BARCODE_PRINTERS]
    ON [dbo].[PR_BARCODE_PRINTERS]([DEPID] ASC);

