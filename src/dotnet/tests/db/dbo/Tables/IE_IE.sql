CREATE TABLE [dbo].[IE_IE] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [NAME]        NVARCHAR (250)   NULL,
    [ENDUSERID]   INT              NOT NULL,
    [ADR_COUNTRY] INT              NULL,
    [ADR_CITY]    NVARCHAR (150)   NULL,
    [ADR_CODE]    NVARCHAR (50)    NULL,
    [ADR_STREET]  NVARCHAR (200)   NULL,
    [DESCSTR]     NTEXT            NULL,
    [RSDEPID]     INT              NULL,
    [NN]          NVARCHAR (20)    NOT NULL,
    [LLOCATION]   NVARCHAR (200)   NULL,
    [HALLE]       NVARCHAR (200)   NULL,
    [ABTEILUNG]   NVARCHAR (200)   NULL,
    [SPEC_AGREE]  NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IE_IE_ADR_COUNTRY] FOREIGN KEY ([ADR_COUNTRY]) REFERENCES [dbo].[COM_COUNTRIES] ([ID]),
    CONSTRAINT [FK_IE_IE_ENDUSERID] FOREIGN KEY ([ENDUSERID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_IE_IE_RSDEPID] FOREIGN KEY ([RSDEPID]) REFERENCES [dbo].[FC_OFFICE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IE_IE_NN]
    ON [dbo].[IE_IE]([NN] ASC);

