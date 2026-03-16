CREATE TABLE [dbo].[SM_SERVICEPROTOCOL] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_S]             INT              NOT NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [DD]              DATETIME         NOT NULL,
    [WORKORDERID]     INT              NOT NULL,
    [SERVCENTERID]    INT              NULL,
    [SERVICEREASON]   NVARCHAR (1024)  NOT NULL,
    [ACCWORK]         NVARCHAR (1024)  NULL,
    [VARIOUSCONSUM]   INT              NULL,
    [WARRS_CHECKED]   INT              NULL,
    [WARRS_INSTALLED] NVARCHAR (50)    NULL,
    [WARRS_REMOVED]   NVARCHAR (50)    NULL,
    [REMARKS]         NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_SERVICEPROTOCOL_SERVCENTERID] FOREIGN KEY ([SERVCENTERID]) REFERENCES [dbo].[SM_SERVICECENTER] ([ID]),
    CONSTRAINT [FK_SM_SERVICEPROTOCOL_WORKORDERID] FOREIGN KEY ([WORKORDERID]) REFERENCES [dbo].[SM_WORKORDER] ([ID])
);

