CREATE TABLE [dbo].[PR_MPL_GROUP_ACCESSS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [MPL_GROUPID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_MPL_GROUP_ACCESSS_MPL_GROUPID] FOREIGN KEY ([MPL_GROUPID]) REFERENCES [dbo].[DEF_USERS] ([ID])
);

