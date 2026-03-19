CREATE TABLE [dbo].[PR_STAGES] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [DESCRIPTION] NTEXT            NULL,
    [NAME]        NVARCHAR (100)   NOT NULL,
    [MTID]        INT              NOT NULL,
    [ORDERPOS]    INT              NULL,
    [STAGECOLOR]  INT              NULL,
    [DEPID]       INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_STAGES_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_STAGES_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_STAGES_1]
    ON [dbo].[PR_STAGES]([MTID] ASC, [NAME] ASC) WITH (FILLFACTOR = 90);

