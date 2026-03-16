CREATE TABLE [dbo].[FC_EXT_FAR_ACCESS] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NOT NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [ENDDEPID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_EXT_FAR_ACCESS_ENDDEPID] FOREIGN KEY ([ENDDEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

