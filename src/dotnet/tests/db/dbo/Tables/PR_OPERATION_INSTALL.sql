CREATE TABLE [dbo].[PR_OPERATION_INSTALL] (
    [ID]                      INT              IDENTITY (1, 1) NOT NULL,
    [GID]                     UNIQUEIDENTIFIER NULL,
    [S_CR]                    INT              NOT NULL,
    [S_CDT]                   DATETIME         NOT NULL,
    [S_MR]                    INT              NULL,
    [S_MDT]                   DATETIME         NULL,
    [ARC]                     INT              NULL,
    [OPERID]                  INT              NOT NULL,
    [PARTID]                  INT              NULL,
    [BOMID]                   INT              NULL,
    [SN]                      NVARCHAR (50)    NOT NULL,
    [PARTMODELID]             INT              NULL,
    [REMARK]                  NVARCHAR (250)   NULL,
    [PARTQUANTITY]            DECIMAL (20, 10) NULL,
    [BATCHN]                  NVARCHAR (100)   NULL,
    [CREATEFLAG]              INT              NULL,
    [PARTQUANTITYCHANGEDFLAG] INT              NULL,
    CONSTRAINT [PK__PR_OPERA__3214EC2762AFA012] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PR_OPERATION_INSTALL_BOMID] FOREIGN KEY ([BOMID]) REFERENCES [dbo].[PR_MODELTYPE_BOM] ([ID]),
    CONSTRAINT [FK_PR_OPERATION_INSTALL_DEVID] FOREIGN KEY ([PARTID]) REFERENCES [dbo].[PR_DEVICE] ([ID]),
    CONSTRAINT [FK_PR_OPERATION_INSTALL_OPERID] FOREIGN KEY ([OPERID]) REFERENCES [dbo].[PR_OPERATION] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_INSTALL_PARTID]
    ON [dbo].[PR_OPERATION_INSTALL]([PARTID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_INSTALL_OPERID_BOMID]
    ON [dbo].[PR_OPERATION_INSTALL]([OPERID] ASC, [BOMID] ASC)
    INCLUDE([PARTID]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_INSTALL]
    ON [dbo].[PR_OPERATION_INSTALL]([OPERID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE trigger [dbo].[PR_OPERATION_INSTALL_DEL] on [dbo].[PR_OPERATION_INSTALL]
FOR delete, update
as 
  set nocount on
  
    delete from PR_DEVICE where PR_DEVICE.ID in (select distinct A.PARTID from deleted A) 
                          and PR_DEVICE.CREATEDTOINSTALLROWID is not null
                          and PR_DEVICE.CREATEDTOINSTALLROWID in (select distinct A.ID from deleted A) 
                          and not exists (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = PR_DEVICE.ID)
                          and not exists (select C.PARTID from inserted C where C.PARTID = PR_DEVICE.ID)
                          and not exists (select H.DEVICEID from PR_OPERATION_EXT_PARAMS H with (nolock) where H.DEVICEID = PR_DEVICE.ID)
                          and not exists (select N.PARTID from PR_OPERATION_INSTALL N where N.PARTID = PR_DEVICE.ID and N.ID not in (select J.ID from deleted J))
                          and PR_DEVICE.ORDERID is null
  
  update PR_DEVICE set S_S = 1000086 /* install canceled */
  where PR_DEVICE.ID in (select distinct A.PARTID from deleted A)
    and PR_DEVICE.S_S = 1000077 /* install */
    and not exists (select B.PARTID from inserted B where B.PARTID = PR_DEVICE.ID)
    and not exists (select N.PARTID from PR_OPERATION_INSTALL N where N.PARTID = PR_DEVICE.ID and N.ID not in (select J.ID from deleted J))
  
  set nocount off