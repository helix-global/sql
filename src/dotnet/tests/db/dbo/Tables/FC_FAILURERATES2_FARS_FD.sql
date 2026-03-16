CREATE TABLE [dbo].[FC_FAILURERATES2_FARS_FD] (
    [FYEAR]          INT             NOT NULL,
    [FMONTH]         INT             NOT NULL,
    [MTID]           INT             NOT NULL,
    [MODELID]        INT             NOT NULL,
    [FCODE]          INT             NULL,
    [FACODE]         INT             NOT NULL,
    [FCOUNT]         DECIMAL (14, 4) NULL,
    [FRATE]          DECIMAL (14, 2) NULL,
    [PRODUCED_COUNT] DECIMAL (14, 4) NULL,
    [FCOUNT_INT]     DECIMAL (14, 4) NULL,
    [FCOUNT_EXT]     DECIMAL (14, 4) NULL,
    CONSTRAINT [FK_FC_FAILURERATES2_FARS_FD_2_FACODE] FOREIGN KEY ([FACODE]) REFERENCES [dbo].[FC_FAILUREANALYSISCODES] ([ID]) ON DELETE CASCADE
);

