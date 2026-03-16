CREATE TABLE [dbo].[PR_PRORD_STAGES] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [DEPARTMENTID] INT              NOT NULL,
    [NAME]         NVARCHAR (200)   NOT NULL,
    [DESCRIPTION]  NTEXT            NULL,
    [STCOLOR]      INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_PRORD_STAGES_DEPARTMENTID] FOREIGN KEY ([DEPARTMENTID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_PRORD_STAGES]
    ON [dbo].[PR_PRORD_STAGES]([DEPARTMENTID] ASC);

