CREATE TABLE [dbo].[HH_CV_FILES] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [VNESHID]  INT              NOT NULL,
    [FILENAME] NVARCHAR (255)   NOT NULL,
    [FILESIZE] INT              NOT NULL,
    [FILEDESC] NTEXT            NULL,
    [FILEDATE] DATETIME         NOT NULL,
    [FILEBLOB] IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_HH_CV_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[HH_CV] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_HH_CV_FILES]
    ON [dbo].[HH_CV_FILES]([VNESHID] ASC);

