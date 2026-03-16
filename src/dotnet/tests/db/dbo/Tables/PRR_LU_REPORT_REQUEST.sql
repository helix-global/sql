CREATE TABLE [dbo].[PRR_LU_REPORT_REQUEST] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NOT NULL,
    [S_S]             INT              NOT NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [DEPID]           INT              NOT NULL,
    [USECURRENTMONTH] INT              NULL,
    [USEPREPARATORY]  INT              NULL,
    [DD]              DATE             NOT NULL,
    [ERRTXT]          NVARCHAR (MAX)   NULL,
    [ONEMONTHONLY]    INT              NULL,
    [ONEMONTHMONTH]   INT              NULL,
    [REMARK]          NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PRR_LU_REPORT_REQUEST_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

