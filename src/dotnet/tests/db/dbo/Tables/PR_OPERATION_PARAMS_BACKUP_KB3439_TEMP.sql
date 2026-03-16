CREATE TABLE [dbo].[PR_OPERATION_PARAMS_BACKUP_KB3439_TEMP] (
    [ID]         INT              NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NULL,
    [S_CDT]      DATETIME         NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [OPERID]     INT              NOT NULL,
    [PARAMID]    INT              NOT NULL,
    [PVALUE]     SQL_VARIANT      NOT NULL,
    [PCOMMENT]   NTEXT            NULL,
    [CREATEFLAG] INT              NULL,
    [INDEX_STR]  NVARCHAR (250)   NULL,
    [EQID]       INT              NULL,
    [SWVERID]    INT              NULL,
    [SN]         NVARCHAR (50)    NULL,
    [TYPEID]     INT              NULL,
    [NEW_VAL]    SQL_VARIANT      NULL,
    [CONVERTED]  BIT              CONSTRAINT [DF_PR_OPERATION_PARAMS_BACKUP_KB3439_TEMP_CONVERTED] DEFAULT ((0)) NULL
);

