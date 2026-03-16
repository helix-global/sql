create function [dbo].[SH_NEWSTATE_IF_ALL_SHIPPED](@aDeviceID int,@aOldState int,@aMode int)
returns int as 
begin

  declare @accMode int
  declare @itemQty int
  
  select @accMode = isnull(C.ACCMODE,0)
        ,@itemQty = isnull(A.RESQUANTITY,1)
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
  where A.ID = @aDeviceID
  
  if @accMode in (0,3) /*by SN*/
     return 1000010  /*shipped*/
  
  declare @allreadyShipped int
  select @allreadyShipped = sum(isnull(A.QTYTOSHIP,1)) 
        from SH_ORDER_T A with (nolock)
        left join SH_ORDER B with (nolock) on B.ID = A.SHORDERID
       where A.DEVICEID = @aDeviceID
         and B.S_S = 1000024 /*shipped*/
  
  if @allreadyShipped >= @itemQty
     return 1000010  /*shipped*/
         
         
  return @aOldState       
  
end