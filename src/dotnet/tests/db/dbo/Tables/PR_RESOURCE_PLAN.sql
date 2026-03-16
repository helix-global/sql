CREATE TABLE [dbo].[PR_RESOURCE_PLAN] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [DEPID]       INT              NULL,
    [FROMDT]      DATETIME         NULL,
    [TODT]        DATETIME         NULL,
    [XML]         NTEXT            NULL,
    [NAME]        NVARCHAR (255)   NULL,
    [CHANGES_XML] NTEXT            NULL,
    [APPLYDT]     DATETIME         NULL,
    [LURID]       INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_RESOURCE_PLAN_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_RESOURCE_PLAN_LURID] FOREIGN KEY ([LURID]) REFERENCES [dbo].[PRR_LU_REPORT_REQUEST] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_RESOURCE_PLAN]
    ON [dbo].[PR_RESOURCE_PLAN]([DEPID] ASC, [FROMDT] ASC, [TODT] ASC)
    INCLUDE([APPLYDT]) WHERE ([APPLYDT] IS NOT NULL);

