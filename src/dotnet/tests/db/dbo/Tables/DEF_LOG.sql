CREATE TABLE [dbo].[DEF_LOG] (
    [ID]          INT            IDENTITY (1, 1) NOT NULL,
    [DD]          DATETIME       NOT NULL,
    [LEV]         INT            NOT NULL,
    [CAPTION]     NVARCHAR (400) NOT NULL,
    [S_USERID]    INT            NOT NULL,
    [EV_TEXT]     NTEXT          NULL,
    [DOCOID]      INT            NULL,
    [DOCID]       INT            NULL,
    [EV_TYPE]     INT            NOT NULL,
    [EV_TEXT_ZIP] IMAGE          NULL,
    [ADDINFO]     NTEXT          NULL,
    [PDBCLI]      NVARCHAR (32)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_DEF_LOG_EV_TYPE]
    ON [dbo].[DEF_LOG]([EV_TYPE] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DEF_LOG_DOC]
    ON [dbo].[DEF_LOG]([DOCOID] ASC, [DOCID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_DEF_LOG]
    ON [dbo].[DEF_LOG]([DD] ASC, [S_USERID] ASC)
    INCLUDE([LEV]);

