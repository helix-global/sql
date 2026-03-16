CREATE TABLE [dbo].[FC_FAILUREANALYSISCODES] (
    [ID]                INT              IDENTITY (1, 1) NOT NULL,
    [GID]               UNIQUEIDENTIFIER NULL,
    [S_CR]              INT              NULL,
    [S_CDT]             DATETIME         NOT NULL,
    [S_MR]              INT              NULL,
    [S_MDT]             DATETIME         NULL,
    [ARC]               INT              NULL,
    [NAME]              NVARCHAR (200)   NOT NULL,
    [DESCRIPTION]       NTEXT            NULL,
    [S_S]               INT              NOT NULL,
    [POSORDER]          INT              NULL,
    [REQ_FAR]           INT              NULL,
    [NOTCONFIRMED]      INT              NULL,
    [REQ_HER]           INT              NULL,
    [FAILURERATE]       DECIMAL (14, 2)  NULL,
    [MTID]              INT              NOT NULL,
    [TEMP_OLDID]        INT              NULL,
    [TEMP_WASADDED]     INT              NULL,
    [EXT_NAME]          NVARCHAR (200)   NULL,
    [EXT]               INT              NULL,
    [EXTCODEOWNERDEPID] INT              NULL,
    [ENDDEIID]          INT              NULL,
    [INCL_IN_PARENT]    INT              NULL,
    [HUMAN_ERROR]       INT              NULL,
    [QACODE]            INT              NULL,
    [EXTFCODE]          INT              NULL,
    [CAPTION]           NVARCHAR (400)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FC_FAILUREANALYSISCODES_ENDDEIID] FOREIGN KEY ([ENDDEIID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_FC_FAILUREANALYSISCODES_EXTCODEOWNERDEPID] FOREIGN KEY ([EXTCODEOWNERDEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_FC_FAILUREANALYSISCODES_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_FAILUREANALYSISCODES_OLDID]
    ON [dbo].[FC_FAILUREANALYSISCODES]([TEMP_OLDID] ASC);

