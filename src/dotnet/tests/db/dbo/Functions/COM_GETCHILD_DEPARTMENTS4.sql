create function [dbo].[COM_GETCHILD_DEPARTMENTS4] (@aParentID int, @includeChildDeps bit)
returns @res table (ID int)
as 
begin

   /*
   возвращает только @aParentID если @includeChildDeps = 0
   возвращает @aParentID и ID дочерних отделов рекурсивно если @includeChildDeps = 1
   */

   insert into @res (ID) values (@aParentID)
   
   if isnull(@includeChildDeps,0) <> 1
   begin
     return
   end

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