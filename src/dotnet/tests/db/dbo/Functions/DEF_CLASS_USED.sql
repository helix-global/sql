create function [dbo].[DEF_CLASS_USED](@aOID int)
returns nvarchar(50) as 
begin
  declare @res nvarchar(50)
  
  if exists (select * from DEF_INTERFACE_T with (nolock) where CLASSOID = @aOID)
    set @res = 'Interface'
    
  if exists (select * from DEF_CLASS_ENVS with (nolock) where TOCLASSOID = @aOID)  
  begin
     if @res is null 
        set @res = 'Enviropment'
     else
        set @res = @res+', Enviropment'
  end

  if exists (select * from DEF_ENTITY_FIELDS with (nolock) where OL_CLASSOID = @aOID)  
  begin
     if @res is null 
        set @res = 'Attribute Link'
     else
        set @res = @res+', Attribute Link'
  end

  
  return @res
end