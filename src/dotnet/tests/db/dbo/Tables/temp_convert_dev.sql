CREATE TABLE [dbo].[temp_convert_dev] (
    [SESSIONID]       NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [SN]              NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [PRODUCTIONORDER] NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [DEVICEID]        INT           NULL,
    [ORDERID]         INT           NULL,
    [OPERID]          INT           NULL
);

