CREATE TABLE [dbo].[COM_EMPLOYEE] (
    [ID]                        INT              IDENTITY (1, 1) NOT NULL,
    [GID]                       UNIQUEIDENTIFIER NULL,
    [S_S]                       INT              NOT NULL,
    [S_CR]                      INT              NOT NULL,
    [S_CDT]                     DATETIME         NOT NULL,
    [S_MR]                      INT              NULL,
    [S_MDT]                     DATETIME         NULL,
    [ARC]                       INT              NULL,
    [NAME]                      NVARCHAR (200)   NOT NULL,
    [EMAIL]                     NVARCHAR (200)   NULL,
    [PHONE]                     NVARCHAR (100)   NULL,
    [DEPID]                     INT              NULL,
    [PERSONALNO]                NVARCHAR (20)    NULL,
    [QUALIFICATION]             INT              NULL,
    [PERSONALWT]                INT              NULL,
    [ROLEINDEP]                 INT              NULL,
    [DISSDATE]                  DATETIME         NULL,
    [GENDER]                    INT              NULL,
    [NOPROD]                    INT              NULL,
    [ISTEMP]                    INT              NOT NULL,
    [TEMPID]                    INT              NULL,
    [REQUESTROWID]              INT              NULL,
    [temp_save_PN]              INT              NULL,
    [EMPDATE]                   DATE             NULL,
    [ISRANDD]                   INT              NULL,
    [PRODSUPPORT]               INT              NULL,
    [PARTINPRODUCTION]          INT              NULL,
    [GIVENNAME]                 NVARCHAR (100)   NOT NULL,
    [SURNAME]                   NVARCHAR (100)   NOT NULL,
    [OLDDEPID_AUTOCHANGED]      INT              NULL,
    [AZUBI]                     INT              NULL,
    [ZAFID]                     INT              NULL,
    [WRKPLACE]                  NVARCHAR (100)   NULL,
    [OLDPERSONALWT_AUTOCHANGED] INT              NULL,
    [NOGREENCARD]               INT              NULL,
    [CH_BALANCE_FROM]           DATE             NULL,
    [NOLUR]                     INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_EMPLOYEE_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_COM_EMPLOYEE_PERSONALWT] FOREIGN KEY ([PERSONALWT]) REFERENCES [dbo].[COM_WORKTIME] ([ID]),
    CONSTRAINT [FK_COM_EMPLOYEE_ZAFID] FOREIGN KEY ([ZAFID]) REFERENCES [dbo].[COM_ZEITAFIRMA] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_EMPLOYEE_ZAFID]
    ON [dbo].[COM_EMPLOYEE]([ZAFID] ASC) WHERE ([ZAFID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_COM_EMPLOYEE_S_S_ID]
    ON [dbo].[COM_EMPLOYEE]([S_S] ASC)
    INCLUDE([ID]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_EMPLOYEE_REQUESTROWID]
    ON [dbo].[COM_EMPLOYEE]([REQUESTROWID] ASC) WHERE ([REQUESTROWID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_EMPLOYEE_EMAIL]
    ON [dbo].[COM_EMPLOYEE]([EMAIL] ASC, [DISSDATE] ASC) WHERE ([EMAIL] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_COM_EMPLOYEE_DISSDATE_EMPDATE]
    ON [dbo].[COM_EMPLOYEE]([DISSDATE] ASC, [EMPDATE] ASC)
    INCLUDE([ID], [DEPID], [PERSONALWT]);


GO
CREATE NONCLUSTERED INDEX [IX_COM_EMPLOYEE_DEPID]
    ON [dbo].[COM_EMPLOYEE]([DEPID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_EMPLOYEE]
    ON [dbo].[COM_EMPLOYEE]([PERSONALNO] ASC) WHERE ([PERSONALNO] IS NOT NULL AND [DISSDATE] IS NULL);

