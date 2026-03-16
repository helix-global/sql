CREATE TABLE [dbo].[MSG_MODELS_CREA_NOTI] (
    [ID]        INT              IDENTITY (1, 1) NOT NULL,
    [GID]       UNIQUEIDENTIFIER NOT NULL,
    [S_CR]      INT              NOT NULL,
    [S_CDT]     DATETIME         NOT NULL,
    [S_MR]      INT              NULL,
    [S_MDT]     DATETIME         NULL,
    [ARC]       INT              NULL,
    [ENBL]      INT              NOT NULL,
    [CAPTION]   NVARCHAR (350)   NOT NULL,
    [REMARK]    NTEXT            NULL,
    [MSGTO]     NVARCHAR (1024)  NOT NULL,
    [MSGCOPYTO] NVARCHAR (1025)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

