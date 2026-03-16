create function [dbo].[PR_OPER_QUALIFICATION_TAB](@UserID int,@OnDate datetime)
returns @res table (ID int)
as 
begin

  insert into @res (ID) 
  select K.OPERTYPEID from PR_OPERATIONS_RAW_BYUSER K with (nolock, noexpand) 
                  left join PR_EMPL_TO_OPERGR Q with (nolock) on Q.ID = K.LINKID
                  where K.USERID = @UserID
                    and ISNULL(Q.DBEG,'19900101') <= cast(@OnDate as date)
                    and ISNULL(Q.DEND,'40000101') >= cast(@OnDate as date)
  return
  
end