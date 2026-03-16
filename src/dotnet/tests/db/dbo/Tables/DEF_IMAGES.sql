CREATE TABLE [dbo].[DEF_IMAGES] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NULL,
    [S_CDT]            DATETIME         NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [OID]              INT              NOT NULL,
    [LABEL]            NVARCHAR (40)    NOT NULL,
    [NAME]             NVARCHAR (100)   NOT NULL,
    [MODULEOID]        INT              NOT NULL,
    [IMAGES]           IMAGE            NULL,
    [IMGHEIGHT]        INT              NULL,
    [IMGWIDTH]         INT              NULL,
    [IMGTYPE]          INT              NOT NULL,
    [TRANSPARENTCOLOR] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_IMAGES_MODULEOID] FOREIGN KEY ([MODULEOID]) REFERENCES [dbo].[DEF_MODULES] ([OID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_IMAGES_1]
    ON [dbo].[DEF_IMAGES]([LABEL] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_IMAGES]
    ON [dbo].[DEF_IMAGES]([OID] ASC);

