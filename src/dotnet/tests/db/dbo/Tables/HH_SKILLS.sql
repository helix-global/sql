CREATE TABLE [dbo].[HH_SKILLS] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [VHESHID] INT              NOT NULL,
    [NAME]    NVARCHAR (250)   NOT NULL,
    [LVL]     INT              NOT NULL,
    [REMARK]  NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_HH_SKILLS_VHESHID] FOREIGN KEY ([VHESHID]) REFERENCES [dbo].[HH_PROJECT] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_HH_SKILLS]
    ON [dbo].[HH_SKILLS]([VHESHID] ASC);

