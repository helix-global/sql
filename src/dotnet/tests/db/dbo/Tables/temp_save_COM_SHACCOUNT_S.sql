CREATE TABLE [dbo].[temp_save_COM_SHACCOUNT_S] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_S]        INT              NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [ACCOUNTID]  INT              NOT NULL,
    [DBEG]       DATETIME         NOT NULL,
    [DEND]       DATETIME         NOT NULL,
    [EMPLOYEEID] INT              NOT NULL
);

