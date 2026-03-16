CREATE TABLE [dbo].[FC_8D_REPORT_P] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [REPID]      INT              NOT NULL,
    [ROLE]       INT              NULL,
    [EMPLOYEEID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_8D_REPORT_P_EMPLOYEEID] FOREIGN KEY ([EMPLOYEEID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_FC_8D_REPORT_P_REPID] FOREIGN KEY ([REPID]) REFERENCES [dbo].[FC_8D_REPORT] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_8D_REPORT_P]
    ON [dbo].[FC_8D_REPORT_P]([REPID] ASC);

