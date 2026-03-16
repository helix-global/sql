CREATE TABLE [dbo].[temp_need_add_from_IPM] (
    [ID]                  INT             IDENTITY (1, 1) NOT NULL,
    [F0]                  NVARCHAR (2048) NULL,
    [F1]                  NVARCHAR (2048) NULL,
    [F2]                  NVARCHAR (2048) NULL,
    [F3]                  NVARCHAR (2048) NULL,
    [F4]                  NVARCHAR (2048) NULL,
    [DEVICEID]            INT             NULL,
    [BOMID]               INT             NULL,
    [MODELID]             INT             NULL,
    [MTID]                INT             NULL,
    [PARTEXISTS]          INT             NULL,
    [PARTMODELID]         INT             NULL,
    [INSTALLOPERID]       INT             NULL,
    [PARTID]              INT             NULL,
    [EXISTINGPARTMODELID] INT             NULL
);

