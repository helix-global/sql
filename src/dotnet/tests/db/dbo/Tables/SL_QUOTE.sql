CREATE TABLE [dbo].[SL_QUOTE] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_S]     INT              NOT NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [DD]      DATETIME         NOT NULL,
    [ND]      NVARCHAR (12)    NOT NULL,
    [CUSTID]  INT              NULL,
    [REMARK]  NTEXT            NULL,
    [MODELID] INT              NOT NULL,
    [QTY]     INT              NOT NULL,
    CONSTRAINT [PK__SL_QUOTE__3214EC274FFCBE51] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_QUOTE_CUSTID] FOREIGN KEY ([CUSTID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID]),
    CONSTRAINT [FK_SL_QUOTE_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SL_QUOTE_ND]
    ON [dbo].[SL_QUOTE]([ND] ASC);

