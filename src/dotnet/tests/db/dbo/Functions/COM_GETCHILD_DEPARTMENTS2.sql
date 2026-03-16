create function [dbo].[COM_GETCHILD_DEPARTMENTS2] (@aParentID int, @aIncludeInputID int)
returns @res table (ID int)
as 
begin
   /*возвращает ID дочерних отделов рекурсивно */

   if @aIncludeInputID = 1
     insert into @res (ID) values (@aParentID)

   insert into @res (ID)
   select distinct A.ID 
     from COM_DEPARTMENTS A with (nolock) 
    where A.PARENTDEPARTMENT = @aParentID
   
   if @@rowcount = 0
     return
   
   declare @i int = 1
   while 1 = 1 
   begin
   
	   insert into @res (ID)
	   select distinct A.ID 
		 from COM_DEPARTMENTS A with (nolock) 
		where A.PARENTDEPARTMENT in (select ID from @res)
		  and not exists (select B.ID from @res B where B.ID = A.ID)
		  
		if @@rowcount = 0 break  
      
        if @i > 30 break
        set @i = @i + 1
   
   end

return

end