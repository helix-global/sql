CREATE TABLE [dbo].[SW_TOOL_GROUPS] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [NAME]          NVARCHAR (200)   NOT NULL,
    [DEPID]         INT              NOT NULL,
    [SHARETOALL]    INT              NULL,
    [CATEGORY]      NVARCHAR (100)   NULL,
    [HIDE_IN_OPERS] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SW_TOOL_GROUPS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SW_TOOL_GROUPS_GID]
    ON [dbo].[SW_TOOL_GROUPS]([GID] ASC);

