create function [dbo].[IE_FIND_WHERE_OTHER] (@aSCallID int ,@aSCaseID int, @aWOrderID int, @UserID int)
returns @res table (ID int)
as 
begin

                         
   if @aSCallID is not null
   begin
    
       insert into @res (ID) 
       select C.VNESHID
        from SM_SERVICECALL A with (nolock)
        left join PR_DEVICE B with (nolock) on B.MODELID = A.MODELID and B.SN = A.SN
        left join IE_IEITEMS C with (nolock) on C.DEVICEID = B.ID
       where A.ID = @aSCallID  
   
       
   end
   else if @aSCaseID is not null
   begin
   
		insert into @res (ID) 
		select C.VNESHID
		from SM_SERVICECASE_ITEMS A with (nolock) 
		left join IE_IEITEMS C with (nolock) on C.DEVICEID = A.DEVICEID
		where A.VNESHID = @aSCaseID
   
   end
   else if @aWOrderID is not null
   begin
   
		insert into @res (ID) 
		select C.VNESHID
		from SM_WORKORDER A with (nolock) 
		left join IE_IEITEMS C with (nolock) on C.DEVICEID = A.DEVICEID
		where A.ID = @aWOrderID
   
   end
                      
   return
    
end