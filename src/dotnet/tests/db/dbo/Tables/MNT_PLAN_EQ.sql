CREATE TABLE [dbo].[MNT_PLAN_EQ] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [VNESHID]         INT              NOT NULL,
    [EQID]            INT              NOT NULL,
    [LASTDATE]        DATETIME         NULL,
    [NEXTDATE]        DATETIME         NULL,
    [LEMODE]          INT              NULL,
    [WORKCYCLES]      INT              NULL,
    [NEXTDATE_FROZEN] INT              DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MNT_PLAN_EQ_EQID] FOREIGN KEY ([EQID]) REFERENCES [dbo].[EQ_EQUIPMENT] ([ID]),
    CONSTRAINT [FK_MNT_PLAN_EQ_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[MNT_PLAN] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_MNT_PLAN_EQ_EQID]
    ON [dbo].[MNT_PLAN_EQ]([EQID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MNT_PLAN_EQ_2]
    ON [dbo].[MNT_PLAN_EQ]([VNESHID] ASC, [EQID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MNT_PLAN_EQ]
    ON [dbo].[MNT_PLAN_EQ]([VNESHID] ASC);

