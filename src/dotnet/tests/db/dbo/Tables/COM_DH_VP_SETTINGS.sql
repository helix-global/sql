CREATE TABLE [dbo].[COM_DH_VP_SETTINGS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [NAME]           NVARCHAR (50)    NOT NULL,
    [CODE]           INT              NOT NULL,
    [REMARK]         NTEXT            NULL,
    [DEFAULT4EMPLID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_DH_VP_SETTINGS_DEFAULT4EMPLID] FOREIGN KEY ([DEFAULT4EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_DH_VP_SETTINGS_CODE]
    ON [dbo].[COM_DH_VP_SETTINGS]([CODE] ASC);

