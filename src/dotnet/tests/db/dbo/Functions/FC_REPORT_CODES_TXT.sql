CREATE function [dbo].[FC_REPORT_CODES_TXT](@ReportID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''
   

   select @res = @res + '(' + ltrim(rtrim(str(A.REPCODEID))) + ') ' + B.NAME + CHAR(13) + char(10) 
   from FC_REPORT_CODES A with (nolock)
   left join FC_FAILURECODES B with (nolock) on B.ID = A.REPCODEID
   where A.VNESHID = @ReportID
	   
   if (@aMode = 2)
   begin	   
     declare @anDesc nvarchar(1000)
     select @anDesc = A.FAILUREDESCRIPTION from FC_REPORT A with (nolock) where A.ID = @ReportID
     if @anDesc is not null
     begin
       if LEN(@res) > 0
         set @res = @res + CHAR(13) + char(10) + @anDesc
       else
         set @res = @anDesc
     end
   end
	   
	   
   if LEN(@res) = 0
     return null
     
   return @res  

end;