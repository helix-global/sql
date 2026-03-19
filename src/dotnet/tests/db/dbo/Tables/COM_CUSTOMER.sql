CREATE TABLE [dbo].[COM_CUSTOMER] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NULL,
    [S_CDT]         DATETIME         NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [NAME]          NVARCHAR (250)   NOT NULL,
    [DBEG]          DATETIME         NULL,
    [DEND]          DATETIME         NULL,
    [COUNTRY]       INT              NULL,
    [ARC]           INT              NULL,
    [REMARKS]       NTEXT            NULL,
    [ADDRESS]       NVARCHAR (350)   NULL,
    [PHONE]         NVARCHAR (100)   NULL,
    [CONTACT]       NVARCHAR (200)   NULL,
    [CODE]          NVARCHAR (50)    NULL,
    [PRE_SHIPMENT]  INT              NULL,
    [ADR_CODE]      NVARCHAR (50)    NULL,
    [ADR_CITY]      NVARCHAR (150)   NULL,
    [ADR_STREET]    NVARCHAR (300)   NULL,
    [ADR_RECIPIENT] NVARCHAR (150)   NULL,
    [HOMEPAGE]      NVARCHAR (250)   NULL,
    [CRMGUID]       UNIQUEIDENTIFIER NULL,
    [S_S]           INT              NOT NULL,
    [GLNN]          NVARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_CUSTOMER_COUNTRY] FOREIGN KEY ([COUNTRY]) REFERENCES [dbo].[COM_COUNTRIES] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_CUSTOMER_CRMGUID]
    ON [dbo].[COM_CUSTOMER]([CRMGUID] ASC) WHERE ([CRMGUID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_COM_CUSTOMER_COUNTRY]
    ON [dbo].[COM_CUSTOMER]([COUNTRY] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COM_CUSTOMER_CODE]
    ON [dbo].[COM_CUSTOMER]([CODE] ASC);

