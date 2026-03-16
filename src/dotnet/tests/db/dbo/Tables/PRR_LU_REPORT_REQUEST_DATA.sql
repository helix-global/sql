CREATE TABLE [dbo].[PRR_LU_REPORT_REQUEST_DATA] (
    [ID]                            INT             IDENTITY (1, 1) NOT NULL,
    [VNESHID]                       INT             NOT NULL,
    [EMPLID]                        INT             NULL,
    [YEAR]                          INT             NULL,
    [MONTH]                         INT             NULL,
    [DBEG]                          DATETIME        NULL,
    [DEND]                          DATETIME        NULL,
    [E_INCLUDED]                    INT             NULL,
    [H_AVAILABLE]                   DECIMAL (18, 2) NULL,
    [H_AVAILABLE_PLAN]              DECIMAL (18, 2) NULL,
    [H_VACATIONS]                   DECIMAL (18, 2) NULL,
    [H_INOPERATIONS]                DECIMAL (18, 2) NULL,
    [ISRANDD]                       INT             NULL,
    [PRODSUPPORT]                   INT             NULL,
    [PARTINPRODUCTION]              DECIMAL (10, 4) NULL,
    [PARTINPRODUCTIONSUPPORT]       DECIMAL (10, 4) NULL,
    [PARTINRANDD]                   DECIMAL (18, 2) NULL,
    [H_AVAILABLE_RANDD]             DECIMAL (18, 2) NULL,
    [H_INOPERATIONS_RANDD]          DECIMAL (18, 2) NULL,
    [H_AVAILABLE_PRODSUPPORT]       DECIMAL (18, 2) NULL,
    [WTID]                          INT             NULL,
    [CALENDARID]                    INT             NULL,
    [H_INOPERATIONS_CONST]          DECIMAL (18, 2) NULL,
    [DEP_AVAILABLE_PRODSUPPORT]     DECIMAL (18, 2) NULL,
    [DEP_AVAILABLE_PRODSUPP_POSTED] DECIMAL (18, 2) NULL,
    [DEP_PROD_SUPP_FACTOR]          DECIMAL (18, 2) NULL,
    [AFTER_CHANGE]                  INT             NULL,
    [OPERS_100]                     DECIMAL (18, 2) NULL,
    [OPERS_101]                     DECIMAL (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PRR_LU_REPORT_REQUEST_DATA_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[PRR_LU_REPORT_REQUEST] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PRR_LU_REPORT_REQUEST_DATA]
    ON [dbo].[PRR_LU_REPORT_REQUEST_DATA]([VNESHID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'процент Production Support Assigment Share (по месяц-год-отдел)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRR_LU_REPORT_REQUEST_DATA', @level2type = N'COLUMN', @level2name = N'DEP_PROD_SUPP_FACTOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'знаменатель для вычисления Production Support Assigment Share (по месяц-год-отдел)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRR_LU_REPORT_REQUEST_DATA', @level2type = N'COLUMN', @level2name = N'DEP_AVAILABLE_PRODSUPP_POSTED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'числитель для вычисления Production Support Assigment Share (по месяц-год-отдел)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRR_LU_REPORT_REQUEST_DATA', @level2type = N'COLUMN', @level2name = N'DEP_AVAILABLE_PRODSUPPORT';

