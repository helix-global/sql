CREATE TABLE [dbo].[COM_VACATION_CANCEL] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_S]          INT              NOT NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [VACATIONID]   INT              NOT NULL,
    [CAN_TYPE]     INT              NOT NULL,
    [DBEG]         DATE             NULL,
    [DEND]         DATE             NULL,
    [REQUESTED_DT] DATETIME         NULL,
    [REQUESTED_BY] INT              NULL,
    [APPROVED_DT]  DATETIME         NULL,
    [APPROVED_BY]  INT              NULL,
    [REMARK]       NTEXT            NULL,
    CONSTRAINT [PK__COM_VACA__3214EC27273A9FE0] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_VACATION_CANCEL_VACATIONID] FOREIGN KEY ([VACATIONID]) REFERENCES [dbo].[COM_VACATION] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_VACATION_CANCEL_S_S]
    ON [dbo].[COM_VACATION_CANCEL]([S_S] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COM_VACATION_CANCEL_2]
    ON [dbo].[COM_VACATION_CANCEL]([VACATIONID] ASC, [S_S] ASC);

