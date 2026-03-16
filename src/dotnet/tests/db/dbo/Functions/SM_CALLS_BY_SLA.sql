create function [dbo].SM_CALLS_BY_SLA (@SlaID int, @DepID int, @mtID int, @custID int, @modelID int)
returns @res table (ID int )
as 
begin

  insert into @res (ID)
  select A.ID
  from SM_SERVICECALL A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.SDEPID = @DepID
    and A.SCDIRECTION = 1 /*incoming*/
    and A.SCTYPE = 2 /*email*/  
    and (@mtID is null or @mtID = B.TYPEID)
    and (@custID is null or @custID = A.CUSTID)
    and (@modelID is null or @modelID = A.MODELID)
    
  return

end