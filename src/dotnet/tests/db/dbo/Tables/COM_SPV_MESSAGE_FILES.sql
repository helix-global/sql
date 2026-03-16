CREATE TABLE [dbo].[COM_SPV_MESSAGE_FILES] (
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
    [ISOPENED]    INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_SPV_MESSAGE_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[COM_SPV_MESSAGE] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_SPV_MESSAGE_FILES]
    ON [dbo].[COM_SPV_MESSAGE_FILES]([VNESHID] ASC);

