create function [dbo].[DEF_STATE_NAME_X](@aStateOID int,@aLangCode nvarchar(2))
returns nvarchar(150) as 
begin
  declare @res nvarchar(150)
  select @res = A.NAME from DEF_CLASS_STATES A with (nolock) where A.OID = @aStateOID


  declare @i int
  set @i = CHARINDEX('[',@res)
  if @i > 0 
  begin
    set @res = dbo.COM_LANG_X(@res,@aLangCode)
  end
  
  return @res;
end