CREATE TABLE [dbo].[SM_EMAIL_BOXES] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [NAME]             NVARCHAR (50)    NOT NULL,
    [EXC_SERVER]       NVARCHAR (250)   NULL,
    [EXC_DOMAIN]       NVARCHAR (50)    NOT NULL,
    [EXC_CW]           NVARCHAR (50)    NULL,
    [REMARK]           NTEXT            NULL,
    [EMAIL]            NVARCHAR (100)   NULL,
    [EXC_USER]         NVARCHAR (50)    NULL,
    [DISABLED]         INT              NULL,
    [DEPID]            INT              NULL,
    [AUTOREPLY]        INT              NULL,
    [AUTOREPLYHTML]    NTEXT            NULL,
    [AUTOREPLYSUBJ]    NVARCHAR (250)   NULL,
    [EXC_VER]          INT              NULL,
    [SIGNATURE]        NTEXT            NULL,
    [SIG_ENABLED]      INT              NULL,
    [SIG_AUTO]         INT              NULL,
    [SCHED_TIME_CONST] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SM_EMAIL_BOXES_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SM_EMAIL_BOXES_DEPID]
    ON [dbo].[SM_EMAIL_BOXES]([DEPID] ASC) WHERE ([DEPID] IS NOT NULL);

