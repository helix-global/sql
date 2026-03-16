CREATE function [dbo].[COM_INDEPARTMENT](@aDepID int,@aUser int,@aDate datetime)
returns int as 
begin


  declare @EmpID int
  declare @DepID int
  
  select @EmpID = A.EMPLOYEEID
        ,@DepID = B.DEPID 
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B on B.ID = A.EMPLOYEEID 
  where A.ID = @aUser

  declare @parentdep int  
  declare @dep int
  declare @iii int
  set @iii = 1
  set @dep = @aDepID
  
  while (1=1)
  begin
     /*принадлежит отделу*/
     if (@DepID = @dep)
       return 1
       
     select @parentdep = A.PARENTDEPARTMENT from COM_DEPARTMENTS A with (nolock) where A.ID = @dep
     if @parentdep is null 
       break;
       
     set @dep = @parentdep
     
     set @iii = @iii + 1
     if @iii > 100
       return 0;   
    
  end  

  return 0;
end