CREATE TABLE [dbo].[MSG_WAIT_DOCS_SETTINGS] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [NAME]         NVARCHAR (250)   NOT NULL,
    [REPORTOID]    INT              NOT NULL,
    [OID]          INT              NOT NULL,
    [DELIVERYTYPE] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MSG_WAIT_DOCS_SETTINGS_REPORTOID] FOREIGN KEY ([REPORTOID]) REFERENCES [dbo].[DEF_REPORTS] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MSG_WAIT_DOCS_SETTINGS_OID]
    ON [dbo].[MSG_WAIT_DOCS_SETTINGS]([OID] ASC);

