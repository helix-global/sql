CREATE TABLE [dbo].[EQ_FR] (
    [ID]                 INT              IDENTITY (1, 1) NOT NULL,
    [GID]                UNIQUEIDENTIFIER NOT NULL,
    [S_S]                INT              NOT NULL,
    [S_CR]               INT              NOT NULL,
    [S_CDT]              DATETIME         NOT NULL,
    [S_MR]               INT              NULL,
    [S_MDT]              DATETIME         NULL,
    [ARC]                INT              NULL,
    [FR_NN]              NVARCHAR (20)    NOT NULL,
    [EQID]               INT              NOT NULL,
    [DD]                 DATE             NOT NULL,
    [DEPID]              INT              NOT NULL,
    [FR_DESC]            NTEXT            NOT NULL,
    [SEND2REPAIR_D]      DATE             NULL,
    [SEND2REPAIR_EMPLID] INT              NULL,
    [REMARKS]            NTEXT            NULL,
    [REPAIR_DD]          DATE             NULL,
    [RETURN_DD]          DATE             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_EQ_FR_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_EQ_FR_EQID] FOREIGN KEY ([EQID]) REFERENCES [dbo].[EQ_EQUIPMENT] ([ID]),
    CONSTRAINT [FK_EQ_FR_SEND2REPAIR_EMPLID] FOREIGN KEY ([SEND2REPAIR_EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EQ_FR_NN]
    ON [dbo].[EQ_FR]([FR_NN] ASC);

