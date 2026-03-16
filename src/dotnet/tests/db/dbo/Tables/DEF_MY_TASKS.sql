CREATE TABLE [dbo].[DEF_MY_TASKS] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_S]        INT              NULL,
    [S_CR]       INT              NULL,
    [S_CDT]      DATETIME         NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [S_USERID]   INT              NOT NULL,
    [PRIORITY]   INT              NOT NULL,
    [CAPTION]    NVARCHAR (250)   NOT NULL,
    [ANNOTATION] NTEXT            NULL,
    [DOCOID]     INT              NULL,
    [DOCID]      INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_MY_TASKS_DOCOID] FOREIGN KEY ([DOCOID]) REFERENCES [dbo].[DEF_CLASSES] ([OID]),
    CONSTRAINT [FK_DEF_MY_TASKS_S_USERID] FOREIGN KEY ([S_USERID]) REFERENCES [dbo].[DEF_USERS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_DEF_MY_TASKS]
    ON [dbo].[DEF_MY_TASKS]([S_USERID] ASC, [S_S] ASC);

