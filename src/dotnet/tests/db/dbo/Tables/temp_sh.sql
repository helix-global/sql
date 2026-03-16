CREATE TABLE [dbo].[temp_sh] (
    [id]                 INT            IDENTITY (1, 1) NOT NULL,
    [PartNumber]         NVARCHAR (100) NULL,
    [CRM_Name]           NVARCHAR (500) NULL,
    [CRM_Description]    NVARCHAR (MAX) NULL,
    [CRM_Responsibility] NVARCHAR (MAX) NULL,
    [CRM_Type]           NVARCHAR (100) NULL,
    [PCT_Name]           NVARCHAR (100) NULL,
    [PCT_Description]    NVARCHAR (MAX) NULL,
    [PCT_Description2]   NVARCHAR (MAX) NULL,
    [PCT_Responsibility] NVARCHAR (100) NULL,
    [PCT_Option]         NVARCHAR (100) NULL,
    [PDB_Name]           NVARCHAR (500) NULL,
    [PDB_Description]    NVARCHAR (MAX) NULL,
    [PDB_Owner]          NVARCHAR (100) NULL,
    [PDB_Type]           NVARCHAR (100) NULL,
    CONSTRAINT [PK_temp_sh] PRIMARY KEY CLUSTERED ([id] ASC)
);

