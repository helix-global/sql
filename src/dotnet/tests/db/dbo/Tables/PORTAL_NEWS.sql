CREATE TABLE [dbo].[PORTAL_NEWS] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NOT NULL,
    [S_S]          INT              NOT NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [TITLE]        NVARCHAR (1000)  NULL,
    [LINK]         NVARCHAR (1000)  NULL,
    [PIC]          IMAGE            NULL,
    [BODY]         TEXT             NULL,
    [PINNED]       INT              NULL,
    [PINNEDORDER]  INT              NULL,
    [PUBLISHDATE]  DATE             NULL,
    [ANNOUNCEMENT] NVARCHAR (300)   NULL,
    [PUBLICNEWS]   INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

