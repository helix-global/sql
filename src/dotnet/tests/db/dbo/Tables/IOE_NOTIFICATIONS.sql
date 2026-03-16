CREATE TABLE [dbo].[IOE_NOTIFICATIONS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [DBEG]       DATE             NOT NULL,
    [PERIODN]    INT              NOT NULL,
    [PERIODTYPW] INT              NOT NULL,
    [REMARK]     NTEXT            NULL,
    [LASTSEND]   DATE             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

