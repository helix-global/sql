CREATE TABLE [dbo].[DEF_COMPANY] (
    [ID]                          INT              IDENTITY (1, 1) NOT NULL,
    [GID]                         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]                        INT              NOT NULL,
    [S_CDT]                       DATETIME         NOT NULL,
    [S_MR]                        INT              NULL,
    [S_MDT]                       DATETIME         NULL,
    [ARC]                         INT              NULL,
    [COMPANY_NAME]                NVARCHAR (1000)  NOT NULL,
    [COMPANY_ADDRESS]             NVARCHAR (2000)  NOT NULL,
    [COMPANY_SITE]                NVARCHAR (1000)  NULL,
    [COMPANY_TEL]                 NVARCHAR (1000)  NULL,
    [COMPANY_FAX]                 NVARCHAR (1000)  NULL,
    [COMPANY_COMMERCIAL_REGISTER] NVARCHAR (50)    NULL,
    [COMPANY_COMMERCIAL_TAXNO]    NVARCHAR (50)    NULL,
    [COMPANY_COMMERCIAL_VATNO]    NVARCHAR (50)    NULL,
    [COMPANY_LOGO]                IMAGE            NULL,
    CONSTRAINT [PK__DEF_COMP__3214EC271771C0F0] PRIMARY KEY CLUSTERED ([ID] ASC)
);

