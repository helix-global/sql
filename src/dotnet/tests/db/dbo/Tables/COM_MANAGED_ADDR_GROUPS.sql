CREATE TABLE [dbo].[COM_MANAGED_ADDR_GROUPS] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [NAME]      NVARCHAR (250)   NOT NULL,
    [SHARETYPE] INT              NULL,
    [REMARK]    NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_MANAGED_ADDR_GROUPS]
    ON [dbo].[COM_MANAGED_ADDR_GROUPS]([S_CR] ASC);

