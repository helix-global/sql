CREATE TABLE [dbo].[PR_TROUBLE_TEMPLATES] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [DEPID]   INT              NOT NULL,
    [NAME]    NVARCHAR (200)   NOT NULL,
    [MTID]    INT              NOT NULL,
    [REMARK]  NTEXT            NULL,
    [SHARETO] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_TROUBLE_TEMPLATES_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_TROUBLE_TEMPLATES_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);

