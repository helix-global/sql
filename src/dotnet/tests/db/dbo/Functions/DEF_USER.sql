create function [dbo].[DEF_USER](@id int,@aMode int)
returns nvarchar(200) as 
begin
  declare @res nvarchar(200)
  select @res = A.FULLNAME from DEF_USERS A with (nolock) where A.ID = @id
  return @res
end