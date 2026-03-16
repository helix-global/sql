CREATE TABLE [dbo].[FC_OFFICE] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [NAME]    NVARCHAR (100)   NOT NULL,
    [COUNTRY] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_OFFICE_COUNTRY] FOREIGN KEY ([COUNTRY]) REFERENCES [dbo].[COM_COUNTRIES] ([ID])
);

