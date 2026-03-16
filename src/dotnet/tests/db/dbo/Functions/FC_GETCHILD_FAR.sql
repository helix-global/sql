create function [dbo].[FC_GETCHILD_FAR] (@aids nvarchar(max))
returns @res table (ID int)
as 
begin
   /*возвращает ID дочерних FAR рекурсивно */

   insert into @res (ID)
   select distinct A.ID 
     from FC_REPORT A with (nolock) 
    where A.PARENTID in (select ID from dbo.COM_STR2TABLE_INT(@aids))
   
   declare @i int = 1
   while 1 = 1 
   begin
   
	   insert into @res (ID)
	   select distinct A.ID 
		 from FC_REPORT A with (nolock) 
		where A.PARENTID in (select ID from @res)
		  and not exists (select B.ID from @res B where B.ID = A.ID)
		  
		if @@rowcount = 0 break  
      
        if @i > 100 break
        set @i = @i + 1
        
   
   end

return

end