CREATE TABLE [dbo].[PR_REPORT_PARAM_TEMPLATES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [NAME]        NVARCHAR (250)   NOT NULL,
    [DESCRIPTION] NVARCHAR (250)   NULL,
    [REPORTLABEL] NVARCHAR (250)   NOT NULL,
    [USERID]      INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_REPORT_PARAM_TEMPLATES_USERID] FOREIGN KEY ([USERID]) REFERENCES [dbo].[DEF_USERS] ([ID])
);

