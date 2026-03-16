CREATE TABLE [dbo].[temp_sh_4] (
    [ID]          INT             IDENTITY (1, 1) NOT NULL,
    [SN]          NVARCHAR (200)  NULL,
    [DESCR]       NVARCHAR (4000) NULL,
    [URSACHE]     NVARCHAR (4000) NULL,
    [DEVICEID]    INT             NULL,
    [MODELID]     INT             NULL,
    [MODELTYPEID] INT             NULL,
    [FCODE_FOUND] BIT             CONSTRAINT [DF_temp_sh_4_FCODE_FOUND] DEFAULT ((0)) NOT NULL,
    [QTY]         INT             NULL,
    CONSTRAINT [PK_temp_sh_4] PRIMARY KEY CLUSTERED ([ID] ASC)
);

