create function dbo.SM_SERVICETASKS_4_DEVICE (@aDeviceID int, @aUserID int, @aMode int)
returns @res table (ID int)
as 
begin

   declare @mtid int
   
   select @mtid = B.TYPEID
   from PR_DEVICE A with (nolock)
   left join PR_MODELS B with (nolock) on B.ID = A.MODELID
   where A.ID = @aDeviceID

   insert into @res (ID)
   select A.ID 
   from SM_SERVICETASKS A with (nolock)
   where A.MTID = @mtid

return

end