CREATE FUNCTION [dbo].[fn_test1]
( )
RETURNS NVARCHAR (MAX)
AS
 EXTERNAL NAME [IPG.PDB.SqlServer.Objects].[UserDefinedFunctions].[fn_test1]

