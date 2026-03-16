CREATE TABLE [dbo].[HH_PROJECT] (
    [ID]     INT              IDENTITY (1, 1) NOT NULL,
    [GID]    UNIQUEIDENTIFIER NULL,
    [S_S]    INT              NOT NULL,
    [S_CR]   INT              NOT NULL,
    [S_CDT]  DATETIME         NOT NULL,
    [S_MR]   INT              NULL,
    [S_MDT]  DATETIME         NULL,
    [ARC]    INT              NULL,
    [DEPID]  INT              NOT NULL,
    [DD]     DATETIME         NOT NULL,
    [REMARK] NTEXT            NULL,
    [NAME]   NVARCHAR (250)   NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_HH_PROJECT_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

