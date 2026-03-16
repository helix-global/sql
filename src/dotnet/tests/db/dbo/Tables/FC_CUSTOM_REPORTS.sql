CREATE TABLE [dbo].[FC_CUSTOM_REPORTS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_S]            INT              NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [FORMXML]        NTEXT            NULL,
    [NAME]           NVARCHAR (100)   NOT NULL,
    [DESCRIPTION]    NTEXT            NULL,
    [REPLACEDEFAULT] INT              NULL,
    [MTID]           INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_CUSTOM_REPORTS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);

