CREATE TABLE [dbo].[temp_files] (
    [RID]   INT            NULL,
    [FNAME] NVARCHAR (200) NULL,
    [FDESC] NVARCHAR (200) NULL,
    [FDATE] DATETIME       NULL,
    [ID]    INT            IDENTITY (1, 1) NOT NULL
);

