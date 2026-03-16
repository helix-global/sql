CREATE function [dbo].[PR_OPERGR_QUALIFICATION](@OperGRID int, @UserID int,@OnDate datetime)
returns int as 
begin

  declare @dd2 datetime
  set @dd2 = cast(@OnDate as date)

  if exists (select Q.ID 
               from PR_EMPL_TO_OPERGR Q with (nolock)
              where Q.EMPLOYEEID in (select A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @UserID)
                and Q.GROUPID = @OperGRID
                and ISNULL(Q.DBEG,'19900101') <= @dd2
                and ISNULL(Q.DEND,'40000101') >= @dd2
             )
    return 1
    
    
  return 0
end