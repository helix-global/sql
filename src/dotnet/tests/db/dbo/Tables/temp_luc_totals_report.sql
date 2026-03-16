CREATE TABLE [dbo].[temp_luc_totals_report] (
    [CODE]                 NVARCHAR (100)  NULL,
    [DEPID]                INT             NOT NULL,
    [YEAR]                 INT             NOT NULL,
    [MONTH]                INT             NOT NULL,
    [DBEG]                 DATETIME        NULL,
    [DEND]                 DATETIME        NULL,
    [E_INCLUDED]           INT             NULL,
    [H_AVAILABLE]          DECIMAL (18, 2) NULL,
    [H_VACATIONS]          DECIMAL (18, 2) NULL,
    [H_INOPERATIONS]       DECIMAL (18, 2) NULL,
    [KOEFF]                DECIMAL (18, 2) NULL,
    [PRODUCED]             INT             NULL,
    [H_AVAILABLE_RANDD]    DECIMAL (18, 2) NULL,
    [H_AVAILABLE_PRODSUPP] DECIMAL (18, 2) NULL,
    [RANDD_PR]             DECIMAL (16, 1) NULL,
    [PROD_SUPP_PR]         DECIMAL (16, 1) NULL,
    [H_INOPERATIONS_CONST] DECIMAL (18, 2) NULL,
    [CONST_RATIO]          DECIMAL (16, 1) NULL,
    [H_PREPARATORY]        DECIMAL (16, 1) NULL,
    [CONST_2PREPARATORY]   DECIMAL (16, 1) NULL,
    [PREPARATORY_RATIO]    DECIMAL (16, 1) NULL
);

