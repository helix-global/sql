CREATE TABLE [dbo].[SH_TRANS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [NAME]       NVARCHAR (150)   NOT NULL,
    [FORMATTYPE] INT              NOT NULL,
    [OUTPATH]    NVARCHAR (250)   NULL,
    [TRANSTYPE]  INT              NOT NULL,
    [REMARK]     NTEXT            NULL,
    [INPATH]     NVARCHAR (250)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

