CREATE TABLE [dbo].[PR_REV_CHANGINGS_FILES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [VNESHID]     INT              NOT NULL,
    [FILENAME]    NVARCHAR (255)   NOT NULL,
    [FILEDATE]    DATETIME         NOT NULL,
    [FILESIZE]    INT              NULL,
    [FILEBLOB]    IMAGE            NULL,
    [FILEDESC]    NTEXT            NULL,
    [FILEPREVIEW] IMAGE            NULL,
    [FILEHIDDEN]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_REV_CHANGINGS_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[PR_REV_CHANGINGS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REV_CHANGINGS_FILES]
    ON [dbo].[PR_REV_CHANGINGS_FILES]([VNESHID] ASC);

