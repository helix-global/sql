CREATE TABLE [dbo].[COM_TEST] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [CURID]     INT              NOT NULL,
    [FDATE]     DATETIME         NULL,
    [FDATETIME] DATETIME         NULL,
    [S_S]       INT              NULL,
    [FTIME]     DATETIME         NULL,
    [FFOTO]     IMAGE            NULL,
    [FDEC]      DECIMAL (18, 2)  NULL,
    [FSTR]      NVARCHAR (200)   NULL,
    [S_CR]      INT              NULL,
    [S_MR]      INT              NULL,
    [S_CDT]     DATETIME         NULL,
    [S_MDT]     DATETIME         NULL,
    [GID]       UNIQUEIDENTIFIER NULL,
    [FCOLOR]    INT              NULL,
    [ARC]       INT              NULL,
    [TTEXT]     NTEXT            NULL,
    [VID]       INT              NULL,
    CONSTRAINT [PK__COM_TEST__3214EC271BC821DD] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_TEST_CURID] FOREIGN KEY ([CURID]) REFERENCES [dbo].[COM_CURRENCIES] ([ID])
);

