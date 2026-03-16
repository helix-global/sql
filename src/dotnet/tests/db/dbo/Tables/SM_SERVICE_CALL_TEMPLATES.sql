CREATE TABLE [dbo].[SM_SERVICE_CALL_TEMPLATES] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NOT NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [TEMPLATE_TEXT] NTEXT            NULL,
    [NAME]          NVARCHAR (50)    NOT NULL,
    [DEPID]         INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_SERVICE_CALL_TEMPLATES_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

