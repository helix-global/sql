CREATE TABLE [dbo].[DEF_USERS] (
    [ID]                INT              IDENTITY (1, 1) NOT NULL,
    [S_S]               INT              NOT NULL,
    [LOGINNAME]         NVARCHAR (200)   NOT NULL,
    [FULLNAME]          NVARCHAR (200)   NOT NULL,
    [ISGROUP]           INT              NULL,
    [LANGUAGE]          INT              NULL,
    [GID]               UNIQUEIDENTIFIER NULL,
    [S_CR]              INT              NULL,
    [S_MR]              INT              NULL,
    [S_CDT]             DATETIME         NULL,
    [S_MDT]             DATETIME         NULL,
    [ARC]               INT              NULL,
    [EMPLOYEEID]        INT              NULL,
    [USESHAREDACCOUNTS] INT              NULL,
    [REMARK]            NTEXT            NULL,
    [LOGINNAME2]        NVARCHAR (200)   NULL,
    [REQUESTROWID]      INT              NULL,
    [TMP_OP]            INT              NULL,
    [TMP_SPV]           INT              NULL,
    [TMP_DES]           INT              NULL,
    [LADM]              INT              NULL,
    [UC_LOGINNAME]      AS               (upper([LOGINNAME])),
    [ENVIRONMENT]       VARCHAR (200)    NULL,
    [GRGRADE]           INT              NULL,
    [OPTIONS]           NVARCHAR (512)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DEF_USERS_EMPLOYEEID] FOREIGN KEY ([EMPLOYEEID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_USERS_UC]
    ON [dbo].[DEF_USERS]([UC_LOGINNAME] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_USERS_REQUESTROWID]
    ON [dbo].[DEF_USERS]([REQUESTROWID] ASC) WHERE ([REQUESTROWID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_DEF_USERS_LOGINNAME2]
    ON [dbo].[DEF_USERS]([LOGINNAME2] ASC) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_USERS_EMPLOYEEID]
    ON [dbo].[DEF_USERS]([EMPLOYEEID] ASC) WHERE ([EMPLOYEEID] IS NOT NULL) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_USERS]
    ON [dbo].[DEF_USERS]([LOGINNAME] ASC) WITH (FILLFACTOR = 90);

