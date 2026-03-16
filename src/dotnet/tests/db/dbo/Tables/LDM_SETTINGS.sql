CREATE TABLE [dbo].[LDM_SETTINGS] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [LABEL]        NVARCHAR (50)    NOT NULL,
    [VALUEINT]     INT              NULL,
    [REMARK]       NTEXT            NULL,
    [PRM]          INT              NULL,
    [VALUEINT2]    INT              NULL,
    [VALUEFLOAT]   FLOAT (53)       NULL,
    [TYPE]         INT              NULL,
    [VALUEINT_OL]  NVARCHAR (100)   NULL,
    [VALUEINT2_OL] NVARCHAR (100)   NULL,
    [PRM_OL]       NVARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_LDM_SETTINGS_LBEL_PRM]
    ON [dbo].[LDM_SETTINGS]([LABEL] ASC, [PRM] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_LDM_SETTINGS_LABEL_TYPE]
    ON [dbo].[LDM_SETTINGS]([LABEL] ASC, [TYPE] ASC);

