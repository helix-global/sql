CREATE TABLE [dbo].[FC_FAILUREPARAMS] (
    [ID]                INT              IDENTITY (1, 1) NOT NULL,
    [GID]               UNIQUEIDENTIFIER NULL,
    [S_CR]              INT              NOT NULL,
    [S_CDT]             DATETIME         NOT NULL,
    [S_MR]              INT              NULL,
    [S_MDT]             DATETIME         NULL,
    [ARC]               INT              NULL,
    [NAME]              NVARCHAR (200)   NOT NULL,
    [DESCRIPTION]       NTEXT            NULL,
    [CAPTION]           NVARCHAR (400)   NULL,
    [DATATYPE]          INT              NULL,
    [FCODEID]           INT              NULL,
    [MTID]              INT              NOT NULL,
    [PRINT_IN_REP]      INT              NULL,
    [USE_IN_LIST]       INT              NULL,
    [VALREQUIRED]       INT              NULL,
    [VALREQUIRED_INPUT] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_FAILUREPARAMS_FCODEID] FOREIGN KEY ([FCODEID]) REFERENCES [dbo].[FC_FAILURECODES] ([ID]),
    CONSTRAINT [FK_FC_FAILUREPARAMS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);

