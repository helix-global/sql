CREATE function [dbo].[FC_LAST_FAILUREDESC](@DeviceID int,@aMode int)
returns nvarchar(max)
as
begin

   declare @res nvarchar(max)
   declare @lastFRid int
   
   
   if @aMode = 1   /* последний FAR по @DeviceID*/
   begin

	   select top 1 @lastFRid = A.ID from FC_REPORT A with (nolock) where A.DEVICEID = @DeviceID order by ID desc
	   
	   if @lastFRid is null
		 return null

       select @res = A.FAILUREDESCRIPTION from FC_REPORT A with (nolock) where A.ID = @lastFRid
   
   end
   else if @aMode = 3   /* FAR из последнего Service Order по @DeviceID*/
   begin

	   select top 1 @lastFRid = A.FRID 
	     from PR_PRORDER_SERVICE A with (nolock) 
	     left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
	    where A.DEVICEID = @DeviceID 
	      and B.S_S > 1
	      and exists (select K.ID from PR_OPERATION K with (nolock) where K.ORDERID = A.ORDERID and K.DEVICEID = A.DEVICEID)
	    order by A.ID desc
	   
	   if @lastFRid is null
		 return null

       select @res = A.FAILUREDESCRIPTION from FC_REPORT A with (nolock) where A.ID = @lastFRid
   
   end
   
     
   return @res  

end;