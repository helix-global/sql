CREATE TABLE [dbo].[PRR_LUR_KB4018DATE] (
    [ID]    INT              IDENTITY (1, 1) NOT NULL,
    [GID]   UNIQUEIDENTIFIER NOT NULL,
    [S_CR]  INT              NOT NULL,
    [S_CDT] DATETIME         NOT NULL,
    [S_MR]  INT              NULL,
    [S_MDT] DATETIME         NULL,
    [ARC]   INT              NULL,
    [STYPE] INT              NOT NULL,
    [SDD]   DATE             NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PRR_LUR_KB4018DATE]
    ON [dbo].[PRR_LUR_KB4018DATE]([STYPE] ASC);

