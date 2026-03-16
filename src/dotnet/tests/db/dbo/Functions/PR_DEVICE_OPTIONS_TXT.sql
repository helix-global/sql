CREATE function [dbo].[PR_DEVICE_OPTIONS_TXT](@DeviceID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''
   
   
   if ISNULL(@aMode,0) = 0
   begin
   
	   select @res = @res + B.CODE + ': "' + B.NAME + '"' + CHAR(13) + char(10) 
	   from PR_DEVICE_OPT A with (nolock)
	   left join PR_MODELTYPE_OPTIONS B with (nolock) on B.ID = A.OPTID
	   where A.DEVICEID = @DeviceID
	   
   end
   else if @aMode = 1
   begin
   
	   select @res = @res + PR.NAME + ' = ' + cast(P.PVALUE as nvarchar) 
	                      + case when PR.DATATYPE = 10 then ' Ver: '+dbo.PR_DEVICE_SW_REVNAME(@DeviceID,PR.ID) else '' end
	                      + CHAR(13) + char(10) 
	   from PR_DEVICE A with (nolock)
	   left join PR_PRORDER_T B with (nolock) on B.ID = A.ORDERROWID
	   left join PR_PRORDER_TP P with (nolock) on P.OPID = B.ID
	   left join PR_MODELTYPE_PARAMS PR with (nolock) on PR.ID = P.PARAMID
	   where A.ID = @DeviceID
	     and P.PVALUE is not null
   
   end
    
   if LEN(@res) = 0
     return null
     
   return @res  

end;