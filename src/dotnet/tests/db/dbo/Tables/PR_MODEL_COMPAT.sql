CREATE TABLE [dbo].[PR_MODEL_COMPAT] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NOT NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [DEPID]           INT              NOT NULL,
    [MTID]            INT              NOT NULL,
    [REMARK]          NTEXT            NULL,
    [COMPATWITH_MTID] INT              NOT NULL,
    [CMODE]           INT              NOT NULL,
    [CRMGUID]         UNIQUEIDENTIFIER NULL,
    [TS]              ROWVERSION       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_MODEL_COMPAT_COMPATWITH_MTID] FOREIGN KEY ([COMPATWITH_MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID]),
    CONSTRAINT [FK_PR_MODEL_COMPAT_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_MODEL_COMPAT_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);

