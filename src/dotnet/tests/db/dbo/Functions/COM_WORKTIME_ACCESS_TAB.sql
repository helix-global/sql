CREATE function [dbo].[COM_WORKTIME_ACCESS_TAB] (@UserID int, @aMode int, @aDate datetime)
returns @res table (ID int)
as 
begin

    
  if dbo.DEF_USERINGROUP5(@UserID,'WHRO','LA',null,null,null) = 1
  begin

	  insert into @res (ID)
	  select A.ID 
	  from COM_WORKTIME A with (nolock)
	  
	  return
  
  end
   
  insert into @res (ID)
  select A.ID 
  from COM_WORKTIME A with (nolock)
  where dbo.COM_DEP_ACCESS(null,A.DEPID,1,@UserID,getdate())=1
   
   
  return

end