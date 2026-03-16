CREATE TABLE [dbo].[PRR_LU_REPORT_REQUEST_SUM] (
    [ID]                            INT             IDENTITY (1, 1) NOT NULL,
    [VNESHID]                       INT             NOT NULL,
    [DEPID]                         INT             NULL,
    [YEAR]                          INT             NULL,
    [MONTH]                         INT             NULL,
    [DBEG]                          DATETIME        NULL,
    [DEND]                          DATETIME        NULL,
    [E_INCLUDED]                    INT             NULL,
    [H_AVAILABLE]                   DECIMAL (18, 2) NULL,
    [H_VACATIONS]                   DECIMAL (18, 2) NULL,
    [H_INOPERATIONS]                DECIMAL (18, 2) NULL,
    [KOEFF]                         DECIMAL (18, 2) NULL,
    [PRODUCED]                      INT             NULL,
    [H_AVAILABLE_RANDD]             DECIMAL (18, 2) NULL,
    [H_AVAILABLE_PRODSUPP]          DECIMAL (18, 2) NULL,
    [H_AVAILABLE_PRODSUPP_ASSIGNED] DECIMAL (18, 2) NULL,
    [H_AVAILABLE_PRODSUPP_POSTED]   DECIMAL (18, 2) NULL,
    [RANDD_PR]                      DECIMAL (16, 1) NULL,
    [PROD_SUPP_PR]                  DECIMAL (16, 1) NULL,
    [H_INOPERATIONS_CONST]          DECIMAL (18, 2) NULL,
    [CONST_RATIO]                   DECIMAL (16, 1) NULL,
    [H_PREPARATORY]                 DECIMAL (16, 1) NULL,
    [CONST_2PREPARATORY]            DECIMAL (16, 1) NULL,
    [PREPARATORY_RATIO]             DECIMAL (16, 1) NULL,
    [AFTER_CHANGE]                  INT             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_PRR_LU_REPORT_REQUEST_SUM_VNESHID] FOREIGN KEY ([VNESHID]) REFERENCES [dbo].[PRR_LU_REPORT_REQUEST] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PRR_LU_REPORT_REQUEST_SUM]
    ON [dbo].[PRR_LU_REPORT_REQUEST_SUM]([VNESHID] ASC);

