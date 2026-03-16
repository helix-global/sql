CREATE TABLE [dbo].[COM_ZEITAFIRMA] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [NAME]       NVARCHAR (250)   NOT NULL,
    [CUSTOMERID] INT              NULL,
    [REMART]     NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_ZEITAFIRMA_CUSTOMERID] FOREIGN KEY ([CUSTOMERID]) REFERENCES [dbo].[COM_CUSTOMER] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_ZEITAFIRMA_NAME]
    ON [dbo].[COM_ZEITAFIRMA]([NAME] ASC);

