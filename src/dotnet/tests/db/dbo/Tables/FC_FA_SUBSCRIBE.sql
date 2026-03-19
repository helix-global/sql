CREATE TABLE [dbo].[FC_FA_SUBSCRIBE] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [GID]        UNIQUEIDENTIFIER NULL,
    [S_S]        INT              NOT NULL,
    [S_CR]       INT              NOT NULL,
    [S_CDT]      DATETIME         NOT NULL,
    [S_MR]       INT              NULL,
    [S_MDT]      DATETIME         NULL,
    [ARC]        INT              NULL,
    [EMPLOYEEID] INT              NOT NULL,
    [EXPDATE]    DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_FA_SUBSCRIBE_EMPLOYEEID] FOREIGN KEY ([EMPLOYEEID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);

