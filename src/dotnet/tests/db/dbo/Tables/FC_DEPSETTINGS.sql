CREATE TABLE [dbo].[FC_DEPSETTINGS] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [DEPID]         INT              NOT NULL,
    [TODEPID]       INT              NOT NULL,
    [ALLOWASSEMBLY] INT              NULL,
    [REQUIRE1CODE]  INT              NULL,
    [ALLOWEDIT]     INT              NULL,
    [ONLYEMPLID]    INT              NULL,
    [REMARK]        NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_DEPSETTINGS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_FC_DEPSETTINGS_ONLYEMPLID] FOREIGN KEY ([ONLYEMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_FC_DEPSETTINGS_TODEPID] FOREIGN KEY ([TODEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

