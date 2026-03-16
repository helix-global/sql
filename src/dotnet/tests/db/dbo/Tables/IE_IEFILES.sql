CREATE TABLE [dbo].[IE_IEFILES] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NOT NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [VNESHID]  INT              NOT NULL,
    [FILENAME] NVARCHAR (255)   NOT NULL,
    [FILESIZE] INT              NOT NULL,
    [FILEDESC] NTEXT            NULL,
    [FILEDATE] DATE             NOT NULL,
    [FILEBLOB] IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IE_IEFILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[IE_IE] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_IE_IEFILES]
    ON [dbo].[IE_IEFILES]([VNESHID] ASC);

