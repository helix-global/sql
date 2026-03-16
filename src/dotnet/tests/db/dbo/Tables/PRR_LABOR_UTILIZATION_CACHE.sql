CREATE TABLE [dbo].[PRR_LABOR_UTILIZATION_CACHE] (
    [ID]                        INT             IDENTITY (1, 1) NOT NULL,
    [DEPID]                     INT             NOT NULL,
    [DD]                        DATE            NOT NULL,
    [MONTH]                     INT             NOT NULL,
    [YEAR]                      INT             NOT NULL,
    [ALLPRODUCED]               INT             NULL,
    [EMPL_COUNT]                INT             NULL,
    [ALL_MH]                    DECIMAL (18, 2) NULL,
    [ALL_MH_VACATIONS]          DECIMAL (18, 2) NULL,
    [ALL_MH_DELTA]              DECIMAL (18, 2) NULL,
    [MH_INOPERATIONS]           DECIMAL (18, 2) NULL,
    [MH_INOPERATIONS_INDEP]     DECIMAL (18, 2) NULL,
    [MH_INOPERATIONS_NOT_INDEP] DECIMAL (18, 2) NULL,
    [DEV_PR]                    DECIMAL (16, 1) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PRR_LABOR_UTILIZATION_CACHE_1]
    ON [dbo].[PRR_LABOR_UTILIZATION_CACHE]([DEPID] ASC, [DD] ASC);

