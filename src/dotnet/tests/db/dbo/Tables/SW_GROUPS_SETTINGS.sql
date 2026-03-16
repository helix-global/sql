CREATE TABLE [dbo].[SW_GROUPS_SETTINGS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [SWGRID]     INT              NOT NULL,
    [REMARK]     NTEXT            NULL,
    [DISABLE_AN] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SW_GROUPS_SETTINGS_SWGRID] FOREIGN KEY ([SWGRID]) REFERENCES [dbo].[SW_TOOL_GROUPS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SW_GROUPS_SETTINGS]
    ON [dbo].[SW_GROUPS_SETTINGS]([SWGRID] ASC);

