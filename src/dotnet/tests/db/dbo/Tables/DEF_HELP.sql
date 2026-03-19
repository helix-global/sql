CREATE TABLE [dbo].[DEF_HELP] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NOT NULL,
    [S_S]            INT              NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [CAPTION]        NVARCHAR (300)   NOT NULL,
    [PARENTOID]      INT              NULL,
    [OID]            INT              NOT NULL,
    [LINKEDTOCLASS]  INT              NULL,
    [LINKEDTOREPORT] INT              NULL,
    [LINKEDTOOPER]   INT              NULL,
    [HIDED]          INT              NULL,
    [TEXT_RU]        NTEXT            NULL,
    [TEXT_DE]        NTEXT            NULL,
    [TEXT_EN]        NTEXT            NULL,
    [POSORDER]       INT              NULL,
    [SPECIALPAGE]    INT              NULL,
    [ONLY4GROUP]     INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_HELP_LINKEDTOCLASS] FOREIGN KEY ([LINKEDTOCLASS]) REFERENCES [dbo].[DEF_CLASSES] ([OID]),
    CONSTRAINT [FK_DEF_HELP_LINKEDTOOPER] FOREIGN KEY ([LINKEDTOOPER]) REFERENCES [dbo].[DEF_OPERATION] ([OID]),
    CONSTRAINT [FK_DEF_HELP_LINKEDTOREPORT] FOREIGN KEY ([LINKEDTOREPORT]) REFERENCES [dbo].[DEF_REPORTS] ([OID]),
    CONSTRAINT [FK_DEF_HELP_ONLY4GROUP] FOREIGN KEY ([ONLY4GROUP]) REFERENCES [dbo].[DEF_USERS] ([ID]),
    CONSTRAINT [FK_DEF_HELP_PARENTOID] FOREIGN KEY ([PARENTOID]) REFERENCES [dbo].[DEF_HELP] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_HELP_OID]
    ON [dbo].[DEF_HELP]([OID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_HELP_GID]
    ON [dbo].[DEF_HELP]([GID] ASC);

