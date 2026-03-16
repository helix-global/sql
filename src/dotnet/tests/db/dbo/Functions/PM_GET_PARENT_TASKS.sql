CREATE function [dbo].[PM_GET_PARENT_TASKS] (@aTaskID int, @aMode int)
returns @res table (ID int)
as 
begin
  
  
  declare @i int = 0
  declare @parentID int
  declare @taskID int = @aTaskID
  
  while (1=1)
  begin
     set @parentID = null 

     select @parentID = A.PARENTID 
     from PM_TASK A with (nolock) 
     where A.ID = @taskID
     
     if @parentID is null 
       break
  
     insert into @res (ID) values (@parentID)
       
     set @taskID = @parentID  
       
     set @i = @i + 1  
     
     if @i > 300
       break      
  
  end

  return

end