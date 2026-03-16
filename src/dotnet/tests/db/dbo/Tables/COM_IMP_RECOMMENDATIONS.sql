CREATE TABLE [dbo].[COM_IMP_RECOMMENDATIONS] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [GID]            UNIQUEIDENTIFIER NOT NULL,
    [S_S]            INT              NOT NULL,
    [S_CR]           INT              NOT NULL,
    [S_CDT]          DATETIME         NOT NULL,
    [S_MR]           INT              NULL,
    [S_MDT]          DATETIME         NULL,
    [ARC]            INT              NULL,
    [INITIATIVE_NUM] NVARCHAR (11)    NULL,
    [INITIATOR]      INT              NULL,
    [IMP_TYPE]       INT              NULL,
    [DESCR]          NTEXT            NULL,
    [SPV_COMMENT]    NTEXT            NULL,
    [PLM_COMMENT]    NTEXT            NULL,
    [RESULT]         NTEXT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_COM_IMP_RECOMMENDATIONS_INITIATOR] FOREIGN KEY ([INITIATOR]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);

