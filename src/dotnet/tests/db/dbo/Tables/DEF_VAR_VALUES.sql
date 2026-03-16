CREATE TABLE [dbo].[DEF_VAR_VALUES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [VAROID]      INT              NOT NULL,
    [DBEG]        DATE             NOT NULL,
    [DEND]        DATE             NOT NULL,
    [USERID]      INT              NULL,
    [VALUEINT]    INT              NULL,
    [VALUESTRING] NVARCHAR (500)   NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NULL,
    [S_MR]        INT              NULL,
    [S_CDT]       DATETIME         NULL,
    [S_MDT]       DATETIME         NULL,
    CONSTRAINT [PK_DEF_VAR_VALUES] PRIMARY KEY CLUSTERED ([ID] ASC)
);

