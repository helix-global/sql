create function [dbo].[PR_REPORT_T_CHECKOPTIONS](@aDeviceID int, @aOnlyCustomerID int, @aOnlyOptionID int)
returns int as 
begin
   
  if @aOnlyCustomerID is null and @aOnlyOptionID is null  
    return 1

  if @aOnlyOptionID is not null
  begin
     if not exists (select B.ID from PR_DEVICE_OPT B with (nolock) where B.DEVICEID = @aDeviceID and B.OPTID = @aOnlyOptionID)
        return 0
  end
  
  if @aOnlyCustomerID is not null
  begin
  
     declare @custID int
     
     select @custID = coalesce(C.CUSTOMERID, B.CUSTOMERID, 0)
     from PR_DEVICE A with (nolock)
     left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
     left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
     where A.ID = @aDeviceID
     
     if @custID <> @aOnlyCustomerID
        return 0
  
  end
  
  return 0
end