CREATE function [dbo].[COM_EMPLOYEE_ACCESS3_TAB] (@UserID int, @aMode int, @aDate datetime)
returns @res table (ID int)
as 
begin

  /* 
  копия COM_EMPLOYEE_ACCESS3, но табличная 
  
  функция для фильтров в списках по сотрудникам 
  разрешено там где сотрудник = сам
  дальше ЕСЛИ СУПЕРВИЗОР или MNG - по отделу
  
  */  
  insert into @res (ID)
  select A.EMPLOYEEID
  from DEF_USERS A with (nolock) where A.ID = @UserID
  
  
  if dbo.DEF_USERINGROUP(@UserID,17,@aDate) = 1 /*SP*/ or dbo.DEF_USERINGROUP(@UserID,25,@aDate) = 1 /*SPA*/ or dbo.DEF_USERINGROUP(@UserID,15,@aDate) = 1 /*MNG*/
    or dbo.DEF_USERINGROUP7(@UserID,'DH&VICE') = 1 /*KB3582*/
  begin
     
    insert into @res (ID)
    select A.ID 
    from COM_EMPLOYEE A with (nolock)
    where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID,@aMode,@aDate))
     
     
  end


  /*   прямой, но медленный вариант 
   
   insert into @res (ID)
   select A.ID 
   from COM_EMPLOYEE A with (nolock)
   where dbo.COM_EMPLOYEE_ACCESS3(A.ID,@UserID,@aMode,@aDate)=1
   
  */
  
   return

end