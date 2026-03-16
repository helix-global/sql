CREATE function [dbo].[COM_GETPARENT_DEPARTMENTS] (@aID int, @aIncludeInputID int)
returns @res table (ID int)
as 
begin
   /*возвращает ID родительских отделов рекурсивно */

   if @aID is null 
     return

   declare @ParentID int
   declare @ParentID2 int

   set @ParentID = @aID
   
   if @aIncludeInputID = 1 
      insert into @res (ID) values (@aID)
  
   declare @i int = 1
   while 1 = 1 
   begin
       set @ParentID2 = null

	   select @ParentID2 = A.PARENTDEPARTMENT from COM_DEPARTMENTS A with (nolock) where A.ID = @ParentID
   
	   if @ParentID2 is not null
	   begin
		 insert into @res (ID) values (@ParentID2)
		 set @ParentID = @ParentID2
	   end  
	   else
	   begin
		 return
	   end
	   
        if @i > 30 break  /*avoid loops*/
        set @i = @i + 1

   end

return

end