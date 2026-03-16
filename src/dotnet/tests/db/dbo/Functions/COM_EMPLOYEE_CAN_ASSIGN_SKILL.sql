CREATE function [dbo].[COM_EMPLOYEE_CAN_ASSIGN_SKILL] (@aSkillID int, @aMode int)
returns @res table (ID int)
as 
begin

  if @aSkillID is null
  begin
     insert into @res (ID) 
     select E.ID from COM_EMPLOYEE E with (nolock)
     
     return
  end
  
  declare @prodSupport int
  select @prodSupport = isnull(A.PRODUCTION_SUPPORT,0)
    from COM_SKILLS A with (nolock)
   where A.ID = @aSkillID

  if @prodSupport = 1
  begin
     insert into @res (ID) 
     select E.ID from COM_EMPLOYEE E with (nolock)
     
     return
  end

  insert into @res (ID) 
  select E.ID
    from COM_EMPLOYEE E with (nolock)
    join PR_EMPL_TO_OPERGR G with (nolock) on E.ID=G.EMPLOYEEID 
    left join COM_OPERATION_GROUP_SKILL S with (nolock) on G.GROUPID=S.OPERGROUP_ID
    left join PR_OPERATIONS O with (nolock) on G.GROUPID=O.OPERGRID 
    left join COM_OPERATION_SKILL OS with (nolock) on O.ID=OS.OPERFORM_ID 
    where (S.SKILLID=@aSkillID or OS.SKILLID=@aSkillID) 
      and dbo.COM_EMPLOYEE_HAS_SKILL(E.ID,@aSkillID)=0 
  
   return

end