CREATE TABLE [report].[FBA_ACCEPTED_ITEMS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [DEVICE_ID]      INT              NOT NULL,
    [ACCEPTED_VALUE] NVARCHAR (1)     NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK__DEVICE_ID] FOREIGN KEY ([DEVICE_ID]) REFERENCES [dbo].[PR_DEVICE] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FBA_ACCEPTED_ITEMS_DEVICEID]
    ON [report].[FBA_ACCEPTED_ITEMS]([DEVICE_ID] ASC) WHERE ([DEVICE_ID] IS NOT NULL);

