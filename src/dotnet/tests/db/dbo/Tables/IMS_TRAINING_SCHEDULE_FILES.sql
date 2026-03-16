CREATE TABLE [dbo].[IMS_TRAINING_SCHEDULE_FILES] (
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
    CONSTRAINT [FK_IMS_TRAINING_SCHEDULE_FILES_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[IMS_TRAINING_SCHEDULE] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_IMS_TRAINING_SCHEDULE_FILES]
    ON [dbo].[IMS_TRAINING_SCHEDULE_FILES]([VNESHID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KB2931 - IMS - Changes for Qualification -> Training*', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMS_TRAINING_SCHEDULE_FILES';

