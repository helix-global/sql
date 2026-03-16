CREATE function [dbo].[PM_GET_CHILD_TASKS] (@ParentTaskID int, @aMode int)
returns @res table (ID int)
as 
begin
  
  /*@aMode = 123 добавляет саму родительскую задачу*/
  
  insert into @res (ID) 
  select A.ID from PM_TASK A with (nolock) where A.PARENTID = @ParentTaskID
  
  declare @i int = 0
  
  while (1=1)
  begin
  
     insert into @res (ID) 
     select A.ID from PM_TASK A with (nolock) 
     where A.PARENTID in (select ID from @res)
       and not exists (select B.ID from @res B where B.ID = A.ID)
       
     if @@rowcount = 0
       break
       
     set @i = @i + 1  
     
     if @i > 300
       break      
  
  end
  
  if @aMode = 123
  begin
		insert into @res (ID) values (@ParentTaskID)  
  end

  return

end