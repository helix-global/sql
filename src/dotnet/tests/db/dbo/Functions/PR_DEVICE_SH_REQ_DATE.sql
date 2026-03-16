create function [dbo].[PR_DEVICE_SH_REQ_DATE](@aDeviceID int, @aMode int)
returns date 
as
begin

/*  KB931

@aMode 1 - first
       2 - last

*/

  declare @res date
  
  if @aMode = 1
  begin
	  
	  select top 1 @res = cast(B.DD as date)
	  from SH_ORDER_T A with (nolock)
	  left join SH_ORDER B with (nolock) on B.ID = A.SHORDERID
	  where A.DEVICEID = @aDeviceID
		and B.S_S = 1000024 /*shipped*/
	  order by A.ID 
	  
  end
  else if @aMode = 2
  begin
	  
	  select top 1 @res = cast(B.DD as date)
	  from SH_ORDER_T A with (nolock)
	  left join SH_ORDER B with (nolock) on B.ID = A.SHORDERID
	  where A.DEVICEID = @aDeviceID
		and B.S_S = 1000024 /*shipped*/
	  order by A.ID desc
	  
  end

    
  return @res
end;