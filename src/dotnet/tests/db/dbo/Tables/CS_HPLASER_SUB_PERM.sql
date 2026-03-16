CREATE TABLE [dbo].[CS_HPLASER_SUB_PERM] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [DEPID]      INT              NOT NULL,
    [REMARK]     NTEXT            NULL,
    [ACCESSMODE] INT              NOT NULL,
    [S_S]        INT              NOT NULL,
    [OWNDEPID]   INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_CS_HPLASER_SUB_PERM_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_CS_HPLASER_SUB_PERM_OWNDEPID] FOREIGN KEY ([OWNDEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CS_HPLASER_SUB_PERM_1]
    ON [dbo].[CS_HPLASER_SUB_PERM]([DEPID] ASC, [ACCESSMODE] ASC, [S_S] ASC);

