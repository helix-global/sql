CREATE TABLE [dbo].[IC_SRVOPER_RESULT] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NOT NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [SRVORDER]     NVARCHAR (50)    NOT NULL,
    [S_S]          INT              NOT NULL,
    [ERRORS]       NTEXT            NULL,
    [DEVICEOPERID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IC_SRVOPER_RESULT_SRVORDER]
    ON [dbo].[IC_SRVOPER_RESULT]([SRVORDER] ASC);

