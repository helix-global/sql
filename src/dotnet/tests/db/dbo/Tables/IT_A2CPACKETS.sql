CREATE TABLE [dbo].[IT_A2CPACKETS] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NOT NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [VERSION] NVARCHAR (50)    NOT NULL,
    [REMARK]  NTEXT            NULL,
    [DD]      DATE             NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

