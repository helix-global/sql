CREATE TABLE [dbo].[PR_PRORDER_FILES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [VNESHID]     INT              NOT NULL,
    [FILENAME]    NVARCHAR (255)   NULL,
    [FILESIZE]    INT              NOT NULL,
    [FILEDESC]    NTEXT            NULL,
    [FILEDATE]    DATETIME         NULL,
    [FILEBLOB]    IMAGE            NULL,
    [FILEPREVIEW] IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_PRORDER_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[PR_PRORDER] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_PRORDER_FILES]
    ON [dbo].[PR_PRORDER_FILES]([VNESHID] ASC) WITH (FILLFACTOR = 90);

