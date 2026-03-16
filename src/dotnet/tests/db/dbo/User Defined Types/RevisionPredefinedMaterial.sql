CREATE TYPE [dbo].[RevisionPredefinedMaterial] AS TABLE (
    [CODE]        NVARCHAR (16)   NOT NULL,
    [UCATEGORY]   NVARCHAR (200)  NULL,
    [QUANTITY]    DECIMAL (18, 6) NOT NULL,
    [TYPICAL2NAV] INT             NULL,
    [OPTIONNAME]  NVARCHAR (300)  NULL,
    [OPERID]      INT             NOT NULL);

