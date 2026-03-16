CREATE function [dbo].[COM_EMPLOYEE_ACCESS3](@aEmplID int,@aUser int,@aMode int,@aDate datetime)
returns int as 
begin
  /* 
  функция для фильтров в списках по сотрудникам 
  разрешено там где сотрудник = сам
  дальше ЕСЛИ СУПЕРВИЗОР или MNG - по отделу
  */  
  declare @aRowUserID int
  select top 1 @aRowUserID = A.ID from DEF_USERS A with (nolock) where A.EMPLOYEEID = @aEmplID
  
  if @aRowUserID = @aUser
    return 1  
  
  declare @DepID int
  
  select @DepID = B.DEPID
    from DEF_USERS A with (nolock) 
    left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
   where A.ID = @aRowUserID
   
  
  if dbo.COM_DEP_ACCESS(null,@DepID,@aMode,@aUser,@aDate) = 1
  begin
     if dbo.DEF_USERINGROUP(@aUser,17,@aDate) = 1 /*SP*/
       return 1
     if dbo.DEF_USERINGROUP(@aUser,25,@aDate) = 1 /*SPA*/
       return 1
     if dbo.DEF_USERINGROUP(@aUser,15,@aDate) = 1 /*MNG*/
       return 1
  end
  
  return 0
end