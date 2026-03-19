CREATE TABLE [dbo].[COM_ADDED_WORKTIME_PLAN] (
    [ID]       INT                IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER   NOT NULL,
    [S_S]      INT                NOT NULL,
    [S_CR]     INT                NOT NULL,
    [S_CDT]    DATETIME           NOT NULL,
    [S_MR]     INT                NULL,
    [S_MDT]    DATETIME           NULL,
    [ARC]      INT                NULL,
    [DEPID]    INT                NOT NULL,
    [MONTH]    INT                NULL,
    [YEAR]     INT                NULL,
    [DATEEDIT] DATETIMEOFFSET (7) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_ADDED_WORKTIME_PLAN_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_ADDED_WORKTIME_PLAN]
    ON [dbo].[COM_ADDED_WORKTIME_PLAN]([DEPID] ASC, [MONTH] ASC, [YEAR] ASC);

