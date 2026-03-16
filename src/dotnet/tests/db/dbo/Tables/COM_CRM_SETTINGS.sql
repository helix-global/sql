CREATE TABLE [dbo].[COM_CRM_SETTINGS] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [DBNAME] NVARCHAR (50)    NOT NULL,
    [CRMURL] NVARCHAR (100)   NOT NULL,
    [REMARK] NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

