CREATE TABLE [dbo].[PR_DEVICE_WAS_ARCHIVED] (
    [ID]                    INT            IDENTITY (1, 1) NOT NULL,
    [S_CR]                  INT            NULL,
    [S_CDT]                 DATETIME       NULL,
    [DEVICEID]              INT            NOT NULL,
    [ORDERID]               INT            NOT NULL,
    [LASTCHANGES_TIMESTAMP] DATETIME       NOT NULL,
    [OUTPATH]               NVARCHAR (255) NULL,
    [ERR]                   INT            NULL,
    [FILESIZE]              INT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_DEVICE_WAS_ARCHIVED_ERR]
    ON [dbo].[PR_DEVICE_WAS_ARCHIVED]([ERR] ASC) WHERE ([ERR] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_DEVICE_WAS_ARCHIVED]
    ON [dbo].[PR_DEVICE_WAS_ARCHIVED]([DEVICEID] ASC, [ORDERID] ASC, [LASTCHANGES_TIMESTAMP] ASC);

