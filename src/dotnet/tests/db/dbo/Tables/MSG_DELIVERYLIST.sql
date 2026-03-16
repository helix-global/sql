CREATE TABLE [dbo].[MSG_DELIVERYLIST] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [DEPID]        INT              NOT NULL,
    [DELIVERYTYPE] INT              NOT NULL,
    [GREMAIL]      NVARCHAR (100)   NULL,
    [OPTIONS]      NVARCHAR (512)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MSG_DELIVERYLIST_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MSG_DELIVERYLIST_1]
    ON [dbo].[MSG_DELIVERYLIST]([DELIVERYTYPE] ASC, [DEPID] ASC);

