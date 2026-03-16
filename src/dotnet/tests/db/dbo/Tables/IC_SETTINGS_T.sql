CREATE TABLE [dbo].[IC_SETTINGS_T] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [VNESHID]        INT              NOT NULL,
    [SERVERNAME]     NVARCHAR (200)   NOT NULL,
    [DBNAME]         NVARCHAR (200)   NOT NULL,
    [REMARK]         NTEXT            NULL,
    [FAILUREPARTNER] NVARCHAR (200)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IC_SETTINGS_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[IC_SETTINGS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_IC_SETTINGS_T]
    ON [dbo].[IC_SETTINGS_T]([VNESHID] ASC);

