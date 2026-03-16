CREATE TABLE [dbo].[IE_ITEMPOSITIONS] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NOT NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [NAME]     NVARCHAR (150)   NOT NULL,
    [DESCSTR]  NTEXT            NULL,
    [REQUIRED] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

