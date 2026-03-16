CREATE TABLE [dbo].[DEF_LASTREPORTS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [USERID]      INT              NOT NULL,
    [REPORTOID]   INT              NOT NULL,
    [DD]          DATETIME         NOT NULL,
    [FILENAME]    NVARCHAR (300)   NOT NULL,
    [FPX]         IMAGE            NULL,
    [INPUTPARAMS] NTEXT            NULL,
    [PDF]         IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_LASTREPORTS_REPORTOID] FOREIGN KEY ([REPORTOID]) REFERENCES [dbo].[DEF_REPORTS] ([OID]),
    CONSTRAINT [FK_DEF_LASTREPORTS_USERID] FOREIGN KEY ([USERID]) REFERENCES [dbo].[DEF_USERS] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_LASTREPORTS_GID]
    ON [dbo].[DEF_LASTREPORTS]([GID] ASC);

