CREATE TABLE [dbo].[PR_MOF_SWAP] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [S_S]       INT              NOT NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [DEPID]     INT              NOT NULL,
    [DD]        DATETIME         NOT NULL,
    [DEVICE1ID] INT              NOT NULL,
    [DEVICE2ID] INT              NOT NULL,
    [REMARK]    NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_MOF_SWAP_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_MOF_SWAP_DEVICE1ID] FOREIGN KEY ([DEVICE1ID]) REFERENCES [dbo].[PR_DEVICE] ([ID]),
    CONSTRAINT [FK_PR_MOF_SWAP_DEVICE2ID] FOREIGN KEY ([DEVICE2ID]) REFERENCES [dbo].[PR_DEVICE] ([ID])
);

