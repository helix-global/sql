CREATE TABLE [dbo].[COM_CALENDAR] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [DDAY]      DATE             NOT NULL,
    [CALENDAR]  INT              NOT NULL,
    [DAYSTATUS] INT              NOT NULL,
    CONSTRAINT [PK__COM_CALE__3214EC271ADEEA9C] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_CALENDAR]
    ON [dbo].[COM_CALENDAR]([CALENDAR] ASC, [DDAY] ASC)
    INCLUDE([DAYSTATUS]);

