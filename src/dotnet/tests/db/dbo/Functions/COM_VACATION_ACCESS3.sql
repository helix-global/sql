CREATE function [dbo].[COM_VACATION_ACCESS3](@aCR int, @aState int,@aEmplID int,@aUserID int,@aMode int,@aDate datetime)
returns int as 
begin

  if dbo.DEF_USERINGROUP4(@aUserID,'HR',@aDate) = 1 --KB945
    return 1

  declare @myEmplID int
  select @myEmplID = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID

  if @myEmplID = @aEmplID
    return 1
  
  if (@aState = 1)
  begin
    if (@aCR = @aUserID)
      return 1
    if (@myEmplID <> @aEmplID)
      return 0
  end  
  
  if dbo.DEF_USERINGROUP7(@aUserID,'HWTF') = 1 /*KB3085*/
    return 0  /*условие на свои сработает выше*/
    
    
  declare @DepID int
  
  select @DepID = B.DEPID
    from COM_EMPLOYEE B with (nolock)
   where B.ID = @aEmplID
   
  
  if dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUserID,@aDate) = 1
  begin
     if dbo.DEF_USERINGROUP4(@aUserID,'SPV',@aDate) = 1 
       return 1
     if dbo.DEF_USERINGROUP4(@aUserID,'MNG',@aDate) = 1 
       return 1
     if dbo.DEF_USERINGROUP4(@aUserID,'DH&VICE',@aDate) = 1 
       return 1
     if dbo.DEF_USERINGROUP4(@aUserID,'VA',@aDate) = 1 /*Vacation Aproval*/
       return 1
     if dbo.DEF_USERINGROUP4(@aUserID,'VAVIEW',@aDate) = 1 /*Vacation View KB2537*/
       return 1
       
     if dbo.DEF_USERINGROUP4(@aUserID,'OGH3',@aDate) = 1 /*OGH3 KB821*/
     begin
       if @aState = 1000141/*approved*/
       begin
         if exists (select B.ID 
                      from PR_EMPL_TO_OPERGR A with (nolock) 
                      left join PR_EMPL_TO_OPERGR B with (nolock) on B.GROUPID = A.GROUPID and B.DEPID = A.DEPID
                     where A.EMPLOYEEID = @myEmplID
                       and A.DEPID = @DepID
                       and B.EMPLOYEEID = @aEmplID
                       and isnull(A.DBEG,'20000101') <= @aDate
                       and isnull(A.DEND,'40000101') > @aDate
                       and isnull(B.DBEG,'20000101') <= @aDate
                       and isnull(B.DEND,'40000101') > @aDate
                     )
                     return 1
       end
     end  
       
  end
  
  if dbo.DEF_USERINGROUP4(@aUserID,'MNGD',@aDate) = 1 and exists (select J.ID from COM_DH_VP_SETTINGS_T J with (nolock) where J.EMPLID = @aEmplID)
       return 1  
  
  return 0    
  
end