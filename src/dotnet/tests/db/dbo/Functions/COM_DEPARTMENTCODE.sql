create function [dbo].[COM_DEPARTMENTCODE](@aDepID int)
returns nvarchar(100) as 
begin

  declare @res nvarchar(100)

  select @res = A.CODE
  from COM_DEPARTMENTS A with (nolock)
  where A.ID = @aDepID
  
  return @res
  
end