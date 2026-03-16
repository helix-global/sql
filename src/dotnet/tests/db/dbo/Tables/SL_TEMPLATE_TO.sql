CREATE TABLE [dbo].[SL_TEMPLATE_TO] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [GID]      UNIQUEIDENTIFIER NULL,
    [S_CR]     INT              NOT NULL,
    [S_CDT]    DATETIME         NOT NULL,
    [S_MR]     INT              NULL,
    [S_MDT]    DATETIME         NULL,
    [ARC]      INT              NULL,
    [VNESHID]  INT              NOT NULL,
    [OPTID]    INT              NOT NULL,
    [QUANTITY] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_TEMPLATE_TO_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[SL_TEMPLATE] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_SL_TEMPLATE_TO]
    ON [dbo].[SL_TEMPLATE_TO]([VNESHID] ASC);

