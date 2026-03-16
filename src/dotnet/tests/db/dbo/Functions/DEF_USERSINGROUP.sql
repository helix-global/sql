CREATE function [dbo].[DEF_USERSINGROUP](@GroupID int)  
 returns @res table(ID INT)
as 
begin  

  declare @now datetime
  set @now = GETDATE()

  insert into @res (ID)
  select A.USERID
  from DEF_USERSTOGROUP A  with (nolock)
  where A.GROUPID = @GroupID
    and (A.DCLS is null or A.DCLS >= cast(@now as date))
  
  return

end