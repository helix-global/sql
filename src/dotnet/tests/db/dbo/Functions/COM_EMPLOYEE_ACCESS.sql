CREATE function [dbo].[COM_EMPLOYEE_ACCESS](@aEmplID int,@aUser int,@aMode int,@aDate datetime)
returns int as 
begin
  /* 
  функция для фильтров в списках по сотрудникам 
  разрешено там где сотрудник = сам
  дальше проверка от отдела
  */  
  declare @UsEmpl int
  declare @DepID int
  
  select @UsEmpl = A.EMPLOYEEID 
        ,@DepID = B.DEPID
    from DEF_USERS A with (nolock) 
    left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
   where A.ID = @aUser
   
  if @UsEmpl = @aEmplID
    return 1
  
  declare @arc int
  set @arc = dbo.DEF_CLASS_ARC(1000061,null); /* employee */

 
  if dbo.DEF_F_ACCESS(@arc,null,3,getdate(),@aUser,0) = 0 /* view */
    return 0
  
  declare @res int
  select @res = dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate)
  return @res
end