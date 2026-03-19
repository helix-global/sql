CREATE TABLE [dbo].[SW_TOOLS] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_S]          INT              NOT NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [NAME]         NVARCHAR (200)   NOT NULL,
    [DESCRIPTION]  NTEXT            NULL,
    [GROUPID]      INT              NOT NULL,
    [TOOLTYPE]     INT              NOT NULL,
    [DESCSTR]      NVARCHAR (250)   NULL,
    [ITEMTAGS]     NVARCHAR (300)   NULL,
    [ACCVIEW]      INT              NULL,
    [EXTSIZELIMIT] INT              NULL,
    [CODE]         NVARCHAR (20)    NOT NULL,
    [OLDCODE]      NVARCHAR (20)    NULL,
    [CRMGUID]      UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SW_TOOLS_GROUPID] FOREIGN KEY ([GROUPID]) REFERENCES [dbo].[SW_TOOL_GROUPS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SW_TOOLS_GID]
    ON [dbo].[SW_TOOLS]([GID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SW_TOOLS_CODE]
    ON [dbo].[SW_TOOLS]([CODE] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SW_TOOLS]
    ON [dbo].[SW_TOOLS]([GROUPID] ASC);

