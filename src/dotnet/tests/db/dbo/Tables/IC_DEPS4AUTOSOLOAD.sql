CREATE TABLE [dbo].[IC_DEPS4AUTOSOLOAD] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NOT NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [DEPID]     INT              NOT NULL,
    [REMARK]    NTEXT            NULL,
    [DISABLED]  INT              NULL,
    [LASTERROR] NTEXT            NULL,
    [LASTLOAD]  DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IC_DEPS4AUTOSOLOAD_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

