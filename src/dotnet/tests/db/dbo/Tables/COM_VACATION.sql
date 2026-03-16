CREATE TABLE [dbo].[COM_VACATION] (
    [ID]                     INT              IDENTITY (1, 1) NOT NULL,
    [GID]                    UNIQUEIDENTIFIER NULL,
    [S_S]                    INT              NOT NULL,
    [S_CR]                   INT              NOT NULL,
    [S_CDT]                  DATETIME         NOT NULL,
    [S_MR]                   INT              NULL,
    [S_MDT]                  DATETIME         NULL,
    [ARC]                    INT              NULL,
    [EMPLID]                 INT              NOT NULL,
    [VACATIONTYPE]           INT              NOT NULL,
    [DBEG]                   DATE             NOT NULL,
    [DEND]                   DATE             NULL,
    [REMARK]                 NTEXT            NULL,
    [PERIODTYPE]             INT              NULL,
    [SHORTDURATION]          INT              NULL,
    [REJECTIONREMARK]        NTEXT            NULL,
    [SHORTSTART]             DATETIME         NULL,
    [APP_REJ_USERID]         INT              NULL,
    [APP_REJ_DT]             DATETIME         NULL,
    [APPLIED_USERID]         INT              NULL,
    [APPLIED_DT]             DATETIME         NULL,
    [TEMP_N]                 INT              NULL,
    [NAVNN]                  INT              NULL,
    [SICKLIEVEINFORMED]      DATETIME         NULL,
    [RESULTNOTYFIED]         DATETIME         NULL,
    [ADDEDFROMWEB]           INT              NULL,
    [PICT]                   IMAGE            NULL,
    [EMERG_CASE]             INT              NULL,
    [EMERG_CASE_DESCRIPTION] NVARCHAR (250)   NULL,
    [SUBMIT]                 INT              NULL,
    [IMPORTKEY]              NVARCHAR (250)   NULL,
    [IMPORTKEY2]             NVARCHAR (250)   NULL,
    [P_SPLEAVE_SHORT]        INT              NULL,
    [P_SPLEAVE]              INT              NULL,
    CONSTRAINT [PK__COM_VACA__3214EC275B8E6C8E] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_VACATION_EMPLID] FOREIGN KEY ([EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID]),
    CONSTRAINT [FK_COM_VACATION_P_SPLEAVE] FOREIGN KEY ([P_SPLEAVE]) REFERENCES [dbo].[COM_SPECIAL_LEAVES_T] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_VACATION_NAVNN]
    ON [dbo].[COM_VACATION]([NAVNN] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COM_VACATION_DBEG]
    ON [dbo].[COM_VACATION]([DBEG] ASC)
    INCLUDE([ID], [S_S], [S_CR], [EMPLID], [DEND]);


GO
CREATE NONCLUSTERED INDEX [IX_COM_VACATION_3]
    ON [dbo].[COM_VACATION]([S_S] ASC, [VACATIONTYPE] ASC)
    INCLUDE([SUBMIT]) WHERE ([EMERG_CASE] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_COM_VACATION_1]
    ON [dbo].[COM_VACATION]([EMPLID] ASC, [S_S] ASC)
    INCLUDE([DBEG], [DEND], [VACATIONTYPE], [PERIODTYPE]);

