CREATE TABLE [dbo].[MAC_POOLS] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [NN]     INT              NOT NULL,
    [ST1]    TINYINT          NOT NULL,
    [ST2]    TINYINT          NOT NULL,
    [ST3]    TINYINT          NOT NULL,
    [ST4]    TINYINT          NOT NULL,
    [ST5]    TINYINT          NOT NULL,
    [ST6]    TINYINT          NOT NULL,
    [EN4]    TINYINT          NOT NULL,
    [EN5]    TINYINT          NOT NULL,
    [EN6]    TINYINT          NOT NULL,
    [REMARK] NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MAC_POOLS_NN]
    ON [dbo].[MAC_POOLS]([NN] ASC);

