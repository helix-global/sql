CREATE TABLE [dbo].[EQ_TYPES] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [NAME]       NVARCHAR (200)   NOT NULL,
    [REMARK]     NTEXT            NULL,
    [DEPID]      INT              NOT NULL,
    [SHAREDTYPE] INT              NULL,
    [MTID]       INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_EQ_TYPES_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_EQ_TYPES_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EQ_TYPES_NAME]
    ON [dbo].[EQ_TYPES]([DEPID] ASC, [NAME] ASC);

