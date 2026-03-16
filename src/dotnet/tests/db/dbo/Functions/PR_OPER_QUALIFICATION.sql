CREATE function [dbo].[PR_OPER_QUALIFICATION](@OperID int, @UserID int,@OnDate datetime)
returns int as 
begin
  declare @EmplID int
  select @EmplID = A.EMPLOYEEID from DEF_USERS A  with (nolock) where A.ID = @UserID
  declare @NeedQual int

  declare @prGroup int
  select @prGroup = (select B.OPERGRID from PR_OPERATIONS B with (nolock) where B.ID = 
      (select A.OPERTYPEID from PR_OPERATION A with (nolock) where A.ID = @OperID) )

  declare @dd2 datetime
  set @dd2 = cast(@OnDate as date)

  if exists (select Q.ID 
               from PR_EMPL_TO_OPERGR Q with (nolock)
              where Q.EMPLOYEEID = @EmplID
                and Q.GROUPID = @prGroup 
                and ISNULL(Q.DBEG,'19900101') <= @dd2
                and ISNULL(Q.DEND,'40000101') >= @dd2
             )
    return 1
    
    
  return 0
end