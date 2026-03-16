CREATE TABLE [dbo].[CAPT_EYE_FI_CARDS] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [NAME]         NVARCHAR (255)   NOT NULL,
    [DEPID]        INT              NOT NULL,
    [PRTADDR]      NVARCHAR (100)   NOT NULL,
    [POSORDER]     INT              NULL,
    [ITDEVICENAME] NVARCHAR (255)   NULL,
    [TYPE]         INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PR_EYE_FI_CARDS_DEPID] FOREIGN KEY ([DEPID]) REFERENCES [dbo].[COM_DEPARTMENTS] ([ID])
);

