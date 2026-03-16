CREATE AGGREGATE [dbo].[fn_str_join](@Value SQL_VARIANT NULL, @Delimiter NVARCHAR (MAX) NULL, @Flags NVARCHAR (MAX) NULL)
    RETURNS NVARCHAR (MAX)
    EXTERNAL NAME [IPG.PDB.SqlServer.Objects].[fn_str_join];

