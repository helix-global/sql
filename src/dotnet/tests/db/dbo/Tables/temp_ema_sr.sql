CREATE TABLE [dbo].[temp_ema_sr] (
    [ID]       INT            NOT NULL,
    [S_S]      INT            NULL,
    [PVALUE]   SQL_VARIANT    NULL,
    [SN]       NVARCHAR (50)  NOT NULL,
    [NN]       NVARCHAR (20)  NULL,
    [CODE]     NVARCHAR (16)  NULL,
    [NAME]     NVARCHAR (200) NULL,
    [HOSTSN]   NVARCHAR (50)  NULL,
    [HOSTCODE] NVARCHAR (16)  NULL,
    [HOLTNAME] NVARCHAR (200) NULL
);

