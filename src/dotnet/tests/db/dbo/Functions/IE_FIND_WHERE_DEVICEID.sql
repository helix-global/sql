create function [dbo].[IE_FIND_WHERE_DEVICEID] (@aDeviceID int, @UserID int)
returns @res table (ID int)
as 
begin
                      
   insert into @res (ID)
   select B.ID
   from IE_IEITEMS A with (nolock)
   left join IE_IE B with (nolock) on B.ID = A.VNESHID
   where A.DEVICEID = @aDeviceID
                      
   return
    
end