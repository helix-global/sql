CREATE TABLE [dbo].[SYNC2_DELRULES] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [TABLEID]    INT              NOT NULL,
    [DELRULESQL] NTEXT            NOT NULL,
    [TORDER]     INT              NOT NULL,
    [REMARK]     NTEXT            NULL,
    [CHILDTNAME] NVARCHAR (50)    NOT NULL,
    [DISABLE]    INT              NULL,
    [OBJNAME]    NVARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SYNC2_DELRULES_TABLEID] FOREIGN KEY ([TABLEID]) REFERENCES [dbo].[SYNC2_TABLES] ([ID])
);

