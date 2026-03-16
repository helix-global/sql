CREATE TABLE [dbo].[DEF_FEEDBACK] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_S]          INT              NOT NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [SUBJECT]      NVARCHAR (400)   NOT NULL,
    [DESCRIPTION]  NTEXT            NULL,
    [FEEDBACKTYPE] INT              NOT NULL,
    [RESOLUTION]   NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

