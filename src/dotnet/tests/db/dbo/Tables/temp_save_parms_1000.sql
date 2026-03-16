CREATE TABLE [dbo].[temp_save_parms_1000] (
    [ID]       INT              NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NULL,
    [S_CDT]    DATETIME         NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [OPERID]   INT              NOT NULL,
    [PARAMID]  INT              NOT NULL,
    [PVALUE]   SQL_VARIANT      NOT NULL,
    [PCOMMENT] NTEXT            NULL
);

