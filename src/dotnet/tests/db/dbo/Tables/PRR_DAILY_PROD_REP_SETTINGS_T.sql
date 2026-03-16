CREATE TABLE [dbo].[PRR_DAILY_PROD_REP_SETTINGS_T] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [VNESHID]      INT              NOT NULL,
    [MODELID]      INT              NULL,
    [MODELGROUPID] INT              NULL,
    [POSITION]     INT              NULL,
    [HEADER1]      NVARCHAR (512)   NULL,
    [HEADER2]      NVARCHAR (512)   NULL,
    [HEADER3]      NVARCHAR (512)   NULL,
    [ISVISIBLE]    INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PRR_DAILY_PROD_REP_SETTINGS_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[PRR_DAILY_PROD_REP_SETTINGS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PRR_DAILY_PROD_REP_SETTINGS_T]
    ON [dbo].[PRR_DAILY_PROD_REP_SETTINGS_T]([VNESHID] ASC);

