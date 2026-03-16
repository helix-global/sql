CREATE FUNCTION [dbo].[SM_SERVICECASE_STATE_tmp] (@CaseID int, @DateFrom datetime, @DateTo datetime)
RETURNS int
AS
BEGIN

  --Result:
  --1: New
  --2: Closed
  --4: In Progress
  -- or bitwise combination

  declare @isNew int
  declare @isClosed int
  declare @isInProgress int

  select 
    @isNew =  
      (
      case 
        when SC.DD >= @DateFrom and SC.DD <= @DateTo
        then 1
        else 0
      end
      ),
    @isClosed =  
      (
      case 
        when S_S<>1000191  and dbo.SM_SERVICECASE_CLOSE_DATE(SC.ID) >= @DateFrom and dbo.SM_SERVICECASE_CLOSE_DATE(SC.ID) <= @DateTo -- dbo.SM_SERVICECASE_CLOSE_DATE(SC.ID) is not null and S_S<>100019
        then 2
        else 0
      end
      ),
    @isInProgress =  
      (
      case 
        when  SC.DD <= @DateTo and ((dbo.SM_SERVICECASE_CLOSE_DATE(SC.ID) is null and SC.S_S=1000191) or dbo.SM_SERVICECASE_CLOSE_DATE(SC.ID) >= @DateTo)
        then 4
        else 0
      end
      )
  from SM_SERVICECASE SC with (nolock)
  where SC.ID = @CaseID

  return @isNew | @isClosed | @isInProgress;

END