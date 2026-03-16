CREATE TABLE [dbo].[LN_WEEK_VARIANT] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [WEEKID]      INT              NOT NULL,
    [DAY]         INT              NOT NULL,
    [VARIANTNAME] NVARCHAR (250)   NOT NULL,
    [VARIANTTYPE] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_LN_WEEK_VARIANT_WEEKID] FOREIGN KEY ([WEEKID]) REFERENCES [dbo].[LN_WEEKS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_LN_WEEK_VARIANT]
    ON [dbo].[LN_WEEK_VARIANT]([WEEKID] ASC);

