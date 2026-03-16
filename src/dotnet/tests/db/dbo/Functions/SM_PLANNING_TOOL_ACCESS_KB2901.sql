create function [dbo].[SM_PLANNING_TOOL_ACCESS_KB2901] (@UserID int, @mode int)
returns @res table (ID int)
as 
begin

  /*KB2901
    возвращает список сотрудников в соотв. с KB2901 
   */
  
  
  if dbo.DEF_USERINGROUP7(@UserID,'FSEgA') = 1 
  begin
     insert into @res (ID)
     select dbo.DEF_EMPLOYEE(@UserID)
     
     return
     
  end
  else
  begin

     insert into @res (ID)
     select A.ID
       from COM_EMPLOYEE A with (nolock)
      where A.DEPID in (select BB.ID from dbo.COM_ACCESS_DEPARTMENTS2(@UserID,1,getdate()) BB)
        and A.DEPID in (select KK.DEPID from SM_EMAIL_BOXES KK with (nolock))
  
  end
       
    
  return

end