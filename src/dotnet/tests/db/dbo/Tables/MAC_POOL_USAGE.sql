CREATE TABLE [dbo].[MAC_POOL_USAGE] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NOT NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [POOLID]   INT              NOT NULL,
    [PARAMSTR] NVARCHAR (100)   NOT NULL,
    [A1]       TINYINT          NOT NULL,
    [A2]       TINYINT          NOT NULL,
    [A3]       TINYINT          NOT NULL,
    [A4]       TINYINT          NOT NULL,
    [A5]       TINYINT          NOT NULL,
    [A6]       TINYINT          NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MAC_POOL_USAGE_POOLID] FOREIGN KEY ([POOLID]) REFERENCES [dbo].[MAC_POOLS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MAC_POOL_USAGE2]
    ON [dbo].[MAC_POOL_USAGE]([POOLID] ASC, [A1] ASC, [A2] ASC, [A3] ASC, [A4] ASC, [A5] ASC, [A6] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MAC_POOL_USAGE]
    ON [dbo].[MAC_POOL_USAGE]([POOLID] ASC, [PARAMSTR] ASC);

