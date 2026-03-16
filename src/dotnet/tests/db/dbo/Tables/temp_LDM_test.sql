CREATE TABLE [dbo].[temp_LDM_test] (
    [id]      INT           IDENTITY (1, 1) NOT NULL,
    [EMPID]   INT           NULL,
    [DBEG]    DATETIME      NULL,
    [reg]     NVARCHAR (20) NULL,
    [RECID]   INT           NULL,
    [daterec] DATETIME      CONSTRAINT [DF_temp_LDM_test_daterec] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_temp_LDM_test] PRIMARY KEY CLUSTERED ([id] ASC)
);

