CREATE TABLE [dbo].[COM_TEST_T] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [VNESHID] INT              NOT NULL,
    [FCOLOR]  INT              NULL,
    [DTFILED] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_TEST_T_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[COM_TEST] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_TEST_T]
    ON [dbo].[COM_TEST_T]([VNESHID] ASC);

