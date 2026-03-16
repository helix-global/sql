CREATE function [dbo].[PR_PRORDER_CUSTOM_COMMENTS](@aOrderID int)
returns nvarchar(1024)
as
begin
  declare @res nvarchar(1024)
  set @res = '';

  select @res = @res + cast(A.REMARK as nvarchar(max)) + CHAR(13)+ CHAR(10)
  from PR_PRORDER_PLAN A with (nolock)
  where A.ORDERID = @aOrderID
    and A.REMARK is not null
    
  declare @reslen int
  set @reslen = len(@res)
  if @reslen > 2
    set @res = SUBSTRING(@res,1,@reslen-1)
    
    
  if LEN(LTRIM(@res)) = 0
    return null  
    
  return @res;
end;