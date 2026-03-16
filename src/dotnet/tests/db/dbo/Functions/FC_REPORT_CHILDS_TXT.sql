create function [dbo].[FC_REPORT_CHILDS_TXT](@ReportID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''

   select @res = @res + '[' + ltrim(rtrim(str(A.ID))) + '] ' + B.NAME + ' SN:'+ A.SN + CHAR(13) + char(10) 
   from FC_REPORT A with (nolock)
   left join PR_MODELS B with (nolock) on B.ID = A.MODELID
   where A.PARENTID = @ReportID
	   
   if LEN(@res) = 0
     return null
     
   return @res  

end;