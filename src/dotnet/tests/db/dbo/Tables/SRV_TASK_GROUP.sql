CREATE TABLE [dbo].[SRV_TASK_GROUP] (
    [ID]      INT             IDENTITY (1, 1) NOT NULL,
    [OID]     INT             NOT NULL,
    [S_S]     INT             NOT NULL,
    [S_CR]    INT             NOT NULL,
    [S_MR]    INT             NULL,
    [S_CDT]   DATETIME        NOT NULL,
    [S_MDT]   DATETIME        NULL,
    [LABL]    NVARCHAR (256)  NOT NULL,
    [NAME]    NVARCHAR (2048) NOT NULL,
    [DESC]    NTEXT           NULL,
    [OPTIONS] NVARCHAR (512)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

