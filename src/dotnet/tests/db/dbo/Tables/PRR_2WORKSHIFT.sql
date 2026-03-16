CREATE TABLE [dbo].[PRR_2WORKSHIFT] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NOT NULL,
    [S_S]        INT              NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [DEPID]      INT              NOT NULL,
    [YY]         INT              NOT NULL,
    [MM]         INT              NOT NULL,
    [REMARK]     NTEXT            NULL,
    [APPROVEDBY] INT              NULL,
    [APPROVEDDT] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PRR_2WORKSHIFT_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PRR_2WORKSHIFT_DEPID]
    ON [dbo].[PRR_2WORKSHIFT]([DEPID] ASC);

