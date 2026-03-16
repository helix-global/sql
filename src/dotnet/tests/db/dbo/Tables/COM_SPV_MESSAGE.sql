CREATE TABLE [dbo].[COM_SPV_MESSAGE] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_S]       INT              NOT NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [DD]        DATETIME         NOT NULL,
    [MESS]      NTEXT            NOT NULL,
    [DEPID]     INT              NOT NULL,
    [UPVISIBLE] INT              NULL,
    [KIND]      INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

