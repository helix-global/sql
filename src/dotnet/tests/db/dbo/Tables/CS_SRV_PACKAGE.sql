CREATE TABLE [dbo].[CS_SRV_PACKAGE] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [DEPID]         INT              NOT NULL,
    [MTID]          INT              NOT NULL,
    [NAME]          NVARCHAR (200)   NOT NULL,
    [REMARK]        NTEXT            NULL,
    [DESCSTR]       NVARCHAR (250)   NULL,
    [FILENAME_MASK] NVARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_CS_SRV_PACKAGE_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_CS_SRV_PACKAGE_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CS_SRV_PACKAGE_GID]
    ON [dbo].[CS_SRV_PACKAGE]([GID] ASC);

