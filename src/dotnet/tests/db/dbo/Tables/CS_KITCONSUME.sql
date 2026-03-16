CREATE TABLE [dbo].[CS_KITCONSUME] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NOT NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [DD]      DATETIME         NOT NULL,
    [ORDERID] INT              NOT NULL,
    [OPERIDS] NTEXT            NULL,
    [DEND]    DATETIME         NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_CS_KITCONSUME_ORDERID] FOREIGN KEY ([ORDERID]) REFERENCES [dbo].[PR_PRORDER] ([ID])
);

