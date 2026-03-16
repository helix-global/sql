CREATE TABLE [dbo].[FC_FORMS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [FORMXML]     NTEXT            NULL,
    [NAME]        NVARCHAR (100)   NOT NULL,
    [DESCRIPTION] NTEXT            NULL,
    [S_S]         INT              NULL,
    [FTYPE]       INT              NULL,
    [MTID]        INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_FORMS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);

