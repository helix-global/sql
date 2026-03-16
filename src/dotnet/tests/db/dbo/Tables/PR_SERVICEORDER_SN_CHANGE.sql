CREATE TABLE [dbo].[PR_SERVICEORDER_SN_CHANGE] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_S]        INT              NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [SRVORDERID] INT              NULL,
    [REMARK]     NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_SERVICEORDER_SN_CHANGE_SRVORDERID] FOREIGN KEY ([SRVORDERID]) REFERENCES [dbo].[PR_PRORDER] ([ID])
);

