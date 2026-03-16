CREATE TABLE [dbo].[SL_REQ_OPTIONS] (
    [ID]          INT            NOT NULL,
    [S_CR]        INT            NULL,
    [S_CDT]       DATETIME       NULL,
    [S_MR]        INT            NULL,
    [S_MDT]       DATETIME       NULL,
    [MODELID]     INT            NOT NULL,
    [OPTIONGRID]  INT            NOT NULL,
    [OPTIONGRID2] INT            NULL,
    [OPTIONGRID3] INT            NULL,
    [GRNAME]      NVARCHAR (300) NULL,
    [GR2NAME]     NVARCHAR (300) NULL,
    [GR3NAME]     NVARCHAR (300) NULL,
    [OPTIONGRID4] INT            NULL,
    [OPTIONGRID5] INT            NULL,
    [GR4NAME]     NVARCHAR (300) NULL,
    [GR5NAME]     NVARCHAR (300) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

