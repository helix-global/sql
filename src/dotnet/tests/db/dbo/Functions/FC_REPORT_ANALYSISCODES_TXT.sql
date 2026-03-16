CREATE function [dbo].[FC_REPORT_ANALYSISCODES_TXT](@ReportID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''
   
   if(@aMode in (1,2))
   begin
       select @res = @res + '(' + ltrim(rtrim(str(A.ANALYSISCODEID))) + ') ' + B.NAME + CHAR(13) + char(10) 
       from FC_REPORT_ANALYSIS_CODES A with (nolock)
       left join FC_FAILUREANALYSISCODES B with (nolock) on B.ID = A.ANALYSISCODEID
       where A.VNESHID = @ReportID
           
       if (@aMode = 2)
       begin       
         declare @anDesc nvarchar(2000)
         select @anDesc = A.FAILURE_ANALYSIS from FC_REPORT A with (nolock) where A.ID = @ReportID
         if @anDesc is not null
         begin
           if LEN(@res) > 0
             set @res = @res + CHAR(13) + char(10) + @anDesc
           else
             set @res = @anDesc
         end
       end
   end   
   else if (@aMode = 3)
   begin
      select @res = @res + '(' + ltrim(rtrim(str(A.ANALYSISCODEID))) + ') ' + B.NAME + CHAR(13) + char(10) 
      from FC_REPORT_ANALYSIS_CODES A with (nolock)
      left join FC_FAILUREANALYSISCODES B with (nolock) on B.ID = A.ANALYSISCODEID
      where 
                A.VNESHID = @ReportID
         and
                A.INITI = 1
   end
   else if (@aMode = 4)
   begin
      select @res = @res +  ltrim(rtrim(str(A.ANALYSISCODEID))) + ','
      from FC_REPORT_ANALYSIS_CODES A with (nolock)
      left join FC_FAILUREANALYSISCODES B with (nolock) on B.ID = A.ANALYSISCODEID
      where 
                A.VNESHID = @ReportID
         and
                A.INITI = 1

    if LEN(@res) > 0
        set @res = SUBSTRING(@res,1,len(@res)-1)
   end
   else if (@aMode = 5)
   begin
      select @res = @res +  B.NAME + ','
      from FC_REPORT_ANALYSIS_CODES A with (nolock)
      left join FC_FAILUREANALYSISCODES B with (nolock) on B.ID = A.ANALYSISCODEID
      where 
                A.VNESHID = @ReportID
         and
                A.INITI = 1

    if LEN(@res) > 0
        set @res = SUBSTRING(@res,1,len(@res)-1)
   end
   
       
   if LEN(@res) = 0
     return null
     
   return @res  

end;