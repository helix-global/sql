CREATE TABLE [dbo].[PCT_LOAD_DATA] (
    [Id]      INT             IDENTITY (1, 1) NOT NULL,
    [CatId]   INT             NOT NULL,
    [GrId]    INT             NOT NULL,
    [RegEx]   NVARCHAR (4000) NULL,
    [CatCode] NVARCHAR (1000) NULL,
    [CatName] NVARCHAR (1000) NULL,
    [GrCode]  NVARCHAR (1000) NULL,
    [GrName]  NVARCHAR (1000) NULL,
    CONSTRAINT [PK_PCT_LOAD_DATA] PRIMARY KEY CLUSTERED ([Id] ASC)
);

