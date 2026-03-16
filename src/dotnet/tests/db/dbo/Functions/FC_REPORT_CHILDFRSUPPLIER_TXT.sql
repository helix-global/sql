create function [dbo].[FC_REPORT_CHILDFRSUPPLIER_TXT](@ReportID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''
   
   select @res = @res + case when len(@res) > 0 then ', ' else '' end + isnull(C.CODE,'N/A')
   from FC_REPORT A with (nolock)
   left join PR_MODELS B with (nolock) on B.ID = A.MODELID
   left join COM_DEPARTMENTS C with(nolock) on C.ID = B.DEPID  
   where A.PARENTID = @ReportID
           
       
   if LEN(@res) = 0
     return null
     
   return @res  

end;