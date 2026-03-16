create function [dbo].[SL_CHECK_CUSTOMIZED5](@aProductType int, @aCustom4Group int, @aCustom4ID int, @aCustomerID int)
returns int
as
begin

  if @aProductType <> 2 
    return 1

  if @aCustom4ID = @aCustomerID
     return 1

  if exists (select A.ID from COM_CUST_GROUP_T A with (nolock) where A.VNESHID = @aCustom4Group and A.CUSTID = @aCustomerID)
     return 1
  
  return 0
  
end;