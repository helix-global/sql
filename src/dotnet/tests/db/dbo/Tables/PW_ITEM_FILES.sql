CREATE TABLE [dbo].[PW_ITEM_FILES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [VNESHID]     INT              NOT NULL,
    [FILEDESC]    NTEXT            NULL,
    [FILEDATE]    DATE             NULL,
    [FILENAME]    NVARCHAR (255)   NULL,
    [FILEBLOB]    IMAGE            NULL,
    [FILESIZE]    INT              NOT NULL,
    [FILEPREVIEW] IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PW_ITEM_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[PW_ITEMS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PW_ITEM_FILES]
    ON [dbo].[PW_ITEM_FILES]([VNESHID] ASC);

