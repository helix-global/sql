CREATE function [dbo].[PR_MODEL_PREFIX] (@aModelName nvarchar(250), @aMode int)
returns nvarchar(250)
as 
begin

   declare @res nvarchar(250)
   declare @i int
   set @res = @aModelName
   
   set @i = PATINDEX('%-[0-9]%',@res) 

   if (@i > 2)
     set @res = SUBSTRING(@res,1,@i-1)
   
   return @res

end