CREATE TABLE [dbo].[COM_EMPL_PARTINPROD] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [EMPLID]           INT              NOT NULL,
    [DD]               DATETIME         NOT NULL,
    [PARTINPRODUCTION] INT              NULL,
    [REMARK]           NTEXT            NULL,
    [ISRANDD]          INT              NULL,
    [PRODSUPPORT]      INT              NULL,
    [NONPRODTYPE]      INT              NULL,
    [ALLOW_NON_PS]     INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_EMPL_PARTINPROD_EMPLID] FOREIGN KEY ([EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_EMPL_PARTINPROD_2]
    ON [dbo].[COM_EMPL_PARTINPROD]([EMPLID] ASC, [DD] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COM_EMPL_PARTINPROD]
    ON [dbo].[COM_EMPL_PARTINPROD]([EMPLID] ASC);

