CREATE TABLE [dbo].[PR_MAP] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [NAME]        NVARCHAR (300)   NOT NULL,
    [MTID]        INT              NOT NULL,
    [DESCRIPTION] NTEXT            NULL,
    [NN]          NVARCHAR (15)    NOT NULL,
    [REVN]        INT              NOT NULL,
    [IN_X]        INT              NULL,
    [IN_Y]        INT              NULL,
    [OUT_X]       INT              NULL,
    [OUT_Y]       INT              NULL,
    [MAPPICT]     IMAGE            NULL,
    [MAPTYPE]     INT              NOT NULL,
    [OLDNN]       NVARCHAR (15)    NULL,
    [DEPID]       INT              NOT NULL,
    CONSTRAINT [PK__PR_MAP__3214EC27049AA3C2] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PR_MAP_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_MAP_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_MAP_GID]
    ON [dbo].[PR_MAP]([GID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_MAP]
    ON [dbo].[PR_MAP]([NN] ASC, [REVN] ASC) WITH (FILLFACTOR = 90);

