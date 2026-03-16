CREATE TABLE [dbo].[PR_IMP_SOURCES] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [NAME]       NVARCHAR (200)   NOT NULL,
    [CONNSTRING] NVARCHAR (300)   NOT NULL,
    [SQLTEXT]    NTEXT            NULL,
    [CONTIMEOUT] INT              NULL,
    [REMARK]     NTEXT            NULL,
    [COMTIMEOUT] INT              NULL,
    [DEPID]      INT              NOT NULL,
    [ADDMODE]    INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_IMP_SOURCES_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

