CREATE TABLE [dbo].[PR_DEVICE_STATVALUES] (
    [DEVICEID]              INT             NOT NULL,
    [ORDERID]               INT             NOT NULL,
    [ELAPSED]               INT             NULL,
    [WAITED]                INT             NULL,
    [DURATION]              INT             NULL,
    [CYCLEFROMBEGIN]        INT             NULL,
    [CYCLEFROM1OPER]        INT             NULL,
    [ELAPSEDTROUBLE]        INT             NULL,
    [ELAPSEDWITHOUTTROUBLE] INT             NULL,
    [WASTROUBLE]            INT             NULL,
    [UNINSTALLED]           INT             NULL,
    [WAITBEFORE1OPERSTART]  INT             NULL,
    [ELAPSED_D]             DECIMAL (12, 2) NULL,
    [CYCLEFROM1OPER_D]      DECIMAL (12, 2) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_PR_DEVICE_STAT]
    ON [dbo].[PR_DEVICE_STATVALUES]([DEVICEID] ASC, [ORDERID] ASC);

