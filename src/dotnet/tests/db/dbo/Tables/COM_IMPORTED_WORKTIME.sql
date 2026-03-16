CREATE TABLE [dbo].[COM_IMPORTED_WORKTIME] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [WORKDAY]     DATE             NOT NULL,
    [WORKMINUTES] DECIMAL (16, 2)  NOT NULL,
    [PERSNO]      NVARCHAR (20)    NOT NULL,
    [EMPLID]      INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_IMPORTED_WORKTIME]
    ON [dbo].[COM_IMPORTED_WORKTIME]([WORKDAY] ASC, [EMPLID] ASC);

