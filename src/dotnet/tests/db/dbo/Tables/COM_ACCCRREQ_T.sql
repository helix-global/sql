CREATE TABLE [dbo].[COM_ACCCRREQ_T] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [GID]              UNIQUEIDENTIFIER NULL,
    [S_CR]             INT              NOT NULL,
    [S_CDT]            DATETIME         NOT NULL,
    [S_MR]             INT              NULL,
    [S_MDT]            DATETIME         NULL,
    [ARC]              INT              NULL,
    [VNESHID]          INT              NOT NULL,
    [FULLNAME]         NVARCHAR (100)   NOT NULL,
    [PERSONALN]        NVARCHAR (20)    NULL,
    [DOMAINACCOUNT]    NVARCHAR (100)   NOT NULL,
    [GENDER]           INT              NOT NULL,
    [QUALIFICATION]    INT              NOT NULL,
    [EMAIL]            NVARCHAR (100)   NULL,
    [PHONEN]           NVARCHAR (100)   NULL,
    [R_OPERATOR]       INT              NULL,
    [R_SUPERVISOR]     INT              NULL,
    [TEMPEMPL]         INT              NOT NULL,
    [DEF_LANG]         INT              NULL,
    [PERSONALWT]       INT              NULL,
    [DOMAINACCOUNT_ID] NVARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_ACCCRREQ_T_PERSONALWT] FOREIGN KEY ([PERSONALWT]) REFERENCES [dbo].[COM_WORKTIME] ([ID]),
    CONSTRAINT [FK_COM_ACCCRREQ_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[COM_ACCCRREQ] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_ACCCRREQ_T]
    ON [dbo].[COM_ACCCRREQ_T]([VNESHID] ASC);

