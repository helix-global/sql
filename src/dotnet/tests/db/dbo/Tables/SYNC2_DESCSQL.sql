CREATE TABLE [dbo].[SYNC2_DESCSQL] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [TABLENAME] NVARCHAR (100)   NOT NULL,
    [DESCSQL]   NTEXT            NOT NULL,
    [REMARK]    NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SYNC2_DESCSQL_TNAME]
    ON [dbo].[SYNC2_DESCSQL]([TABLENAME] ASC);

