CREATE TABLE [dbo].[SH_ORDER_T] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [SHORDERID]     INT              NOT NULL,
    [DEVICEID]      INT              NOT NULL,
    [DEV_PR_SS]     INT              NULL,
    [S_S]           INT              NULL,
    [QTYTOSHIP]     INT              NULL,
    [TRMODE]        INT              NULL,
    [APNAV]         INT              NULL,
    [SHIPPINGSTOCK] NVARCHAR (50)    NULL,
    [CHECK_EMPLID]  INT              NULL,
    [CHECK_DATE]    DATETIME         NULL,
    [ARC]           INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SH_ORDER_T_CHECK_EMPLID] FOREIGN KEY ([CHECK_EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_SH_ORDER_T_DEVICEID] FOREIGN KEY ([DEVICEID]) REFERENCES [dbo].[PR_DEVICE] ([ID]),
    CONSTRAINT [FK_SH_ORDER_T_SHORDERID] FOREIGN KEY ([SHORDERID]) REFERENCES [dbo].[SH_ORDER] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SH_ORDER_T_TRMODE]
    ON [dbo].[SH_ORDER_T]([TRMODE] ASC) WHERE ([TRMODE] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_SH_ORDER_T_2]
    ON [dbo].[SH_ORDER_T]([SHORDERID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SH_ORDER_T_1]
    ON [dbo].[SH_ORDER_T]([DEVICEID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SH_ORDER_T]
    ON [dbo].[SH_ORDER_T]([SHORDERID] ASC, [DEVICEID] ASC);


GO
CREATE trigger [dbo].[SH_ORDER_T_DEL] on [dbo].[SH_ORDER_T]
FOR delete
as 
  set nocount on
  
  if exists (select * from deleted A 
             left join PR_DEVICE B on B.ID = A.DEVICEID
              where A.S_S = 1000106 
                and B.S_S <> 1000010
            )
    raiserror('Cannot delete this shipment. Device state was modified.[L=sh_cannot_modified',16,1)

 
  if exists (select * from deleted A 
              where A.S_S = 1000106 
                and exists (select B.ID from SH_ORDER_T B where B.DEVICEID = A.DEVICEID and B.ID > A.ID)
                and not exists (select I.ID from inserted I where I.ID = A.ID)
            )
    raiserror('Cannot delete this shipment. Only last shipment record can be deleted.[L=sh_cannot_only_last',16,1)

  
  set nocount off