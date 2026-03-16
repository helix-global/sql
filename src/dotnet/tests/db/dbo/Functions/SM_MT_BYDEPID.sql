create function [dbo].[SM_MT_BYDEPID] (@aServiceDepID int,@aMode int)
returns @res table (ID int)
as 
begin

  insert into @res (ID) 
  select distinct A.MTID 
  from SM_EMAIL_BOXES_MT A with (nolock) 
  left join SM_EMAIL_BOXES B with (nolock) on B.ID = A.VNESHID
  where B.DEPID = @aServiceDepID
  
  return

end