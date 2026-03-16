create function [dbo].[COM_DEPARTMENT3_WITHCHILDS2] ( @UserID int)
returns @res table (ID int)
as 
begin
/*
  v.2 + KB3638 added ADM role to view all
*/
   insert into @res (ID) 
   select ID from dbo.COM_GETCHILD_DEPARTMENTS2(dbo.COM_DEPARTMENT2(@UserID),1)
   
   if dbo.DEF_USERINGROUP7(@UserID,'ADM') = 1
   begin
	   insert into @res (ID) 
	   select ID from COM_DEPARTMENTS   
   end

   return 
    
end