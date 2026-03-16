CREATE TABLE [dbo].[HR_CH_EMP_OPT] (
    [ID]               INT      IDENTITY (1, 1) NOT NULL,
    [S_CR]             INT      NULL,
    [S_CDT]            DATETIME NULL,
    [S_MR]             INT      NULL,
    [S_MDT]            DATETIME NULL,
    [EMPID]            INT      NOT NULL,
    [BALANCE_SHRT_ABS] INT      DEFAULT ((480)) NULL,
    [BALANCE_OVERTIME] INT      DEFAULT ((480)) NULL,
    [SHRT_ABS_MAX]     INT      DEFAULT ((225)) NULL,
    [SHRT_ABS_HDV]     INT      DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_HR_CH_EMP_OPT] FOREIGN KEY ([EMPID]) REFERENCES [dbo].[COM_EMPLOYEE] ([ID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table is used to store employee associated data related to the value of compensation hour limits.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HR_CH_EMP_OPT';

