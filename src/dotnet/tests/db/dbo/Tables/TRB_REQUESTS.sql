CREATE TABLE [dbo].[TRB_REQUESTS] (
    [ID]                   INT              IDENTITY (1, 1) NOT NULL,
    [GID]                  UNIQUEIDENTIFIER NOT NULL,
    [S_S]                  INT              NOT NULL,
    [S_CR]                 INT              NOT NULL,
    [S_CDT]                DATETIME         NOT NULL,
    [S_MR]                 INT              NULL,
    [S_MDT]                DATETIME         NULL,
    [ARC]                  INT              NULL,
    [BOOKDATE]             DATE             NULL,
    [DESCRIPTION]          NVARCHAR (1000)  NULL,
    [PERSON_VEHICLE]       NVARCHAR (4000)  NULL,
    [PICKUPTIME]           DATETIME         NULL,
    [TERMINTIME]           DATETIME         NULL,
    [PICKUPLOCATION]       NVARCHAR (1000)  NULL,
    [DRIVERUSERID]         INT              NULL,
    [REMARKS]              NVARCHAR (1000)  NULL,
    [CONTACTPERSON]        NVARCHAR (500)   NULL,
    [DRIVERCONFIRMCHANGES] INT              NULL,
    [TREFFPUNKT]           INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_TRB_REQUESTS_DRIVERUSERID] FOREIGN KEY ([DRIVERUSERID]) REFERENCES [dbo].[DEF_USERS] ([ID])
);

