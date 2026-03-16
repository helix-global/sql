CREATE TABLE [dbo].[LN_SKIPPING] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [WEEKID] INT              NOT NULL,
    [DAY]    INT              NOT NULL,
    [REMARK] NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_LN_SKIPPING_WEEKID] FOREIGN KEY ([WEEKID]) REFERENCES [dbo].[LN_WEEKS] ([ID])
);

