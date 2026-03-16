CREATE TABLE [dbo].[temp_40_ship] (
    [ID]                  INT           NOT NULL,
    [SN]                  NVARCHAR (50) NOT NULL,
    [SHIPPED_DT]          DATETIME      NULL,
    [LAST_OPERATION_CMPL] DATETIME      NULL,
    [SERVORDID]           INT           NULL,
    [COMPLETED_DT]        DATETIME      NULL
);

