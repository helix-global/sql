CREATE TABLE [dbo].[temp_mo_del] (
    [ID]            INT              IDENTITY (1, 1) NOT NULL,
    [GID]           UNIQUEIDENTIFIER NULL,
    [S_CR]          INT              NOT NULL,
    [S_CDT]         DATETIME         NOT NULL,
    [S_MR]          INT              NULL,
    [S_MDT]         DATETIME         NULL,
    [ARC]           INT              NULL,
    [MODELID]       INT              NOT NULL,
    [OPTIONID]      INT              NOT NULL,
    [PREDEFINEDOPT] INT              NULL
);

