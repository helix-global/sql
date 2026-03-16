CREATE function [dbo].[COM_EMPLOYEE_IN_REPORTS](@UserID int, @aMode int, @aDate datetime)
returns @res table (ID int)
begin
  
  /* для KB821 выдает список сотрудников по которым UserID может получать отчет Daily Working Time 
     члены роли 'OGH3'видят только сотрудников из своих групп
  */
  
     if dbo.DEF_USERINGROUP4(@UserID,'OGH3',@aDate) = 1 
     begin
        
        declare @myEmplID int
        declare @myDepID int
        
        select @myEmplID = A.EMPLOYEEID
              ,@myDepID = B.DEPID
          from DEF_USERS A with (nolock)
          left join COM_EMPLOYEE B  with (nolock) on B.ID = A.EMPLOYEEID
          where A.ID = @UserID
     
        insert into @res (ID)
        select distinct B.EMPLOYEEID
          from PR_EMPL_TO_OPERGR A with (nolock) 
          left join PR_EMPL_TO_OPERGR B with (nolock) on B.GROUPID = A.GROUPID and B.DEPID = A.DEPID
         where A.EMPLOYEEID = @myEmplID
           and A.DEPID = @myDepID
           and isnull(A.DBEG,'20000101') <= @aDate
           and isnull(A.DEND,'40000101') > @aDate
           and isnull(B.DBEG,'20000101') <= @aDate
           and isnull(B.DEND,'40000101') > @aDate
           
     end
     else 
     begin
       insert into @res (ID)
       select EMP.ID 
       FROM COM_EMPLOYEE EMP with (nolock)
       where EMP.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID,@aMode,@aDate))
     end  

  

  return

end