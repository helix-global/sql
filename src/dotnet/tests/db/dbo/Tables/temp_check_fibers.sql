CREATE TABLE [dbo].[temp_check_fibers] (
    [SN]       NVARCHAR (50)  NULL,
    [CODE]     NVARCHAR (16)  NULL,
    [NAME]     NVARCHAR (100) NULL,
    [PARTSN]   NVARCHAR (50)  NULL,
    [PARTCODE] NVARCHAR (16)  NULL
);


GO
CREATE NONCLUSTERED INDEX [Ix_temp_check_fibers]
    ON [dbo].[temp_check_fibers]([SN] ASC, [CODE] ASC, [NAME] ASC, [PARTSN] ASC, [PARTCODE] ASC);

