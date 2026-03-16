CREATE function [dbo].[PR_OPERTYPE_QUALIFICATION](@OperTypeID int, @UserID int,@OnDate datetime)
returns int as 
begin
  declare @EmplID int
  select @EmplID = A.EMPLOYEEID from DEF_USERS A  with (nolock) where A.ID = @UserID
  declare @NeedQual int

  declare @prGroup int
  select @prGroup = B.OPERGRID from PR_OPERATIONS B with (nolock) where B.ID = @OperTypeID 

  if exists (select Q.ID 
               from PR_EMPL_TO_OPERGR Q with (nolock)
              where Q.EMPLOYEEID = @EmplID
                and Q.GROUPID = @prGroup )
    return 1
    
    
  return 0
end