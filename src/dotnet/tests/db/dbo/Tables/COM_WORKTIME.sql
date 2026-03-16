CREATE TABLE [dbo].[COM_WORKTIME] (
    [ID]                INT              IDENTITY (1, 1) NOT NULL,
    [GID]               UNIQUEIDENTIFIER NULL,
    [S_CR]              INT              NOT NULL,
    [S_CDT]             DATETIME         NOT NULL,
    [S_MR]              INT              NULL,
    [S_MDT]             DATETIME         NULL,
    [ARC]               INT              NULL,
    [DEPID]             INT              NOT NULL,
    [NAME]              NVARCHAR (150)   NOT NULL,
    [WTDEFAULT]         INT              NULL,
    [CALENDAR]          INT              NOT NULL,
    [MAXHOURSPERDAY]    DECIMAL (10, 1)  NULL,
    [WD1]               INT              NULL,
    [WD2]               INT              NULL,
    [WD3]               INT              NULL,
    [WD4]               INT              NULL,
    [WD5]               INT              NULL,
    [S_S]               INT              NOT NULL,
    [WD6]               INT              NULL,
    [WD7]               INT              NULL,
    [RESTRICTOVERTIMES] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_WORKTIME_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_WORKTIME_DEFAULT]
    ON [dbo].[COM_WORKTIME]([DEPID] ASC, [WTDEFAULT] ASC) WHERE ([WTDEFAULT]=(1));


GO
CREATE NONCLUSTERED INDEX [IX_COM_WORKTIME_2]
    ON [dbo].[COM_WORKTIME]([DEPID] ASC)
    INCLUDE([WTDEFAULT]);


GO
CREATE NONCLUSTERED INDEX [IX_COM_WORKTIME]
    ON [dbo].[COM_WORKTIME]([DEPID] ASC);

