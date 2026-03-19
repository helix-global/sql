CREATE TABLE [dbo].[PR_SUPPLY] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_S]              INT              NOT NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [ND]               NVARCHAR (50)    NOT NULL,
    [DD]               DATETIME         NOT NULL,
    [URGENCY]          INT              NOT NULL,
    [CUSTOMERID]       INT              NOT NULL,
    [DEPARTMENTID]     INT              NOT NULL,
    [COMPLETED_DT]     DATETIME         NULL,
    [SPREQ]            NTEXT            NULL,
    [TEMPID]           INT              NULL,
    [CREATEDBYORDERID] INT              NULL,
    [CDD]              DATETIME         NULL,
    [DESCRIPTION]      NTEXT            NULL,
    [MODELID]          INT              NULL,
    [QTY]              DECIMAL (18, 4)  NULL,
    [REQDATE]          DATETIME         NULL,
    [UNITOFMES]        NVARCHAR (50)    NULL,
    [NN3]              NVARCHAR (50)    NULL,
    [NAVISION_KEY]     NVARCHAR (250)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_SUPPLY_CUSTOMERID] FOREIGN KEY ([CUSTOMERID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_PR_SUPPLY_DEPARTMENTID] FOREIGN KEY ([DEPARTMENTID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_SUPPLY_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_SUPPLY_TEMPID]
    ON [dbo].[PR_SUPPLY]([TEMPID] ASC) WHERE ([TEMPID] IS NOT NULL) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_PR_SUPPLY_S_S_ID_ND_DD_DEPARTMENTID_CDD]
    ON [dbo].[PR_SUPPLY]([S_S] ASC)
    INCLUDE([ID], [ND], [DD], [DEPARTMENTID], [CDD]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_SUPPLY_ND]
    ON [dbo].[PR_SUPPLY]([ND] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PR_SUPPLY_CREATEDBYORDERID]
    ON [dbo].[PR_SUPPLY]([CREATEDBYORDERID] ASC) WHERE ([CREATEDBYORDERID] IS NOT NULL) WITH (FILLFACTOR = 90);


GO
CREATE trigger [dbo].[TR_PR_SUPPLY] on [dbo].[PR_SUPPLY]
FOR update
as 
  
  set nocount on  
  
  insert into MSG_PLANNED_DATES_CHANGES (DEVICEID, OLDDATE, NEWDATE)
  select C.ID, B.DD, A.DD 
  from inserted A
  left join deleted B on B.ID = A.ID
  left join PR_DEVICE C on C.SORDERID = A.ID
  left join PR_PRORDER D on D.ID = C.ORDERID
  where A.DD <> B.DD
    and exists (select G.ID from MSG_DELIVERYLIST G where G.DEPID = D.DEPARTMENTID and G.DELIVERYTYPE = 1606)
  
  
  set nocount off