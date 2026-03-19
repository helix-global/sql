CREATE TABLE [dbo].[EQ_MODEL_PARAM_REF] (
    [ID]                    INT              IDENTITY (1, 1) NOT NULL,
    [GID]                   UNIQUEIDENTIFIER NULL,
    [S_CR]                  INT              NULL,
    [S_CDT]                 DATETIME         NULL,
    [S_MR]                  INT              NULL,
    [S_MDT]                 DATETIME         NULL,
    [EQMODELID]             INT              NOT NULL,
    [PARAMID]               INT              NOT NULL,
    [ARC]                   INT              NULL,
    [USE_IN_WORKCYCLE_CALC] INT              DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_EQ_MODEL_PARAM_REF_EQMODELID] FOREIGN KEY ([EQMODELID]) REFERENCES [dbo].[EQ_MODELS] ([ID]),
    CONSTRAINT [FK_EQ_MODEL_PARAM_REF_PARAMID] FOREIGN KEY ([PARAMID]) REFERENCES [dbo].[PR_MODELTYPE_PARAMS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_EQ_MODEL_PARAM_REF_USE_IN_WORKCYCLE_CALC]
    ON [dbo].[EQ_MODEL_PARAM_REF]([USE_IN_WORKCYCLE_CALC] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_EQ_MODEL_PARAM_REF_PARAMID]
    ON [dbo].[EQ_MODEL_PARAM_REF]([PARAMID] ASC);

