CREATE FUNCTION [dbo].[SM_SERVICECASE_CLOSE_DATE] (@CaseID int)
RETURNS datetime
AS
BEGIN

  declare @result datetime
  
  select @result =  
    (
    case 
      when SC.S_S in (1000192 /*Problem Solved*/) or R.STATUS is not null and R.STATUS in (4 /*Rejected*/)
      then isnull(SC.DCLOSE,SC.S_MDT)
      when SC.S_S in (2000012 /*RMA/SC Issued*/) and PO.S_S in (1000037 /*Shipped*/,1000036 /*Completed*/)
      then PO.COMPLETED_DT
      else null
    end
    ) 
  from SM_SERVICECASE SC with (nolock)
  left join PR_PRORDER PO with (nolock) on PO.ID = SC.SERVORDID
  left join PDB_BUFFER..SERVICEREQUEST R with (nolock) on R.SCASEID = SC.ID
    where SC.ID = @CaseID
      and (SC.S_S in (1000192 /*Problem Solved*/) or R.STATUS is not null and R.STATUS in (4 /*Rejected*/) or (SC.S_S in (2000012 /*RMA/SC Issued*/) and PO.S_S in (1000037 /*Shipped*/,1000036 /*Completed*/)))

  return @result

END