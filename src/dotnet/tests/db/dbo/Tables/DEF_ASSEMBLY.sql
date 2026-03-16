CREATE TABLE [dbo].[DEF_ASSEMBLY] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [NAME]      NVARCHAR (100)   NOT NULL,
    [AUTOLOAD]  INT              NULL,
    [OID]       INT              NOT NULL,
    [MODULEOID] INT              NOT NULL,
    [REMARK]    NTEXT            NULL,
    CONSTRAINT [PK__DEF_ASSE__3214EC2739788055] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_ASSEMBLY_MODULEOID] FOREIGN KEY ([MODULEOID]) REFERENCES [dbo].[DEF_MODULES] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_ASSEMBLY]
    ON [dbo].[DEF_ASSEMBLY]([OID] ASC);


GO
GRANT SELECT
    ON OBJECT::[dbo].[DEF_ASSEMBLY] TO [IPG-DOMAIN\IPGL-bu-pdbAndroidSr]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DEF_ASSEMBLY] TO [EMEA\DEMUS]
    AS [dbo];

