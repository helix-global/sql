CREATE TABLE [dbo].[COM_WDR_RESTRICT] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [DEPID]      INT              NOT NULL,
    [AVAIL_TIME] DATETIME         NULL,
    [REMARK]     NTEXT            NULL,
    [FROM_UNTIL] INT              NULL,
    [FROMDATE]   DATETIME         NULL,
    [UNTILDATE]  DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_WDR_RESTRICT_DEPID]
    ON [dbo].[COM_WDR_RESTRICT]([DEPID] ASC);

