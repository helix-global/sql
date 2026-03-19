CREATE TABLE [dbo].[PR_PRINTED_REPORTS] (
    [ID]        INT           IDENTITY (1, 1) NOT NULL,
    [OPERID]    INT           NOT NULL,
    [REPORTID]  INT           NOT NULL,
    [S_CDT]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [S_CR]      INT           NOT NULL,
    [SESSIONID] NVARCHAR (40) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

