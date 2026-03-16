CREATE TABLE [dbo].[DEF_PLUGINS] (
    [ID]    INT              IDENTITY (1, 1) NOT NULL,
    [GID]   UNIQUEIDENTIFIER NOT NULL,
    [S_CR]  INT              NOT NULL,
    [S_CDT] DATETIME         NOT NULL,
    [S_MR]  INT              NULL,
    [S_MDT] DATETIME         NULL,
    [ARC]   INT              NULL,
    [NAME]  NVARCHAR (100)   NOT NULL,
    [DEPID] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_PLUGINS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

