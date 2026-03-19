CREATE TABLE [dbo].[DEF_CLASS_STATES] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [OID]            INT              NOT NULL,
    [CLASSOID]       INT              NOT NULL,
    [NAME]           NVARCHAR (100)   NOT NULL,
    [STATECOLOR_old] VARCHAR (50)     NULL,
    [STATECOLOR]     INT              NULL,
    [GID]            UNIQUEIDENTIFIER NULL,
    [S_CR]           INT              NULL,
    [S_MR]           INT              NULL,
    [S_CDT]          DATETIME         NULL,
    [S_MDT]          DATETIME         NULL,
    [READONLYSTATE]  INT              NULL,
    [DESCRIPTION]    NVARCHAR (250)   NULL,
    [YESDEL]         INT              NULL,
    CONSTRAINT [PK_DEF_CLASS_STATES] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_CLASS_STATES_CLASSOID] FOREIGN KEY ([CLASSOID]) REFERENCES [dbo].[DEF_CLASSES] ([OID]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DEF_CLASS_STATES]
    ON [dbo].[DEF_CLASS_STATES]([OID] ASC) WITH (FILLFACTOR = 90);

