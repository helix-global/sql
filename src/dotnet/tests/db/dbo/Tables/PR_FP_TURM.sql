CREATE TABLE [dbo].[PR_FP_TURM] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NOT NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [TURM_NUM]  INT              NOT NULL,
    [TURM_NAME] NVARCHAR (100)   NOT NULL,
    [ORDERPOS]  INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_FP_TURM]
    ON [dbo].[PR_FP_TURM]([TURM_NUM] ASC);

