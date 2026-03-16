create function [dbo].[IOE_TRAINING_ACCESS](@aTrainingID int,@aTrainingDepID int,@aMode int,@aUser int,@aDate datetime)
returns int as 
begin

  if dbo.DEF_USERINGROUP5(@aUser,'ONLTRF','ADM',null,null,null) = 1
  begin
	return 1
  end 
  
  if dbo.COM_DEP_ACCESS2(@aTrainingDepID,1,@aUser,@aDate) = 1
  begin
	return 1
  end 
  
  return 0
end