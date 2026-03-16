CREATE TABLE [dbo].[COM_SHORT_WORKDAY] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [MM]       INT              NOT NULL,
    [DD]       INT              NOT NULL,
    [CALENDAR] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_SHORT_WORKDAY]
    ON [dbo].[COM_SHORT_WORKDAY]([CALENDAR] ASC, [MM] ASC, [DD] ASC);

