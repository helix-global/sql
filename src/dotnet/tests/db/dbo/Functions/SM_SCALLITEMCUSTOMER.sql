create function [dbo].[SM_SCALLITEMCUSTOMER](@ModelID int,@SN nvarchar(50))
returns nvarchar(250)
as
begin
  declare @res nvarchar(250) 


  select @res = J.NAME
  from PR_DEVICE A with (nolock)
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
  left join COM_CUSTOMER J with (nolock) on J.ID  = isnull(C.CUSTOMERID, B.CUSTOMERID)
  where A.MODELID = @ModelID
    and A.SN = @SN

  return @res;
end;