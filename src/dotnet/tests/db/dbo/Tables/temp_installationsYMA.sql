CREATE TABLE [dbo].[temp_installationsYMA] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [OPERID]       INT              NOT NULL,
    [PARTID]       INT              NULL,
    [BOMID]        INT              NULL,
    [SN]           NVARCHAR (50)    NOT NULL,
    [PARTMODELID]  INT              NULL,
    [REMARK]       NVARCHAR (250)   NULL,
    [PARTQUANTITY] DECIMAL (20, 10) NULL,
    [BATCHN]       NVARCHAR (100)   NULL,
    [CREATEFLAG]   INT              NULL
);

