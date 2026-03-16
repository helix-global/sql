CREATE TABLE [dbo].[SH_ORDER] (
    [ID]                  INT              IDENTITY (1, 1) NOT NULL,
    [GID]                 UNIQUEIDENTIFIER NULL,
    [S_S]                 INT              NOT NULL,
    [S_CR]                INT              NOT NULL,
    [S_CDT]               DATETIME         NOT NULL,
    [S_MR]                INT              NULL,
    [S_MDT]               DATETIME         NULL,
    [DD]                  DATETIME         NOT NULL,
    [ARC]                 INT              NULL,
    [ND]                  NVARCHAR (50)    NULL,
    [DEPID]               INT              NOT NULL,
    [NAVSESSIONUID]       NVARCHAR (50)    NULL,
    [temp_OLD_DD]         DATETIME         NULL,
    [RS_DATE]             DATETIME         NULL,
    [RS_TIME]             DATETIME         NULL,
    [RS_LOCATION]         NVARCHAR (30)    NULL,
    [NAVSESSIONORDN]      NVARCHAR (20)    NULL,
    [REMARK]              NVARCHAR (200)   NULL,
    [TODEPID]             INT              NULL,
    [SPNOTES]             NVARCHAR (50)    NULL,
    [LAST2LOCATIONID]     INT              NULL,
    [LAST2LOCATIONUSERID] INT              NULL,
    [APNAV]               INT              NULL,
    [ISSERVICE]           INT              NULL,
    [CHECK_STATE]         INT              NULL,
    [CHECK_COUNT]         INT              NULL,
    [CREATE_TR_ORDER]     INT              NULL,
    [TR_ORDER_NO]         NVARCHAR (50)    NULL,
    [TRANSIT_BOX_CODE]    NVARCHAR (20)    NULL,
    [TR_PRIORITY]         INT              NULL,
    CONSTRAINT [PK__SH_ORDER__3214EC277E8CC4B1] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_SH_ORDER_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_SH_ORDER_TODEPID] FOREIGN KEY ([TODEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_SH_ORDER_DEPID]
    ON [dbo].[SH_ORDER]([DEPID] ASC);

