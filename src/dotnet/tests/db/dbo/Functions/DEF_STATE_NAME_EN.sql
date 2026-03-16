create function [dbo].[DEF_STATE_NAME_EN](@aStateOID int)
returns nvarchar(150) as 
begin
  declare @res nvarchar(150)
  select @res = A.NAME from DEF_CLASS_STATES A with (nolock) where A.OID = @aStateOID


  declare @i int
  set @i = CHARINDEX('[',@res)
  if @i > 0 
  begin
    if (SUBSTRING(@res,@i+3,1) = '=') or (SUBSTRING(@res,@i+2,1) = '=')
      set @res = SUBSTRING(@res,1,@i-1)
  end
  
  return @res;
end