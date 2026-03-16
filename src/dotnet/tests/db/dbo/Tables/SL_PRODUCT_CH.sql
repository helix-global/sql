CREATE TABLE [dbo].[SL_PRODUCT_CH] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_S]         INT              NOT NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [MODELID]     INT              NOT NULL,
    [NAME]        NVARCHAR (300)   NULL,
    [DESCSTR]     NVARCHAR (300)   NULL,
    [DESCRIPTION] NTEXT            NULL,
    [TAGS]        NVARCHAR (300)   NULL,
    [MPICT]       IMAGE            NULL,
    [SPEC]        NVARCHAR (200)   NULL,
    [NEWTAGS]     NVARCHAR (300)   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_SL_PRODUCTS_MODELID] FOREIGN KEY ([MODELID]) REFERENCES [dbo].[PR_MODELS] ([ID])
);

