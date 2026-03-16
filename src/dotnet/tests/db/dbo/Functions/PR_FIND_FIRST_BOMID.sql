CREATE function [dbo].PR_FIND_FIRST_BOMID(@MtID int,@BomID int)
returns int
as
begin

   declare @res int
   set @res = ''

   declare @bomName nvarchar(100)
   select @bomName = A.NAME
   from PR_MODELTYPE_BOM A with (nolock)
   where A.ID = @BomID
   
   set @bomName = replace(@bomName,'0','1')
   set @bomName = replace(@bomName,'9','1')
   set @bomName = replace(@bomName,'8','1')
   set @bomName = replace(@bomName,'7','1')
   set @bomName = replace(@bomName,'6','1')
   set @bomName = replace(@bomName,'5','1')
   set @bomName = replace(@bomName,'4','1')
   set @bomName = replace(@bomName,'3','1')
   set @bomName = replace(@bomName,'2','1')   
   set @bomName = replace(@bomName,'11','1')   
   set @bomName = replace(@bomName,'11','1')   
   set @bomName = replace(@bomName,'11','1')      
   
   select @res = A.ID
   from PR_MODELTYPE_BOM A with (nolock)
   where A.MTID = @MtID
     and upper(A.NAME) = upper(@bomName)
	   
     
   return @res  

end;