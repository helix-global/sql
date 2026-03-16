CREATE TABLE [dbo].[PR_NAV_URLS] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [SERVERNAME]      NVARCHAR (50)    NOT NULL,
    [NAVURL]          NVARCHAR (200)   NOT NULL,
    [LINK_SO]         NVARCHAR (500)   NULL,
    [LINK_IO]         NVARCHAR (500)   NULL,
    [LINK_MOF]        NVARCHAR (500)   NULL,
    [LINK_SHIP]       NVARCHAR (500)   NULL,
    [LINK_PN]         NVARCHAR (500)   NULL,
    [NEWXMLMETHODS]   INT              NULL,
    [LINK_REV]        NVARCHAR (500)   NULL,
    [LINK_SERV_SC]    NVARCHAR (500)   NULL,
    [LINK_SERV_RMA]   NVARCHAR (500)   NULL,
    [LINK_SERV_SCAFF] NVARCHAR (500)   NULL,
    [DISABLEABSCALLS] INT              NULL,
    [LINK_REVS]       NVARCHAR (500)   NULL,
    [LINK_TR]         NVARCHAR (500)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PR_NAV_URLS]
    ON [dbo].[PR_NAV_URLS]([SERVERNAME] ASC);

