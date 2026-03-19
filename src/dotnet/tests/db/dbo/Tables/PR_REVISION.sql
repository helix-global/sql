CREATE TABLE [dbo].[PR_REVISION] (
    [ID]                  INT              IDENTITY (1, 1) NOT NULL,
    [GID]                 UNIQUEIDENTIFIER NULL,
    [S_CR]                INT              NULL,
    [S_CDT]               DATETIME         NULL,
    [S_MR]                INT              NULL,
    [S_MDT]               DATETIME         NULL,
    [MODELID]             INT              NOT NULL,
    [DBEG]                DATETIME         NOT NULL,
    [DEND]                DATETIME         NULL,
    [DESCRIPTION]         NTEXT            NULL,
    [S_S]                 INT              NULL,
    [NAME]                NVARCHAR (200)   NOT NULL,
    [ARC]                 INT              NULL,
    [MAPID]               INT              NULL,
    [SPEC]                NVARCHAR (200)   NULL,
    [MODELGROUPID]        INT              NULL,
    [MTO_APPROVED]        INT              NULL,
    [MTO_APPROVED_REMARK] NTEXT            NULL,
    [MTO_APPROVEDBY]      INT              NULL,
    [MTO_APPROVEDDT]      DATETIME         NULL,
    [REVGROUP]            NVARCHAR (50)    NULL,
    [SYNC2NAV]            INT              NULL,
    [TAGS]                NVARCHAR (300)   NULL,
    [REMARK]              NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_REVISION_MAPID] FOREIGN KEY ([MAPID]) REFERENCES [dbo].[PR_MAP] ([ID]),
    CONSTRAINT [FK_PR_REVISION_MODELGROUPID] FOREIGN KEY ([MODELGROUPID]) REFERENCES [dbo].[PR_MODEL_GROUP] ([ID]),
    CONSTRAINT [FK_PR_REVISION_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REVISION_MODELID_ID_MODELGROUPID]
    ON [dbo].[PR_REVISION]([MODELID] DESC, [ID] DESC)
    INCLUDE([MODELGROUPID]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_REVISION_MODELGROUPID]
    ON [dbo].[PR_REVISION]([MODELGROUPID] ASC) WHERE ([MODELGROUPID] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_REVISION_GID]
    ON [dbo].[PR_REVISION]([GID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_REVISION]
    ON [dbo].[PR_REVISION]([MODELID] ASC, [NAME] ASC);

