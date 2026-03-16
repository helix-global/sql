CREATE TABLE [dbo].[SL_MODELS] (
    [ID]           INT              NOT NULL,
    [GID]          UNIQUEIDENTIFIER NOT NULL,
    [S_CR]         INT              NULL,
    [S_CDT]        DATETIME         NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [S_S]          INT              NOT NULL,
    [CODE]         NVARCHAR (16)    NOT NULL,
    [DEPID]        INT              NOT NULL,
    [NAME]         NVARCHAR (200)   NOT NULL,
    [DESCSTR]      NVARCHAR (300)   NULL,
    [DESCRIPTION]  NTEXT            NULL,
    [TYPEID]       INT              NOT NULL,
    [TAGS]         NVARCHAR (300)   NULL,
    [PRTYPE]       INT              NULL,
    [MPICT]        IMAGE            NULL,
    [SPEC]         NVARCHAR (200)   NULL,
    [CUSTOM4GROUP] INT              NULL,
    [CUSTOM4ID]    INT              NULL,
    [APPROVEDBY]   INT              NULL,
    [APPROVEDDT]   DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_MODELS_PR_MODELS_ID] FOREIGN KEY ([ID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_SL_MODELS_TYPEID]
    ON [dbo].[SL_MODELS]([TYPEID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SL_MODELS_CODE]
    ON [dbo].[SL_MODELS]([CODE] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SL_MODELS_APPROVEDBY]
    ON [dbo].[SL_MODELS]([APPROVEDBY] ASC) WHERE ([APPROVEDBY] IS NOT NULL);

