CREATE function [dbo].[FC_REPORT_ANALYSISCODES_TABLE_test](@ReportID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''
   
   select @res = @res + isnull(D.NAME,'') + '<cell>' + case 
                                     when A.FCODE is null then ''
                                     when isnull(C.DISCOVERED,0) = 1 then 'Discovered' 
                                     when isnull(B.NOTCONFIRMED,0) = 1 then 'Not confirmed' 
                                     else 'Confirmed' end  
                        + '<cell>' + case isnull(B.NOTCONFIRMED,0) 
                                     when 1 then 'NA' 
                                     else coalesce(T.EXT_NAME,B.EXT_NAME,B.NAME) end 
                        + '<row>' 
   from FC_REPORT A0 with (nolock)
   left join FC_REPORT_ANALYSIS_CODES A with (nolock) on A.VNESHID = A0.ID
   left join FC_FAILUREANALYSISCODES B with (nolock) on B.ID = A.ANALYSISCODEID
   left join FC_REPORT_CODES C with (nolock) on C.ID = A.FCODE
   left join FC_FAILURECODES D with (nolock) on D.ID = C.REPCODEID
   left join FC_FAILUREANALYSISCODES_T T with (nolock) on T.VNESHID = B.ID and T.CUSTID = A0.FROMCUSTOMERID
   where A0.ID = @ReportID
     and A.VNESHID is not null
     and isnull(A.OPTS,0) <> 1 /*Internal Only*/
   order by case when C.ID is null then 1 else 0 end, C.ID
	   
   if LEN(@res) = 0
     return null
     
   return @res  

end;