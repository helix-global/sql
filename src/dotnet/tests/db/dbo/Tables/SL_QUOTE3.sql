CREATE TABLE [dbo].[SL_QUOTE3] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [DD]         DATETIME         NULL,
    [ND]         NVARCHAR (12)    NULL,
    [CUSTID]     INT              NULL,
    [COMPATMODE] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_QUOTE3_CUSTID] FOREIGN KEY ([CUSTID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID])
);

