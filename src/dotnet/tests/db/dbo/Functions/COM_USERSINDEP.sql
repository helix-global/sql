create function [dbo].[COM_USERSINDEP](@DepID int,@UserID int)  
 returns @res table(ID INT)
as 
begin  
  declare @departID int
  if (@DepID is not null)
     set @departID = @DepID
  else
  begin
   
    select @departID = B.DEPID
    from DEF_USERS A with (nolock)
    left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
    where A.ID = @UserID
  
  end

  insert into @res (ID)
  select A.ID 
  from DEF_USERS A  with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
  where B.DEPID = @departID
  
  return

end