CREATE TABLE [dbo].[SM_SLA] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [MTID]           INT              NOT NULL,
    [CUSTID]         INT              NULL,
    [MODELID]        INT              NULL,
    [FIRST_REACT_T]  DECIMAL (10, 2)  NOT NULL,
    [INC_RES_T]      DECIMAL (10, 2)  NOT NULL,
    [SERV_ORD_RES_T] DECIMAL (10, 2)  NOT NULL,
    [REMARK]         NTEXT            NULL,
    [DEPID]          INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_SLA_CUSTID] FOREIGN KEY ([CUSTID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_SM_SLA_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_SM_SLA_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID]),
    CONSTRAINT [FK_SM_SLA_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SM_SLA]
    ON [dbo].[SM_SLA]([MTID] ASC, [CUSTID] ASC, [MODELID] ASC);

