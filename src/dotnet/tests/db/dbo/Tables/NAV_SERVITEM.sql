CREATE TABLE [dbo].[NAV_SERVITEM] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [S_CR]              INT            NULL,
    [S_CDT]             DATETIME       NULL,
    [S_MR]              INT            NULL,
    [S_MDT]             DATETIME       NULL,
    [SESSIONGID]        NVARCHAR (40)  NULL,
    [serviceitemnumber] NVARCHAR (50)  NULL,
    [itemnumber]        NVARCHAR (50)  NULL,
    [serialnumber]      NVARCHAR (50)  NULL,
    [vendoritemnumber]  NVARCHAR (250) NULL,
    [description]       NVARCHAR (300) NULL,
    [warranty]          NVARCHAR (50)  NULL,
    [repairstatuscode]  NVARCHAR (50)  NULL,
    [XMLID]             INT            NOT NULL,
    [FARID]             INT            NULL,
    [applicableoption]  NTEXT          NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_NAV_SERVITEM_XMLID_GID]
    ON [dbo].[NAV_SERVITEM]([SESSIONGID] ASC, [XMLID] ASC);

