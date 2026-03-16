CREATE TABLE [dbo].[FC_FAR_FROM_PRMS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [MTID]        INT              NOT NULL,
    [PARAMID]     INT              NOT NULL,
    [SETVALUE]    INT              NOT NULL,
    [SETPARAMID]  INT              NULL,
    [HIDECONVERT] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_FAR_FROM_PRMS_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID]),
    CONSTRAINT [FK_FC_FAR_FROM_PRMS_PARAMID] FOREIGN KEY ([PARAMID]) REFERENCES [dbo].[PR_MODELTYPE_PARAMS] ([ID]),
    CONSTRAINT [FK_FC_FAR_FROM_PRMS_SETPARAMID] FOREIGN KEY ([SETPARAMID]) REFERENCES [dbo].[FC_FAILUREPARAMS] ([ID])
);

