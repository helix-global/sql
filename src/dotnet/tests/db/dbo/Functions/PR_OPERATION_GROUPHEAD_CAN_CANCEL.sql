CREATE function [dbo].[PR_OPERATION_GROUPHEAD_CAN_CANCEL](@aID int, @aState int, @aOperGrID int, @aUserID int, @aMode int)
returns int
as
begin

  if (@aState <> 1000013)
     return 0
  
  if @aState = 1000013 and dbo.PR_OPERGR_QUALIFICATION(@aOperGrID,@aUserID,getdate()) = 1
      return 1
  
  return 0   


end;