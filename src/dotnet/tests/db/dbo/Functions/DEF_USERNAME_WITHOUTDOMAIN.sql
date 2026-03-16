CREATE function [dbo].[DEF_USERNAME_WITHOUTDOMAIN](@id int)
returns nvarchar(200) as 
begin
  declare @res nvarchar(200)
  select @res = A.LOGINNAME from DEF_USERS A with (nolock) where A.ID = @id
  
  if @res like '%\%'
  begin
  
     declare @i int = charindex('\',@res)
     if (@i > 0)
       set @res = substring(@res,@i+1,9999)
  
  
  end
  
  return @res
end