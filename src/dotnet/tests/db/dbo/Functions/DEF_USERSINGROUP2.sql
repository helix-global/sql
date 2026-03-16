CREATE function [dbo].[DEF_USERSINGROUP2](@aGroupName nvarchar(50))  
 returns @res table(ID INT)
as 
begin  

  declare @now datetime
  set @now = GETDATE()

  insert into @res (ID)
  select B.USERID
  from DEF_USERS A
  left join DEF_USERSTOGROUP B  with (nolock) on B.GROUPID = A.ID
  where A.LOGINNAME = @aGroupName
    and A.ISGROUP = 1
    and (B.DCLS is null or B.DCLS >= cast(@now as date))
    and B.USERID is not null
  
  return

end