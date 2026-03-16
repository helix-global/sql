create function [dbo].PR_SO_FIND_RELEVANT_SR(@SupplyOrderID int)
returns @res table (ID int)
as 
begin

  insert into @res(ID)
  select distinct A.SHORDERID 
  from SH_ORDER_T A with (nolock) 
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID 
  where B.SORDERID = @SupplyOrderID

  return 
end