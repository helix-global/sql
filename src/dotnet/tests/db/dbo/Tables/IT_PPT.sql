CREATE TABLE [dbo].[IT_PPT] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NOT NULL,
    [S_S]    INT              NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [DD]     DATETIME         NOT NULL,
    [REMARK] NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

