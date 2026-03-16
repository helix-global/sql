CREATE TABLE [dbo].[FC_FARS_2_NAV] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [FRID]      INT              NOT NULL,
    [SERVICENO] NVARCHAR (50)    NULL,
    [SN]        NVARCHAR (50)    NULL,
    [FILENAME]  NVARCHAR (255)   NOT NULL,
    [FILESIZE]  INT              NULL,
    [FILEBLOB]  IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_FARS_2_NAV_FRID] FOREIGN KEY ([FRID]) REFERENCES [dbo].[FC_REPORT] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FC_FARS_2_NAV_GID]
    ON [dbo].[FC_FARS_2_NAV]([GID] ASC);

