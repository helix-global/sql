CREATE TABLE [dbo].[DEF_VER_HIST] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [VERSIONN]    NVARCHAR (50)    NOT NULL,
    [DESCRIPTION] NTEXT            NULL,
    [RDATE]       DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_VER_HIST]
    ON [dbo].[DEF_VER_HIST]([VERSIONN] ASC);

