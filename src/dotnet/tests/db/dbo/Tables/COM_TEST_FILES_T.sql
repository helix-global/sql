CREATE TABLE [dbo].[COM_TEST_FILES_T] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [VNESHID]     INT              NOT NULL,
    [FILENAME]    NVARCHAR (250)   NOT NULL,
    [FILEDATE]    DATETIME         NOT NULL,
    [FILESIZE]    INT              NULL,
    [FILEBLOB]    IMAGE            NULL,
    [FILEDESC]    NTEXT            NULL,
    [FILEPREVIEW] IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_TEST_FILES_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[COM_TEST_FILES] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_TEST_FILES_T]
    ON [dbo].[COM_TEST_FILES_T]([VNESHID] ASC);

