CREATE TABLE [dbo].[SL_OPTION_FILES] (
    [ID]           INT              NOT NULL,
    [GID]          UNIQUEIDENTIFIER NOT NULL,
    [S_CR]         INT              NULL,
    [S_CDT]        DATETIME         NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [OPTID]        INT              NOT NULL,
    [FILENAME]     NVARCHAR (255)   NOT NULL,
    [FILESIZE]     INT              NULL,
    [FILEDATE]     DATETIME         NULL,
    [FILEBLOB]     IMAGE            NULL,
    [FILEDESC]     NTEXT            NULL,
    [FILEGROUP]    INT              NULL,
    [FILESOURCE]   INT              NULL,
    [FILESOURCEID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

