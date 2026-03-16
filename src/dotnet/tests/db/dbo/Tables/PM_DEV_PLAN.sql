CREATE TABLE [dbo].[PM_DEV_PLAN] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NOT NULL,
    [S_S]             INT              NOT NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [EMPLID]          INT              NOT NULL,
    [DD]              DATETIME         NOT NULL,
    [REMARK]          NTEXT            NULL,
    [REJECTIONREMARK] NTEXT            NULL,
    [REJECTIONDT]     DATETIME         NULL,
    [REJECTIONBY]     INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PM_DEV_PLAN_EMPLID] FOREIGN KEY ([EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PM_DEV_PLAN_EMPLID]
    ON [dbo].[PM_DEV_PLAN]([EMPLID] ASC);

