CREATE TABLE [dbo].[PR_ACTIVECONTROLS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [NAME]        NVARCHAR (100)   NOT NULL,
    [DESCRIPTION] NTEXT            NULL,
    [NCLASS]      NVARCHAR (120)   NOT NULL,
    [NOINPUT]     INT              NULL,
    [RESTRACCESS] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

