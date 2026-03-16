CREATE TABLE [dbo].[VR_ADDRESSES] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [ARC]     INT              NULL,
    [CODE]    NVARCHAR (256)   NOT NULL,
    [ADDRESS] NVARCHAR (1024)  NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [GID]     UNIQUEIDENTIFIER NULL,
    [S_CR]    INT              NULL,
    [S_CDT]   DATETIME         NULL,
    CONSTRAINT [PK__VR_ADDRE__3214EC273837D926] PRIMARY KEY CLUSTERED ([ID] ASC)
);

