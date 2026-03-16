create function [dbo].[DEF_OPERATION_USED](@aOID int)
returns nvarchar(50) as 
begin
  declare @res nvarchar(50)
  
  if exists (select * from DEF_INTERFACE_T with (nolock) where OPEROID = @aOID)
    set @res = 'Interface'
    
  if exists (select * from DEF_CLASS_ENVS with (nolock) where TOOPERATIONOID = @aOID)  
  begin
     if @res is null 
        set @res = 'Enviropment'
     else
        set @res = @res+', Enviropment'
  end
  
  return @res
end