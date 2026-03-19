CREATE TABLE [dbo].[DEF_MY_MEMOS] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_CR]            INT              NULL,
    [S_CDT]           DATETIME         NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [S_USERID]        INT              NULL,
    [CAPTION]         NVARCHAR (250)   NOT NULL,
    [MEMOTEXT]        NTEXT            NULL,
    [VISIBLE_FOR_DEP] INT              NULL,
    [ARC]             INT              NULL,
    [DEPID]           INT              NULL,
    [SHARED_FOR_DEP]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_MY_MEMOS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_DEF_MY_MEMOS_S_USERID] FOREIGN KEY ([S_USERID]) REFERENCES [dbo].[DEF_USERS] ([ID])
);

