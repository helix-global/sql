CREATE TABLE [dbo].[temp_import_addcontacts] (
    [ID]              INT              NOT NULL,
    [CRMGUID]         UNIQUEIDENTIFIER NULL,
    [EMAIL]           NVARCHAR (250)   NULL,
    [NAME]            NVARCHAR (100)   NOT NULL,
    [CONTACT_CRMGUID] NVARCHAR (2048)  NULL,
    [ACCOUNT_CRMGUID] NVARCHAR (2048)  NULL
);

