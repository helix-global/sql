CREATE TABLE [dbo].[SM_SERVICETASK_FILES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [VNESHID]     INT              NOT NULL,
    [FILENAME]    NVARCHAR (255)   NULL,
    [FILESIZE]    INT              NULL,
    [FILEDESC]    NTEXT            NULL,
    [FILEDATE]    DATE             NULL,
    [FILEBLOB]    IMAGE            NULL,
    [FILEPREVIEW] IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_SERVICETASK_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[SM_SERVICETASKS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SM_SERVICETASK_FILES]
    ON [dbo].[SM_SERVICETASK_FILES]([VNESHID] ASC);

