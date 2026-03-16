CREATE function [dbo].[PR_DEVICE_CHILDS](@aDeviceID int,@IncludeParentID int)
returns @res table (ID int)
as
begin
  
  insert into @res (ID)
  select A.ID
  from PR_DEVICE A with (nolock) 
  where A.PARENTID = @aDeviceID
  
  if isnull(@IncludeParentID,0) = 1
  begin
	insert into @res (ID) values (@aDeviceID)
  end  
  
  declare @i int = 0
  
  while (1=1)
  begin
  
     insert into @res (ID) 
     select A.ID from PR_DEVICE A with (nolock) 
     where A.PARENTID in (select ID from @res)
       and not exists (select B.ID from @res B where B.ID = A.ID)
       
     if @@rowcount = 0
       break
       
     set @i = @i + 1  
     
     if @i > 300
       break      
  
  end

  return
  
end;