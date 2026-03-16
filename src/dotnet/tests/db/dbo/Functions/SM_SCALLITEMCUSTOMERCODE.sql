create function [dbo].[SM_SCALLITEMCUSTOMERCODE](@ModelID int,@SN nvarchar(50))
returns nvarchar(50)
as
begin
  declare @res nvarchar(50) 


  select @res = J.GLNN
  from PR_DEVICE A with (nolock)
  left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
  left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
  left join COM_CUSTOMER J with (nolock) on J.ID  = isnull(C.CUSTOMERID, B.CUSTOMERID)
  where A.MODELID = @ModelID
    and A.SN = @SN

  return @res;
end;