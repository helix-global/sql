CREATE TABLE [dbo].[PM_DEV_PLAN_T_T] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NOT NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [VNESHID] INT              NOT NULL,
    [DD]      DATE             NOT NULL,
    [MHOUR]   DECIMAL (10, 2)  NOT NULL,
    [REMARK]  NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PM_DEV_PLAN_T_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[PM_DEV_PLAN_T] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PM_DEV_PLAN_T_T]
    ON [dbo].[PM_DEV_PLAN_T_T]([VNESHID] ASC);

