CREATE TABLE [dbo].[SL_QUOTE2] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_S]          INT              NOT NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [DD]           DATETIME         NOT NULL,
    [ND]           NVARCHAR (12)    NOT NULL,
    [CUSTID]       INT              NULL,
    [REMARK]       NTEXT            NULL,
    [DEPID]        INT              NOT NULL,
    [FAPPLICATION] NVARCHAR (10)    NULL,
    [COMPATMODE]   INT              NULL,
    CONSTRAINT [PK__SL_QUOTE__3214EC277CEF6059] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_QUOTE2_CUSTID] FOREIGN KEY ([CUSTID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_SL_QUOTE2_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SL_QUOTE2_ND]
    ON [dbo].[SL_QUOTE2]([ND] ASC, [DEPID] ASC);

