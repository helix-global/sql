CREATE TABLE [dbo].[COM_CURRENCIES] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [SWIFT]            VARCHAR (4)   NULL,
    [KODVAL]           VARCHAR (3)   NULL,
    [NAMVAL]           NVARCHAR (50) NULL,
    [VALCOUNTRY]       VARCHAR (255) NULL,
    [CH1VAL]           VARCHAR (26)  NULL,
    [CH2VAL]           VARCHAR (26)  NULL,
    [CH5VAL]           VARCHAR (26)  NULL,
    [FRCVAL]           SMALLINT      NULL,
    [FRROD]            SMALLINT      NULL,
    [FR1]              NVARCHAR (30) NULL,
    [FR2]              NVARCHAR (30) NULL,
    [FR5]              NVARCHAR (30) NULL,
    [TYPVAL]           VARCHAR (2)   NULL,
    [RODVAL]           SMALLINT      NULL,
    [MODAVAL]          VARCHAR (5)   NULL,
    [OKONCH]           NVARCHAR (30) NULL,
    [ARC]              INT           NULL,
    [CURSTOVAL]        INT           NULL,
    [IS_SNG]           SMALLINT      NULL,
    [IS_DRAGMET]       SMALLINT      NULL,
    [IS_SKV]           SMALLINT      NULL,
    [IS_KLIR]          SMALLINT      NULL,
    [USE_CODE_COUNTRY] VARCHAR (3)   NULL,
    [GID]              VARCHAR (38)  DEFAULT (newid()) NOT NULL,
    [S_CR]             INT           NULL,
    [S_MR]             INT           NULL,
    [S_CDT]            DATETIME      NULL,
    [S_MDT]            DATETIME      NULL,
    CONSTRAINT [PK_COM_CURRENCIES] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_CURRENCIES]
    ON [dbo].[COM_CURRENCIES]([KODVAL] ASC) WITH (FILLFACTOR = 90);

