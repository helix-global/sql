CREATE TABLE [dbo].[PR_NAV_DEPMODES] (
    [ID]                                   INT              IDENTITY (1, 1) NOT NULL,
    [GID]                                  UNIQUEIDENTIFIER NULL,
    [S_CR]                                 INT              NOT NULL,
    [S_CDT]                                DATETIME         NOT NULL,
    [S_MR]                                 INT              NULL,
    [S_MDT]                                DATETIME         NULL,
    [ARC]                                  INT              NULL,
    [DEPID]                                INT              NOT NULL,
    [INVENTORYMODE]                        INT              NULL,
    [M2_MAT]                               DATETIME         NULL,
    [M2_TIME]                              DATETIME         NULL,
    [M2_DEV]                               DATETIME         NULL,
    [BLOCKSH]                              INT              NULL,
    [MTID]                                 INT              NULL,
    [S2_MAT]                               DATETIME         NULL,
    [S2_TIME]                              DATETIME         NULL,
    [DEVIATIONSVISIBLE]                    INT              NULL,
    [POSTALLFROMDEVIATIONS]                INT              NULL,
    [IGNORETIMEDEVIATIONS]                 INT              NULL,
    [NEWPOSTINGFROMLIST]                   INT              NULL,
    [KEEPPENDING_WHEN_INVENT_MODE_ENABLED] INT              NULL,
    [CUTRMAAFTERDOT]                       INT              NULL,
    [SHOWDEVIATIONSKB3805]                 INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_NAV_DEPMODES_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID]),
    CONSTRAINT [FK_PR_NAV_DEPMODES_MTID] FOREIGN KEY ([MTID]) REFERENCES [dbo].[PR_MODELTYPE] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_NAV_DEPMODES]
    ON [dbo].[PR_NAV_DEPMODES]([DEPID] ASC, [MTID] ASC);

