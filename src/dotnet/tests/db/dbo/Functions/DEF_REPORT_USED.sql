CREATE function [dbo].[DEF_REPORT_USED](@aOID int)
returns nvarchar(50) as 
begin
  declare @res nvarchar(50)
  
  if exists (select * from DEF_INTERFACE_T with (nolock) where REPORTOID = @aOID)
    set @res = 'Interface'
    
  if exists (select * from DEF_CLASS_ENVS with (nolock) where TOREPORTOID = @aOID)  
  begin
     if @res is null 
        set @res = 'Enviropment'
     else
        set @res = @res+', Enviropment'
  end
  
  return @res
end