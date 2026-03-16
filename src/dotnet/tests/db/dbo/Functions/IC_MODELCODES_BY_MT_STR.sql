CREATE function [dbo].[IC_MODELCODES_BY_MT_STR](@mtid int)
returns nvarchar(max) as 
begin
  
  declare @res nvarchar(max) = ''
  
  select @res = @res + A.CODE + ','
  from PR_MODELS A with (nolock)
  where A.TYPEID = @mtid
    
  if LEN(LTRIM(@res)) = 0
    return null  
    
  declare @reslen int
  set @reslen = len(@res)
  if @reslen > 2
    set @res = SUBSTRING(@res,1,@reslen-1)

  
  return @res
  
end