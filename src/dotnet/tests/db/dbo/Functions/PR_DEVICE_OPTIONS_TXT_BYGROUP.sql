create function [dbo].[PR_DEVICE_OPTIONS_TXT_BYGROUP](@DeviceID int,@OptionGroupID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   set @res = ''
   

   select @res = @res + B.CODE + ' ' + CHAR(13) + char(10) 
   from PR_DEVICE_OPT A with (nolock)
   left join PR_MODELTYPE_OPTIONS B with (nolock) on B.ID = A.OPTID
   where A.DEVICEID = @DeviceID
     and B.OPTGROUP = @OptionGroupID
	   
    
   if LEN(@res) = 0
     return null
     
   return @res  

end;