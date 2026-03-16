create function [dbo].[IOE_TOPIC_AVAILABLE](@aDepID int,@aMode int)
returns @res table (ID int) as 
begin


  insert into @res (ID)
  select A.ID from IOE_TOPICS A with(nolock) where isnull(A.AVAILALL,0) = 1

  insert into @res (ID)
  select distinct A.VNESHID from IOE_TOPIC_DEPS A with(nolock) where A.DEPID = @aDepID 

  
  return 
end