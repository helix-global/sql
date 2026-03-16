CREATE function [dbo].[FC_REPORT_INCINSP_TXT](@ReportID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''
   
   if @aMode = 2 /*03.11.17 добавлен режим для YMA custom report по заявке YMA*/
   begin
   
     select @res = @res + ', ' + NAME  
     from (
       /*select distinct isnull(B.EXT_NAME,B.NAME) as NAME*/
       select distinct B.NAME as NAME
       from FC_REPORT_ANALYSIS_CODES A with (nolock)
       left join FC_FAILUREANALYSISCODES B with (nolock) on B.ID = A.ANALYSISCODEID
       where A.VNESHID = @ReportID
     ) M
     
     if len(@res) > 2
     begin
       if substring(@res,1,2) = ', '
         set @res = substring(@res,3,9999)
       set @res = @res + '.'
     end    
     
     return @res
   
   end
   
   select @res = rtrim(A.RESULT_INC_INSP)
   from FC_REPORT A with (nolock)
   where A.ID = @ReportID

   if len(@res) > 0
     set @res = @res + CHAR(13) + char(10) 
     
   select @res = @res + CHAR(13) + char(10) + B.NAME + ': ' + cast(A.PVALUE as nvarchar(max))  
   from FC_REPORT_PARAMS A with (nolock)
   left join FC_FAILUREPARAMS B with (nolock) on B.ID = A.PARAMID
   where A.FRID = @ReportID
     and isnull(B.PRINT_IN_REP,0) = 1
     and A.PVALUE is not null
	   
	   
   if LEN(@res) = 0
     return null
     
   return @res  

end;