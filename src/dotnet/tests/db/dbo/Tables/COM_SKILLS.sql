CREATE TABLE [dbo].[COM_SKILLS] (
    [ID]                      INT              IDENTITY (1, 1) NOT NULL,
    [GID]                     UNIQUEIDENTIFIER NULL,
    [S_S]                     INT              NOT NULL,
    [S_CR]                    INT              NOT NULL,
    [S_CDT]                   DATETIME         NOT NULL,
    [S_MR]                    INT              NULL,
    [S_MDT]                   DATETIME         NULL,
    [ARC]                     INT              NULL,
    [DEPID]                   INT              NOT NULL,
    [NAME]                    NVARCHAR (250)   NOT NULL,
    [DESCRIPTION]             NVARCHAR (4000)  NULL,
    [EXPIRATION_TERM]         INT              NULL,
    [EXPIRATION_TERM_TYPE_ID] INT              NULL,
    [NEEDS_APPROVAL]          INT              NULL,
    [ITERATIONS]              INT              NOT NULL,
    [PRODUCTION_SUPPORT]      INT              NULL,
    [ITERATIONS_REPEAT]       INT              DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_SKILLS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [IX_COM_SKILLS] UNIQUE NONCLUSTERED ([NAME] ASC, [DEPID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_COM_SKILLS_DEPID]
    ON [dbo].[COM_SKILLS]([DEPID] ASC);

