CREATE TABLE [dbo].[FC_CORRACTIONS_FILES] (
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
    CONSTRAINT [FK_FC_CORRACTIONS_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[FC_CORRACTIONS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_CORRACTIONS_FILES]
    ON [dbo].[FC_CORRACTIONS_FILES]([VNESHID] ASC);

