CREATE TABLE [dbo].[COM_DISABLE_SH_ABS] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NOT NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [DEPID]            INT              NOT NULL,
    [REMARK]           NTEXT            NULL,
    [BALANCE_SHRT_ABS] INT              DEFAULT ((480)) NULL,
    [BALANCE_OVERTIME] INT              DEFAULT ((480)) NULL,
    [SHRT_ABS_MAX]     INT              DEFAULT ((225)) NULL,
    [SHRT_ABS_HDV]     INT              DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_DISABLE_SH_ABS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_DISABLE_SH_ABS_DEPID]
    ON [dbo].[COM_DISABLE_SH_ABS]([DEPID] ASC);

