CREATE TABLE [dbo].[SH_SETTINGS] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [DEPID]            INT              NOT NULL,
    [RUNNAVISION]      INT              NULL,
    [MSGTYPE]          INT              NULL,
    [MSGTO]            NVARCHAR (1024)  NULL,
    [MSGCC]            NVARCHAR (1024)  NULL,
    [RS_REQUIRED]      INT              NULL,
    [RS_LOC_REQUIRED]  INT              NULL,
    [BLOCKSHMETHOD]    INT              NULL,
    [IOMSGTYPE]        INT              NULL,
    [IOMSGTO]          NVARCHAR (1024)  NULL,
    [IOMSGCC]          NVARCHAR (1024)  NULL,
    [BLOCK_INPROD]     INT              NULL,
    [BLOCK_MULTYSH]    INT              NULL,
    [ALLOW_SHIPPEDDOT] INT              NULL,
    [ALL_FROM_ONE_IO]  INT              NULL,
    [SRVMSGTYPE]       INT              NULL,
    [SRVMSGTO]         NVARCHAR (1024)  NULL,
    [SRVMSGCC]         NVARCHAR (1024)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SH_SETTINGS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SH_SETTINGS]
    ON [dbo].[SH_SETTINGS]([DEPID] ASC);

