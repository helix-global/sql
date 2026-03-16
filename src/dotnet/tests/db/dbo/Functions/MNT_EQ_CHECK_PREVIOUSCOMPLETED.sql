-- KB4452:2024-02-23: By default, assume that the absence of a setting {@aSetting} means that a repeat check is necessary.
CREATE function [dbo].[MNT_EQ_CHECK_PREVIOUSCOMPLETED](@aSetting int,@EqID int,@PlanID int)
returns int as 
begin

  if isnull(@aSetting,1) = 0 
    return 1

  declare @lastMntOperationID int
  declare @lastMntOperationCompleted datetime
  
  select top 1 @lastMntOperationID = A.ID
              ,@lastMntOperationCompleted = A.COMPLETED_DT
  from PR_OPERATION A with(nolock)
  where A.EQID = @EqID
    and A.S_S <> 1000023 /*canceled*/
  order by A.ID desc  
    
    
  if @lastMntOperationID is not null and @lastMntOperationCompleted is null
     return 0
  return 1;
end