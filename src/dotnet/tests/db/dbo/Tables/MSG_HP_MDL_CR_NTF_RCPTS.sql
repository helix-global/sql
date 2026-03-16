CREATE TABLE [dbo].[MSG_HP_MDL_CR_NTF_RCPTS] (
    [ID]                 INT              IDENTITY (1, 1) NOT NULL,
    [GID]                UNIQUEIDENTIFIER NOT NULL,
    [S_CR]               INT              NOT NULL,
    [S_CDT]              DATETIME         NOT NULL,
    [S_MR]               INT              NULL,
    [S_MDT]              DATETIME         NULL,
    [ARC]                INT              NULL,
    [EMPLID]             INT              NULL,
    [NOTIFICATIONTYPEID] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MSG_HP_MDL_CR_NTF_RCPTS_EMPLID] FOREIGN KEY ([EMPLID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);

