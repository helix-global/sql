CREATE function [dbo].[COM_OVERTIME_ACCESS_TAB] (@UserID int, @aMode int, @aDate datetime)
returns @res table (ID int)
as 
begin

   if dbo.DEF_USERINGROUP7(@UserID,'HWTF') = 1 /*KB3085*/
   begin
   
	 insert into @res (ID)
	 select dbo.DEF_EMPLOYEE(@UserID)
	 
	 return
   
   end

   if dbo.DEF_USERINGROUP7(@UserID,'HROHV') = 1 /*KB3939*/
   begin
   
	 insert into @res (ID)
	 select A.ID from COM_EMPLOYEE A with(nolock)
	 
	 return
   
   end
   

   insert into @res (ID)
   select ID 
   from dbo.COM_EMPLOYEE_ACCESS3_TAB(@UserID, @aMode, @aDate) 
   
   
   if dbo.DEF_USERINGROUP7(@UserID,'OTE') = 1 
   begin
     
      insert into @res (ID)
      select A.ID 
      from COM_EMPLOYEE A with (nolock)
      where A.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@UserID,@aMode,@aDate))
     
   end

  
   return

end