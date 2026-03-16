CREATE TABLE [dbo].[temp_save_FC_FAILUREANALYSISCODES] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [DEPARTID]      INT              NOT NULL,
    [NAME]          NVARCHAR (200)   NOT NULL,
    [DESCRIPTION]   NTEXT            NULL,
    [S_S]           INT              NOT NULL,
    [POSORDER]      INT              NULL,
    [REQ_FAR]       INT              NULL,
    [NOTCONFIRMED]  INT              NULL,
    [REQ_HER]       INT              NULL,
    [FAILURERATE]   DECIMAL (14, 2)  NULL,
    [MTID]          INT              NULL,
    [TEMP_OLDID]    INT              NULL,
    [TEMP_WASADDED] INT              NULL
);

