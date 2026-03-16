CREATE TABLE [dbo].[todel_FC_REPORT_EXTANALYSIS_CODES] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [VNESHID]        INT              NOT NULL,
    [ANALYSISCODEID] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_REPORT_EXTANALYSIS_CODES]
    ON [dbo].[todel_FC_REPORT_EXTANALYSIS_CODES]([VNESHID] ASC) WITH (FILLFACTOR = 90);

