CREATE TABLE [dbo].[SM_SERVICECALL_FILES] (
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
    CONSTRAINT [FK_SM_SERVICECALL_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[SM_SERVICECALL] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SM_SERVICECALL_FILES]
    ON [dbo].[SM_SERVICECALL_FILES]([VNESHID] ASC);

