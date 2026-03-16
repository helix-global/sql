CREATE TABLE [dbo].[SH_STOCK_POINTS_PC] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [MACHINENAME] NVARCHAR (50)    NOT NULL,
    [REMARK]      NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

