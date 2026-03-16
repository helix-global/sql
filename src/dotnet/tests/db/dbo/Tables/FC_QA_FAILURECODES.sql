CREATE TABLE [dbo].[FC_QA_FAILURECODES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [NAME]        NVARCHAR (250)   NOT NULL,
    [QACODE1]     NVARCHAR (100)   NOT NULL,
    [QACODE2]     NVARCHAR (100)   NOT NULL,
    [DESCRIPTION] NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

