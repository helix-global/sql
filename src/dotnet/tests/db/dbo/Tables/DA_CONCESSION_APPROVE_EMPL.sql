CREATE TABLE [dbo].[DA_CONCESSION_APPROVE_EMPL] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NOT NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [AUTHTYPE] INT              NULL,
    [EMPLID]   INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DA_CONCESSION_APPROVE_EMPL_EMPLID] FOREIGN KEY ([EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);

