CREATE TABLE [dbo].[PRR_OVERHOURS] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NOT NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [DEPID]       INT              NOT NULL,
    [YY]          INT              NOT NULL,
    [MM]          INT              NOT NULL,
    [REMARK]      NTEXT            NULL,
    [INCLTEMP]    INT              NULL,
    [INCLWITHOUT] INT              NULL,
    [LESSMINUTES] INT              NULL,
    [EXCSUNDAY]   INT              NULL,
    [APPROVEDBY]  INT              NULL,
    [APPROVEDDT]  DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PRR_OVERHOURS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

