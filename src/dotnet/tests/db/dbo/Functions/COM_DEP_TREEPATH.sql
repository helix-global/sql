CREATE function [dbo].[COM_DEP_TREEPATH](@aDepID int)
returns nvarchar(max) as 
begin

   declare @res nvarchar(max) = ''
   declare @i int = 1
   
   declare @parentID int = @aDepID
   
   while 1=1
   begin
   
	   select @res =  A.CODE + '.' + @res
			 ,@parentID = A.PARENTDEPARTMENT
		 from COM_DEPARTMENTS A with (nolock)
		where A.ID = @parentID

       if @parentID is null break

       set @i = @i +1
       if @i > 500 break
   
   end
   
   set @res = @res + cast(@i as nvarchar)
   
   return @res 

end