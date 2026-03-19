CREATE TABLE [dbo].[DEF_INTERFACE] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [OID]          INT              NOT NULL,
    [LABEL]        NVARCHAR (40)    NOT NULL,
    [MODULEOID]    INT              NOT NULL,
    [NAME]         NVARCHAR (100)   NOT NULL,
    [REMARK]       IMAGE            NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NULL,
    [S_MR]         INT              NULL,
    [S_CDT]        DATETIME         NULL,
    [S_MDT]        DATETIME         NULL,
    [ADMAUTOLOAD]  INT              NULL,
    [WSBCOLOR]     INT              NULL,
    [POSORDER]     INT              NULL,
    [FOLDERIMG]    NVARCHAR (120)   NULL,
    [ONLYFIFQUERY] INT              NULL,
    [HIDEIFQUERY]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_INTERFACE_HIDEIFQUERY] FOREIGN KEY ([HIDEIFQUERY]) REFERENCES [dbo].[DEF_SQL] ([OID]),
    CONSTRAINT [FK_DEF_INTERFACE_MODULEOID] FOREIGN KEY ([MODULEOID]) REFERENCES [dbo].[DEF_MODULES] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_INTERFACE]
    ON [dbo].[DEF_INTERFACE]([OID] ASC);

