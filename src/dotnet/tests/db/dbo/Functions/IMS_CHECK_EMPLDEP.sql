create function [dbo].[IMS_CHECK_EMPLDEP](@aEmplDepID int, @aTrainingType int, @aMode int)
returns int as 
begin

  declare @int_ext int
  declare @depID int
  
  select @int_ext = A.INT_EXT 
        ,@depID = A.DEPID  
  from IMS_TRAINING_TYPE A with (nolock) where A.ID = @aTrainingType
  
  if @int_ext = 2
    return 1

  
  if @int_ext = 1 
  begin
  
    if @aEmplDepID = @depID
      return 1
    
    if exists (select A.ID from dbo.COM_GETCHILD_DEPARTMENTS(@depID) A where A.ID = @aEmplDepID)
      return 1
  
  end
  
  return null


end