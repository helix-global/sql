CREATE TABLE [dbo].[PR_DEVICE_A_FILES] (
    [ID]                    INT              IDENTITY (1, 1) NOT NULL,
    [GID]                   UNIQUEIDENTIFIER NULL,
    [S_CR]                  INT              NOT NULL,
    [S_CDT]                 DATETIME         NOT NULL,
    [S_MR]                  INT              NULL,
    [S_MDT]                 DATETIME         NULL,
    [ARC]                   INT              NULL,
    [DEVICEID]              INT              NOT NULL,
    [FILENAME]              NVARCHAR (255)   NOT NULL,
    [FILESIZE]              INT              NOT NULL,
    [FILEDESC]              NTEXT            NULL,
    [FILEDATE]              DATETIME         NULL,
    [FILEBLOB]              IMAGE            NULL,
    [FILEPREVIEW]           IMAGE            NULL,
    [ORDERID]               INT              NULL,
    [LASTCHANGES_TIMESTAMP] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_DEVICE_A_FILES_DEVICEID] FOREIGN KEY ([DEVICEID]) REFERENCES [dbo].[PR_DEVICE] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_DEVICE_FILES_ORD]
    ON [dbo].[PR_DEVICE_A_FILES]([DEVICEID] ASC, [ORDERID] ASC, [LASTCHANGES_TIMESTAMP] ASC) WHERE ([ORDERID] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_PR_DEVICE_FILES]
    ON [dbo].[PR_DEVICE_A_FILES]([DEVICEID] ASC);

