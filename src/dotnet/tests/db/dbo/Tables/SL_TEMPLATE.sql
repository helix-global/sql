CREATE TABLE [dbo].[SL_TEMPLATE] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [ND]           NVARCHAR (50)    NOT NULL,
    [CUSTID]       INT              NOT NULL,
    [REMARK]       NTEXT            NULL,
    [MODELID]      INT              NOT NULL,
    [DEPID]        INT              NOT NULL,
    [WARRANTY]     INT              NULL,
    [FAPPLICATION] NVARCHAR (10)    NULL,
    CONSTRAINT [PK__SL_TEMPL__3214EC272B403AEE] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_TEMPLATE_CUSTID] FOREIGN KEY ([CUSTID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_SL_TEMPLATE_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

