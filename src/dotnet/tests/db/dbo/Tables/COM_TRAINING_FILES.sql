CREATE TABLE [dbo].[COM_TRAINING_FILES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [VNESHID]     INT              NOT NULL,
    [FILEDESC]    NTEXT            NULL,
    [FILEDATE]    DATETIME         NULL,
    [FILENAME]    NVARCHAR (255)   NULL,
    [FILEBLOB]    IMAGE            NULL,
    [FILESIZE]    INT              NOT NULL,
    [FILEPREVIEW] IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_TRAINING_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[COM_TRAINING] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_TRAINING_FILES]
    ON [dbo].[COM_TRAINING_FILES]([VNESHID] ASC);

