CREATE TABLE [dbo].[FC_A_HISTORY] (
    [ID]                 INT              IDENTITY (1, 1) NOT NULL,
    [GID]                UNIQUEIDENTIFIER NULL,
    [S_CR]               INT              NOT NULL,
    [S_CDT]              DATETIME         NOT NULL,
    [S_MR]               INT              NULL,
    [S_MDT]              DATETIME         NULL,
    [ARC]                INT              NULL,
    [FRID]               INT              NOT NULL,
    [DD]                 DATETIME         NOT NULL,
    [ND]                 NVARCHAR (30)    NOT NULL,
    [REPORTBODY]         IMAGE            NULL,
    [ISSUEDBY]           INT              NULL,
    [APPBY]              INT              NULL,
    [PRELIMINARY]        INT              NULL,
    [MODELID]            INT              NULL,
    [SN]                 NVARCHAR (50)    NULL,
    [RMA]                NVARCHAR (40)    NULL,
    [RMA_TYPE]           INT              NULL,
    [FROMCUSTOMERID]     INT              NULL,
    [DATE_OF_RETURN]     DATETIME         NULL,
    [FAILUREDESCRIPTION] NVARCHAR (1000)  NULL,
    [FAILURE_ANALYSIS]   NVARCHAR (1000)  NULL,
    [ACTIONPOINTS]       NVARCHAR (1000)  NULL,
    [NND]                NVARCHAR (50)    NULL,
    [NNDN]               INT              NULL,
    [REPORTFILENAME]     NVARCHAR (250)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_A_HISTORY_APPBY] FOREIGN KEY ([APPBY]) REFERENCES [dbo].[DEF_USERS] ([ID]),
    CONSTRAINT [FK_FC_A_HISTORY_FRID] FOREIGN KEY ([FRID]) REFERENCES [dbo].[FC_REPORT] ([ID]),
    CONSTRAINT [FK_FC_A_HISTORY_FROMCUSTOMERID] FOREIGN KEY ([FROMCUSTOMERID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_FC_A_HISTORY_ISSUEDBY] FOREIGN KEY ([ISSUEDBY]) REFERENCES [dbo].[DEF_USERS] ([ID]),
    CONSTRAINT [FK_FC_A_HISTORY_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_A_HISTORY_FRID]
    ON [dbo].[FC_A_HISTORY]([FRID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FC_A_HISTORY_1]
    ON [dbo].[FC_A_HISTORY]([NND] ASC);

