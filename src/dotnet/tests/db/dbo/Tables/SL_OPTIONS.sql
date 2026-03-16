CREATE TABLE [dbo].[SL_OPTIONS] (
    [ID]           INT              NOT NULL,
    [GID]          UNIQUEIDENTIFIER NOT NULL,
    [S_CR]         INT              NULL,
    [S_CDT]        DATETIME         NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [S_S]          INT              NOT NULL,
    [CODE]         NVARCHAR (20)    NOT NULL,
    [NAME]         NVARCHAR (300)   NOT NULL,
    [GROUPID]      INT              NULL,
    [GROUPNAME]    NVARCHAR (300)   NULL,
    [TYPEID]       INT              NOT NULL,
    [TAGS]         NVARCHAR (300)   NULL,
    [PRTYPE]       INT              NULL,
    [CMP_OUT]      NVARCHAR (200)   NULL,
    [CMP_REQ]      NVARCHAR (200)   NULL,
    [SPEC]         NVARCHAR (200)   NULL,
    [OPICT]        IMAGE            NULL,
    [CUSTOM4GROUP] INT              NULL,
    [MTNAME]       NVARCHAR (300)   NULL,
    [DEPARTMENTID] INT              NULL,
    [CUSTOM4ID]    INT              NULL,
    [APPROVEDDT]   DATETIME         NULL,
    [APPROVEDBY]   INT              NULL,
    [CMP_BLOCK]    NVARCHAR (200)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_OPTIONS_PR_MODELTYPE_OPTIONS_ID] FOREIGN KEY ([ID]) REFERENCES [dbo].[PR_MODELTYPE_OPTIONS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_SL_OPTIONS_APPROVEDBY]
    ON [dbo].[SL_OPTIONS]([APPROVEDBY] ASC) WHERE ([APPROVEDBY] IS NOT NULL);

