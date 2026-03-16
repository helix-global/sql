CREATE function [dbo].[SM_SERVICECASE_SERVNN](@CaseID int,@aMode int)
returns nvarchar(max)
as
begin

   if @CaseID is null
       return null

   declare @res nvarchar(max)
   set @res = ''
	
   select @res = @res + ltrim(rtrim(A.RESULTORDERNUMBER)) + ', '  
   from PDB_BUFFER..SERVICEREQUEST A with (nolock)
   where A.SCASEID = @CaseID
     and A.S_S = 1000198 /*processed*/
     and A.STATUS = 5 /*processed*/
   
   if LEN(@res) > 2
     set @res = substring(@res,0,len(@res))  
	   
   if LEN(@res) = 0
     return null
     
   return @res  

end;