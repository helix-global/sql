CREATE TABLE [dbo].[temp_save_FC_FAILURECODES] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [DEPARTID]      INT              NOT NULL,
    [DESCRIPTION]   NTEXT            NULL,
    [NAME]          NVARCHAR (200)   NOT NULL,
    [CAPTION]       NVARCHAR (400)   NULL,
    [S_S]           INT              NOT NULL,
    [POSORDER]      INT              NULL,
    [MTID]          INT              NULL,
    [TEMP_OLDID]    INT              NULL,
    [TEMP_WASADDED] INT              NULL
);

