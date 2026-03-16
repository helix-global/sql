CREATE TABLE [dbo].[SW_GROUP_SHARING] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [VNESHID]          INT              NOT NULL,
    [DEPARTMENTID]     INT              NOT NULL,
    [ALLOW_LINK_FILES] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SW_GROUP_SHARING_DEPARTMENTID] FOREIGN KEY ([DEPARTMENTID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_SW_GROUP_SHARING_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[SW_TOOL_GROUPS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SW_GROUP_SHARING]
    ON [dbo].[SW_GROUP_SHARING]([VNESHID] ASC);

