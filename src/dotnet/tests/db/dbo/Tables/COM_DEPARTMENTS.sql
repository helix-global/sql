CREATE TABLE [dbo].[COM_DEPARTMENTS] (
    [ID]                          INT              IDENTITY (1, 1) NOT NULL,
    [GID]                         UNIQUEIDENTIFIER NULL,
    [S_CR]                        INT              NULL,
    [S_CDT]                       DATETIME         NULL,
    [S_MR]                        INT              NULL,
    [S_MDT]                       DATETIME         NULL,
    [NAME]                        NVARCHAR (100)   NOT NULL,
    [CODE]                        NVARCHAR (100)   NOT NULL,
    [CONTACT]                     NVARCHAR (200)   NULL,
    [PHONE]                       NVARCHAR (100)   NULL,
    [EMAIL]                       NVARCHAR (200)   NULL,
    [ADDRESS]                     NVARCHAR (200)   NULL,
    [ARC]                         INT              NULL,
    [PARENTDEPARTMENT]            INT              NULL,
    [NONPROD]                     INT              NULL,
    [DEP_SUPP]                    INT              NULL,
    [FCDBID]                      INT              NULL,
    [POSTINGCODE]                 NVARCHAR (20)    NULL,
    [REWORKORDERPR]               INT              NULL,
    [RSERVER]                     INT              NULL,
    [SUPLORDERONLY4IO]            INT              NULL,
    [CUSTOMERID]                  INT              NULL,
    [PLACECODE]                   NVARCHAR (100)   NULL,
    [PRE_SHIPMENT]                INT              NULL,
    [BLOCKBYCOMPATIPRMS]          INT              NULL,
    [MODEESTIMATIONTIME]          INT              NULL,
    [SOCLOSEMODE]                 INT              NULL,
    [SUPPLYIMPORTCODE]            NVARCHAR (20)    NULL,
    [AUTOPOSTPONEOPERTTIME]       DATETIME         NULL,
    [SIMPLEIDN]                   INT              NULL,
    [LOADSOSTATES]                INT              NULL,
    [CLEARLOCATIONMODE]           INT              NULL,
    [DONTALLOWWEBAPROPOSALS]      INT              NULL,
    [SERVICEORDERFARREQUIRED]     INT              NULL,
    [CHECK_PRINTED_DOC_REQUIRED]  INT              NULL,
    [DISABLECALLNAVSERVITEM]      INT              NULL,
    [SKILL_MATRIX]                INT              NULL,
    [TRAINING_OPERATION_MODE]     INT              NULL,
    [DENY_OVERLAP_ABSENCE]        INT              NULL,
    [SUPPLYFILLMODE]              INT              NULL,
    [ALLOW_SWTOOL_VER_LINK]       INT              NULL,
    [NO_SKILL_ACTION]             INT              NULL,
    [REV_CASC_DEPRECATION]        INT              NULL,
    [REV_CASC_CANCEL_DEPRECATION] INT              NULL,
    [DISABLED]                    INT              NULL,
    [FRANALYZEMISSEDDAYS]         INT              NULL,
    [IMPORTED_WTIMES]             INT              NULL,
    [AUTO_CREATE_HER]             INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_COM_DEPARTMENTS_CUSTOMERID] FOREIGN KEY ([CUSTOMERID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_COM_DEPARTMENTS_PARENTDEPARTMENT] FOREIGN KEY ([PARENTDEPARTMENT]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_COM_DEPARTMENTS_RSERVER] FOREIGN KEY ([RSERVER]) REFERENCES [dbo].[COM_REMOTE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_DEPARTMENTS_POSTINGCODE]
    ON [dbo].[COM_DEPARTMENTS]([POSTINGCODE] ASC) WHERE ([POSTINGCODE] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_COM_DEPARTMENTS_PARENT]
    ON [dbo].[COM_DEPARTMENTS]([PARENTDEPARTMENT] ASC) WHERE ([PARENTDEPARTMENT] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_DEPARTMENTS_CUSTOMERID]
    ON [dbo].[COM_DEPARTMENTS]([CUSTOMERID] ASC) WHERE ([CUSTOMERID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_DEPARTMENTS_CODE]
    ON [dbo].[COM_DEPARTMENTS]([CODE] ASC);


GO
GRANT SELECT
    ON OBJECT::[dbo].[COM_DEPARTMENTS] TO [IPG-DOMAIN\IPGL_Integr_MSCRM]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[COM_DEPARTMENTS] TO [EMEA\DEPCS]
    AS [dbo];

