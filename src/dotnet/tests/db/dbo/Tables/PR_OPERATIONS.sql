CREATE TABLE [dbo].[PR_OPERATIONS] (
    [ID]                   INT              IDENTITY (1, 1) NOT NULL,
    [GID]                  UNIQUEIDENTIFIER NULL,
    [S_CR]                 INT              NOT NULL,
    [S_CDT]                DATETIME         NOT NULL,
    [S_MR]                 INT              NULL,
    [S_MDT]                DATETIME         NULL,
    [ARC]                  INT              NULL,
    [OPERGRID]             INT              NOT NULL,
    [CODE]                 NVARCHAR (50)    NOT NULL,
    [FORMXML]              NTEXT            NULL,
    [NAME]                 NVARCHAR (100)   NOT NULL,
    [ONLYOPTGR]            INT              NULL,
    [DESCRIPTION]          NTEXT            NULL,
    [SMFORMXML]            NTEXT            NULL,
    [INFORMAT]             INT              NULL,
    [UGROUP]               NVARCHAR (200)   NULL,
    [MTID]                 INT              NOT NULL,
    [REVN]                 INT              NOT NULL,
    [S_S]                  INT              NULL,
    [CAPTION]              NVARCHAR (200)   NULL,
    [MANHOUR]              DECIMAL (10, 4)  NULL,
    [BCODE]                NVARCHAR (20)    NULL,
    [NOINPUT]              INT              NULL,
    [FORMXML_NOI]          INT              NULL,
    [SMFORMXML_NOI]        INT              NULL,
    [DENYPARRALEL]         INT              NULL,
    [OPERTYPE]             INT              NULL,
    [AJOIN]                INT              NULL,
    [STAGEID]              INT              NULL,
    [FHASH]                NVARCHAR (50)    NULL,
    [ALLOWGREDIT]          INT              NULL,
    [OLDCODE]              NVARCHAR (50)    NULL,
    [SAVE_SW_ALL]          INT              NULL,
    [WKS_MODE]             INT              NULL,
    [DELAYEDPOST]          INT              NULL,
    [NOTIFYDIVIDE]         INT              NULL,
    [DEPID]                INT              NOT NULL,
    [ALLOWCOPYMENU]        INT              NULL,
    [temp_FORMXML_Convert] NTEXT            NULL,
    [SYNC2REMOTELOCATIONS] INT              NULL,
    [PRINT_BARCODE]        INT              NULL,
    [NOTIFY_START]         INT              NULL,
    [NOTIFY_START_TO]      NVARCHAR (500)   NULL,
    [ISTMELDUNG]           INT              NULL,
    [DENYPARRALELLIMIT]    INT              NULL,
    [DONOTCHECKSKILLS]     INT              NULL,
    [FOPTIONS]             NVARCHAR (200)   NULL,
    [ADDCMPLCONFIRM]       INT              NULL,
    [CHECKKB4546]          INT              NULL,
    [REMARK]               NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PR_OPERATIONS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_OPERATIONS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID]),
    CONSTRAINT [FK_PR_OPERATIONS_OPERGRID] FOREIGN KEY ([OPERGRID]) REFERENCES [dbo].[PR_OPERATIONS_GR] ([ID]),
    CONSTRAINT [FK_PR_OPERATIONS_STAGEID] FOREIGN KEY ([STAGEID]) REFERENCES [dbo].[PR_STAGES] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATIONS_MTID]
    ON [dbo].[PR_OPERATIONS]([MTID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_OPERATIONS_ID_STAGEID]
    ON [dbo].[PR_OPERATIONS]([ID] ASC)
    INCLUDE([STAGEID]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATIONS_2]
    ON [dbo].[PR_OPERATIONS]([OPERTYPE] ASC)
    INCLUDE([ID], [OPERGRID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATIONS1]
    ON [dbo].[PR_OPERATIONS]([OPERGRID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_OPERATIONS]
    ON [dbo].[PR_OPERATIONS]([CODE] ASC, [REVN] ASC) WITH (FILLFACTOR = 90);


GO
create trigger [dbo].[TR_PR_OPERATIONS] on [dbo].[PR_OPERATIONS]
FOR update
as 
  
if TRIGGER_NESTLEVEL() > 1 return
set nocount on  
  

insert into PR_NORM_HISTORY (GID,S_CR,S_CDT,OPERID,USERID,DD,OLDVALUE,NEWVALUE)
select newid(),A.S_MR,getdate(),A.ID,A.S_MR,getdate(),B.MANHOUR,A.MANHOUR
from inserted A
left join deleted B on B.ID = A.ID
where isnull(A.MANHOUR,-546114) <> isnull(B.MANHOUR,-546114)

  
set nocount off