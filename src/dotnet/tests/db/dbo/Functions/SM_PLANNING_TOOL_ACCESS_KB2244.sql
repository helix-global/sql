CREATE function [dbo].[SM_PLANNING_TOOL_ACCESS_KB2244] (@UserID int, @mode int)
returns @res table (ID int)
as 
begin

  /*KB2244 */
  
  
  if dbo.DEF_USERINGROUP7(@UserID,'FSEgA') = 1 
  begin
     insert into @res (ID)
     select A.ID
       from SM_WORKORDER A with (nolock)
       where A.S_CR = @UserID
     
     /*KB2977*/
     insert into @res (ID)
     select A.ID
       from SM_WORKORDER A with (nolock)
       where A.EMPLID = dbo.DEF_EMPLOYEE(@UserID)
     
       
  end
  /*
  последняя группа WOMSG - эта группа которая давала права на работу с palnning tool до KB2244
  чтобы ее права не пропали, она включена
  */
  
  if dbo.DEF_USERINGROUP5(@UserID,'ISgB','SgC','HoSDgD','WOMSG',null) = 1
  begin
     insert into @res (ID)
     select A.ID
       from SM_WORKORDER A with (nolock)
  
  end
       
    
  return

end