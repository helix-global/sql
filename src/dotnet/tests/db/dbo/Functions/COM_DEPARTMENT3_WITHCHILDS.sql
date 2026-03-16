
create function [dbo].[COM_DEPARTMENT3_WITHCHILDS] ( @UserID int)
returns @res table (ID int)
as 
begin
/*
  как dbo.COM_DEPARTMENT2 только с дочерними подразделениями
*/
   insert into @res (ID) 
   select ID from dbo.COM_GETCHILD_DEPARTMENTS2(dbo.COM_DEPARTMENT2(@UserID),1)

   return 
    
end