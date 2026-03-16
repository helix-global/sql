CREATE function [dbo].[DEF_VARIANT2BOOL](@aParam sql_variant)
returns int with schemabinding as 
begin
    declare @paramS nvarchar(max) 

    set @paramS = CAST(@aParam as nvarchar)
    set @paramS = RTRIM(LTRIM(UPPER(@paramS)))
    if @paramS = 'TRUE'
       return 1
    if @paramS = '1'
       return 1
    
    return 0
  
end