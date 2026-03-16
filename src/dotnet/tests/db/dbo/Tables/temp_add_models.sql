CREATE TABLE [dbo].[temp_add_models] (
    [NAME]     NVARCHAR (250) NULL,
    [CODE]     NVARCHAR (50)  NULL,
    [DEPID]    INT            NULL,
    [EX]       INT            NULL,
    [MT]       INT            NULL,
    [MTC]      INT            NULL,
    [ID]       INT            IDENTITY (1, 1) NOT NULL,
    [DEP_SUPP] INT            NULL
);

