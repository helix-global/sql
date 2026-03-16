CREATE TABLE [dbo].[IMS_TRAINING_TYPE] (
    [ID]      INT              IDENTITY (1, 1) NOT NULL,
    [GID]     UNIQUEIDENTIFIER NOT NULL,
    [S_CR]    INT              NOT NULL,
    [S_CDT]   DATETIME         NOT NULL,
    [S_MR]    INT              NULL,
    [S_MDT]   DATETIME         NULL,
    [ARC]     INT              NULL,
    [NAME]    NVARCHAR (250)   NOT NULL,
    [CHNORM]  NVARCHAR (150)   NULL,
    [REMARK]  NTEXT            NULL,
    [DEPID]   INT              NOT NULL,
    [INT_EXT] INT              NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_IMS_TRAINING_TYPE_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

