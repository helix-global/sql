create function [dbo].[COM_SHOW_VACATIONS_MENU](@aUser int)
returns int as 
begin


  declare @DepID int
  
  select @DepID = B.DEPID 
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID 
  where A.ID = @aUser

  if exists (select G.ID 
               from PR_NAV_VAC_DEPMODES G with (nolock) 
              where G.DEPID = @DepID 
                and isnull(G.SHOWMENU,0) = 1
             )
       return 1;         
  
  return 0;
end