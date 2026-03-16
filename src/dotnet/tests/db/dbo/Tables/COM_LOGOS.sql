CREATE TABLE [dbo].[COM_LOGOS] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NOT NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [DEPORIGIN] INT              NOT NULL,
    [LOGO]      IMAGE            NULL,
    [REMARK]    NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_COM_LOGOS_DEPORIGIN]
    ON [dbo].[COM_LOGOS]([DEPORIGIN] ASC);

