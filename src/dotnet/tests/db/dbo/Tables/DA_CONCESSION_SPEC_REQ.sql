CREATE TABLE [dbo].[DA_CONCESSION_SPEC_REQ] (
    [ID]                 INT              IDENTITY (1, 1) NOT NULL,
    [GID]                UNIQUEIDENTIFIER NOT NULL,
    [S_CR]               INT              NOT NULL,
    [S_CDT]              DATETIME         NOT NULL,
    [S_MR]               INT              NULL,
    [S_MDT]              DATETIME         NULL,
    [ARC]                INT              NULL,
    [VNESHID]            INT              NOT NULL,
    [POS]                NVARCHAR (10)    NULL,
    [CHARACTERISITICS]   NTEXT            NULL,
    [PARAMETER]          NTEXT            NULL,
    [MIN_VALUE]          NVARCHAR (250)   NULL,
    [TYP_VAULE]          NVARCHAR (250)   NULL,
    [MAX_VALUE]          NVARCHAR (250)   NULL,
    [UNIT]               NVARCHAR (50)    NULL,
    [MIN_VALUE_ACC]      NVARCHAR (250)   NULL,
    [TYP_VAULE_ACC]      NVARCHAR (250)   NULL,
    [MAX_VALUE_ACC]      NVARCHAR (250)   NULL,
    [MIN_VALUE_ACC_BOLD] INT              NULL,
    [TYP_VAULE_ACC_BOLD] INT              NULL,
    [MAX_VALUE_ACC_BOLD] INT              NULL,
    [PARAMETER_ACC]      NTEXT            NULL,
    [PARAMETER_ACC_BOLD] INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DA_CONCESSION_SPEC_REQ_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[DA_CONCESSION] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_DA_CONCESSION_SPEC_REQ]
    ON [dbo].[DA_CONCESSION_SPEC_REQ]([VNESHID] ASC);

