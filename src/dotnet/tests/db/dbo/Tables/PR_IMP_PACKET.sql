CREATE TABLE [dbo].[PR_IMP_PACKET] (
    [ID]              INT              IDENTITY (1, 1) NOT NULL,
    [GID]             UNIQUEIDENTIFIER NULL,
    [S_S]             INT              NOT NULL,
    [S_CR]            INT              NOT NULL,
    [S_CDT]           DATETIME         NOT NULL,
    [S_MR]            INT              NULL,
    [S_MDT]           DATETIME         NULL,
    [ARC]             INT              NULL,
    [TYPEID]          INT              NOT NULL,
    [REMARKS]         NTEXT            NULL,
    [SPATH]           NVARCHAR (255)   NULL,
    [RECIEVED]        DATETIME         NULL,
    [WASSHIPPED_FLAG] INT              NULL,
    [WASSHIPPED_TO]   NVARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PR_IMP_PACKET_TYPEID] FOREIGN KEY ([TYPEID]) REFERENCES [dbo].[PR_IMP_TRANS] ([ID])
);

