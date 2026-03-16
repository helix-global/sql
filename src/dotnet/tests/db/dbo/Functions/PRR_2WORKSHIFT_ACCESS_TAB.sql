CREATE function [dbo].[PRR_2WORKSHIFT_ACCESS_TAB] (@UserID int, @aMode int, @aDate datetime)
returns @res table (ID int)
as 
begin

/* KB3327 */  

  insert into @res (ID)
  select A.ID
  from PRR_2WORKSHIFT A with (nolock) 
  where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID,@aMode,@aDate))
  
  
  if dbo.DEF_USERINGROUP7(@UserID,'HR') = 1
  begin
     
    insert into @res (ID)
    select A.ID 
    from PRR_2WORKSHIFT A with (nolock) 
    where A.S_S = 2130081  /*approved*/
     
     
  end
  
  return

end